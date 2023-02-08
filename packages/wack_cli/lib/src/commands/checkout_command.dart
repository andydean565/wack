import 'package:args/command_runner.dart';
import 'package:config_repo/config_repo.dart';
import 'package:git_host_repo/git_host_repo.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:ticket_host_repo/ticket_host_repo.dart';

/// {@template tickets_command}
/// A command which fetches tickets.
/// {@endtemplate}
class CheckoutCommand extends Command<int> {
  /// {@macro tickets_command}
  CheckoutCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addFlag(
        'jira',
        abbr: 'j',
        help: 'update jira ticket to Coding',
        negatable: false,
      )
      ..addCommand('ticket');
  }

  final Logger _logger;

  @override
  String get description => 'checkout ticket';

  static const String commandName = 'checkout';

  @override
  String get name => commandName;

  late ConfigRepo config = ConfigRepo.fromEnv()!;
  late GitHostRepo gitRepo = GitlabHostRepo();
  late TicketHostRepo ticketRepo = JiraHostRepo(
    user: config.jiraUser,
    token: config.jiraApiToken,
  );

  @override
  Future<int> run() async {
    // print(argResults?.rest);
    // print(argResults?.arguments);

    if (argResults!.rest.isEmpty) {
      _logger.err('no ticket selected');
      return ExitCode.ioError.code;
    }

    final ticketKey = argResults!.rest.first.toUpperCase();
    final ticketKeyRegex = RegExp('($ticketKey)-*');

    if (!ticketRepo.ticketKeyValidate(ticketKey)) {
      _logger.err('does not match jira key regex');
      return ExitCode.ioError.code;
    }

    final matchingBranches = await gitRepo.findPrefixBranch(ticketKeyRegex);
    _logger.info('local branches found ${matchingBranches.length}');
    if (matchingBranches.isNotEmpty) {
      if (matchingBranches.length == 1) {
        await gitRepo.checkout(matchingBranches.first.branchName);
        return ExitCode.success.code;
      }
      final action = _logger.chooseOne<String>(
        'branches:',
        choices: matchingBranches.map((e) => e.branchName).toList(),
        defaultValue: matchingBranches.first.branchName,
      );
      await gitRepo.checkout(action);
      return ExitCode.success.code;
    }

    _logger.info('getting ticket info $ticketKey');

    try {
      final ticket = await ticketRepo.getTicket(ticketKey);
      _logger.info('creating branch for $ticketKey');
      await gitRepo.checkout(ticket.branch, newBranch: true);
    } catch (e) {
      _logger.err(e.toString());
    }

    // TODO(andy) update jira

    return ExitCode.success.code;
  }
}
