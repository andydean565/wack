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
class DifferenceCommand extends Command<int> {
  /// {@macro tickets_command}
  DifferenceCommand({
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
  String get description => 'get difference between branches';

  static const String commandName = 'difference';

  @override
  String get name => commandName;

  @override
  Future<int> run() async {
    // TODO check for excisting branch
    final gitDir = await GitDir.fromExisting(p.current);
    final current = await gitDir.commits('main');
    final develop = await gitDir.commits('WISE-228-Biometric_Login');

    print(current);
    print(develop);

    var difference = current.entries.fold<Map<String, Commit>>(
      {},
      (previousValue, element) => {
        ...previousValue,
        if (!develop.containsKey(element.key)) ...{element.key: element.value},
      },
    );

    print(difference);

    return ExitCode.success.code;
  }
}
