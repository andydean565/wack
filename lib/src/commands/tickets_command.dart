import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:atlassian_apis/jira_platform.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:wize/src/command_runner.dart';
import 'package:wize/src/version.dart';
import 'package:mason_logger/mason_logger.dart';

import '../models/models.dart';

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
        defaultsTo: 'Ready To Do',
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
  String get description => 'get jira tickets';

  static const String commandName = 'tickets';

  @override
  String get name => commandName;

  @override
  Future<int> run() async {
    final pageination = 10;
    // TODO load config
    final config = Config.fromEnv()!;
    // TODO fetch tickets
    final client = ApiClient.basicAuthentication(
      Uri.https('wisetribe.atlassian.net', ''),
      user: config.jiraUser,
      apiToken: config.jiraApiToken,
    );
    final jira = JiraPlatformApi(client);

    var statuses = (argResults?['status'] as String).split(',').map((e) {
      if (e.contains(' ')) {
        return '"$e"';
      }
      return e;
    }).join(',');

    var query =
        // ignore: leading_newlines_in_multiline_strings
        """
        status IN ($statuses)
        AND project = ${argResults?['project']}
        ${(argResults?['mine'] as bool) ? 'AND assignee in (currentUser()) ' : ''}
        order by created DESC""";

    // print(query);
    var search = true;
    SearchResults? result;
    while (search) {
      result = await jira.issueSearch.searchForIssuesUsingJqlPost(
        body: SearchRequestBean(
          startAt: (result?.startAt ?? 0) +
              (result?.startAt != null ? pageination : 0),
          maxResults: pageination,
          jql: query,
        ),
      );
      // result = await jira.issueSearch.searchForIssuesUsingJql(
      //   startAt: (result?.startAt ?? 0) + pageination,
      //   maxResults: pageination,
      //   jql: query,
      // );
      _logger.info(
        result.issues.map(Ticket.fromJira).toList().fold(
              '',
              (p, e) => '$p\n${e.toString()}',
            ),
      );

      if (result.issues.length != pageination) {
        search = false;
      } else {
        search = _logger.confirm('continue?', defaultValue: true);
      }
    }
    return ExitCode.success.code;
  }
}
