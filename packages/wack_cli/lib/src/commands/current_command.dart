import 'package:args/command_runner.dart';
import 'package:config_repo/config_repo.dart';
import 'package:git_host_repo/git_host_repo.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:ticket_host_repo/ticket_host_repo.dart';

/// {@template tickets_command}
/// A command which fetches tickets.
/// {@endtemplate}
class CurrentCommand extends Command<int> {
  /// {@macro tickets_command}
  CurrentCommand({
    required Logger logger,
  }) : _logger = logger {}

  final Logger _logger;

  @override
  String get description => 'current branch ticket info';

  static const String commandName = 'current';

  @override
  String get name => commandName;

  late ConfigRepo config = ConfigRepo.fromEnv()!;

  late GitHostRepo gitRepo = GitlabHostRepo();

  late TicketHostRepo ticketRepo = JiraHostRepo(
    token: config.jiraApiToken,
    user: config.jiraUser,
  );

  @override
  Future<int> run() async {
    final current = await gitRepo.current;
    final matches = ticketRepo.findKey(current.branchName);

    if (matches.isEmpty) {
      // TODO check commits
      return ExitCode.unavailable.code;
    }

    final match = matches.first;

    final ticketKey = match.toUpperCase();
    final ticket = await ticketRepo.getTicket(ticketKey);
    _logger.info(
      ticket.toString(),
    );

    return ExitCode.success.code;
  }
}
