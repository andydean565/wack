import 'package:args/command_runner.dart';
import 'package:config_repo/config_repo.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:ticket_host_repo/ticket_host_repo.dart';

/// {@template tickets_command}
/// A command which fetches tickets.
/// {@endtemplate}
class TicketCommand extends Command<int> {
  /// {@macro tickets_command}
  TicketCommand({
    required Logger logger,
  }) : _logger = logger {}

  final Logger _logger;

  @override
  String get description => 'get ticket informatin';

  static const String commandName = 'ticket';

  @override
  String get name => commandName;

  late ConfigRepo config = ConfigRepo.fromEnv()!;

  late TicketHostRepo ticketRepo = JiraHostRepo(
    token: config.jiraApiToken,
    user: config.jiraUser,
  );

  @override
  Future<int> run() async {
    if (argResults!.rest.isEmpty) {
      _logger.err('no ticket selected');
      return ExitCode.ioError.code;
    }

    final ticketKey = argResults!.rest.first.toUpperCase();
    final ticket = await ticketRepo.getTicket(ticketKey);
    _logger.info(
      ticket.toString(),
    );

    // TODO options

    final action = _logger.chooseOne(
      'actions:',
      choices: ['update', 'checkout', 'exit'],
      defaultValue: 'exit',
    );

    switch (action) {
      case 'update':
        break;
      case 'checkout':
        runner?.run(['checkout', ticket.key]);
        break;
      default:
    }

    // TODO update

    // TODO checkout

    return ExitCode.success.code;
  }
}
