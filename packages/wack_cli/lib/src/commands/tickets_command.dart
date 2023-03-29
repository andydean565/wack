import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:atlassian_apis/jira_platform.dart';
import 'package:config_repo/config_repo.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:wack_cli/src/command_runner.dart';
import 'package:wack_cli/src/version.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:ticket_host_repo/ticket_host_repo.dart';

/// {@template tickets_command}
/// A command which fetches tickets.
/// {@endtemplate}
class TicketsCommand extends Command<int> {
  /// {@macro tickets_command}
  TicketsCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addOption('project', abbr: 'p', defaultsTo: 'WISE')
      ..addOption(
        'status',
        abbr: 's',
        help: 'ticket status seperated by comma [defaults to Ready To Do]',
        // defaultsTo: 'Ready To Do',
      )
      ..addFlag(
        'mine',
        abbr: 'm',
        help: 'get only issues assigned to you',
        negatable: false,
      );
  }

  final Logger _logger;

  @override
  String get description => 'get avaliable tickets';

  static const String commandName = 'tickets';

  @override
  String get name => commandName;

  late ConfigRepo config = ConfigRepo.fromEnv()!;

  late TicketHostRepo ticketRepo = JiraHostRepo(
    token: config.jiraApiToken,
    user: config.jiraUser,
  );

  @override
  Future<int> run() async {
    final result = await ticketRepo.searchTickets(
      // config.ticketFlow,
      (argResults?['status'] as String?)?.split(','),
      argResults?['project'] as String?,
      maxResults: 50,
      me: true,
    );

    _logger.info(
      result.fold(
        '',
        (p, e) => '$p\n${e.toString()}',
      ),
    );

    return ExitCode.success.code;
  }
}
