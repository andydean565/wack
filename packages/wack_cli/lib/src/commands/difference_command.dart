import 'package:args/command_runner.dart';
import 'package:config_repo/config_repo.dart';
import 'package:git_host_repo/git_host_repo.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:ticket_host_repo/ticket_host_repo.dart';

/// {@template tickets_command}
/// A command which fetches tickets.
/// {@endtemplate}
class DifferenceCommand extends Command<int> {
  /// {@macro tickets_command}
  DifferenceCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addOption(
        'target',
        abbr: 't',
        help: 'target branch',
      )
      ..addOption(
        'source',
        abbr: 's',
        help: 'source branch',
      );
  }

  final Logger _logger;

  @override
  String get description => 'get difference between branches';

  static const String commandName = 'difference';

  @override
  String get name => commandName;

  late GitHostRepo gitRepo = GitlabHostRepo();

  late ConfigRepo config = ConfigRepo.fromEnv()!;

  late TicketHostRepo ticketRepo = JiraHostRepo(
    token: config.jiraApiToken,
    user: config.jiraUser,
  );

  @override
  Future<int> run() async {
    var foundTickets = <List<String>, Ticket>{};

    final target = (argResults?['target'] as String?) ?? 'release';
    final source = (argResults?['source'] as String?) ?? 'develop';

    final commits = await gitRepo.getCommitDifference(source, target);
    final ticketCommits = commits.entries.fold<Map<String, String>>(
      {},
      (p, e) {
        final data = ticketRepo.findKey(e.value.message);
        if (data.isNotEmpty) {
          return {
            ...p,
            ...{
              e.key: data.first.toUpperCase(),
            }
          };
        }
        return p;
      },
    );

    if (ticketCommits.isNotEmpty) {
      final tickets = await ticketRepo.getTickets(
        ticketCommits.entries.map((e) => e.value).toList(),
      );

      foundTickets = tickets.fold<Map<List<String>, Ticket>>(
        {},
        (p, e) {
          final commit = ticketCommits.entries.where(
            (f) => ticketRepo.containsTicket(
              f.value,
              e.key,
            ),
          );
          return {
            ...p,
            ...{
              commit.map((e) => e.key).toList(): e,
            }
          };
        },
      );

      _logger.alert('ticket commits: \n');

      for (final element in foundTickets.entries) {
        _logger.info('${element.value.toString()}\ncommits: ${element.key}');
      }
    }

    // TODO non tickeet commits

    final commitsTicketsId = foundTickets.entries.fold<List<String>>(
      // ignore: inference_failure_on_collection_literal
      const [],
      (p, e) => [...p, ...e.key],
    );

    final nonTicketCommits = commits.entries
        .where(
          (element) => !commitsTicketsId.contains(element.key),
        )
        // ! removes merge commits
        .where(
          (element) => !element.value.message.startsWith('Merge branch'),
        );
    _logger.alert('non ticket commits: \n');

    for (final element in nonTicketCommits) {
      _logger.info(
        '[${element.key}] ${element.value.message.replaceAll("\n", " ")}\n author: ${element.value.author}',
      );
    }

    return ExitCode.success.code;
  }
}
