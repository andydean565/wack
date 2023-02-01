import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:args/command_runner.dart';
import 'package:atlassian_apis/jira_platform.dart';
import 'package:git/git.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:wize/src/command_runner.dart';
import 'package:wize/src/version.dart';
import 'package:mason_logger/mason_logger.dart';

/// {@template tickets_command}
/// A command which fetches tickets.
/// {@endtemplate}
class CheckoutCommand extends Command<int> {
  /// {@macro tickets_command}
  CheckoutCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser.addFlag(
      'jira',
      abbr: 'j',
      help: 'update jira ticket to Coding',
      negatable: false,
    );
  }

  final Logger _logger;

  @override
  String get description => 'checkout ticket';

  static const String commandName = 'checkout';

  @override
  String get name => commandName;

  @override
  Future<int> run() async {
    var keyRegex = RegExp('^([a-zA-Z][A-Z0-9]+)');
    // print(argResults?.rest);
    // print(argResults?.arguments);

    if (argResults!.rest.isEmpty) {
      _logger.err('no ticket selected');

      return ExitCode.ioError.code;
    }

    final ticketKey = argResults!.rest.first.toUpperCase();

    var ticketKeyRegex = RegExp('^/($ticketKey)-*');

    if (!keyRegex.hasMatch(ticketKey)) {
      _logger.err('does not match jira key regex');
      return ExitCode.ioError.code;
    }
    // TODO check for excisting branch
    final gitDir = await GitDir.fromExisting(p.current);
    final branches = await gitDir.branches();

    final prefixedBranches = branches.where(
      (element) => ticketKeyRegex.hasMatch(element.branchName),
    );

    _logger.info('local branches found ${prefixedBranches.length}');
    if (prefixedBranches.isNotEmpty) {
      await gitDir.runCommand([
        'checkout',
        prefixedBranches.first.branchName,
      ]).then((result) {
        stdout.write(result.stdout);
        stderr.write(result.stderr);
      });
      return ExitCode.success.code;
    }
    // await gitDir.runCommand(
    //     ['checkout', '-b' ]).then((result) {
    //   stdout.write(result.stdout);
    //   stderr.write(result.stderr);
    // });

    // // TODO get jira ticket
    // final config = Config.fromEnv()!;
    // final client = ApiClient.basicAuthentication(
    //   Uri.https('wisetribe.atlassian.net', ''),
    //   user: config.jiraUser,
    //   apiToken: config.jiraApiToken,
    // );
    // final jira = JiraPlatformApi(client);

    // var result = await jira.issues.getIssue(issueIdOrKey: ticketKey);
    // var ticket = Ticket.fromJira(result);

    // print(ticket.toString());

    // // TODO input branch name with prefix and parsed title
    // await gitDir.runCommand([
    //   'checkout',
    //   '-b',
    //   (ticket.branch),
    // ]).then((result) {
    //   stdout.write(result.stdout);
    //   stderr.write(result.stderr);
    // });

    // TODO update jira
    return ExitCode.success.code;
  }
}
