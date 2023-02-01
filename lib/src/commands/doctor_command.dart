import 'dart:convert';
import 'dart:io';
import 'package:config_repo/config_repo.dart';
import 'package:git/git.dart';

import 'package:args/command_runner.dart';
import 'package:git_host_repo/git_host_repo.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:wize/src/command_runner.dart';
import 'package:wize/src/version.dart';
import 'package:path/path.dart' as p;

/// {@template update_command}
/// A command which updates the CLI.
/// {@endtemplate}
class DoctorCommand extends Command<int> {
  /// {@macro update_command}
  DoctorCommand({
    required Logger logger,
    PubUpdater? pubUpdater,
  })  : _logger = logger,
        _pubUpdater = pubUpdater ?? PubUpdater();

  final Logger _logger;
  final PubUpdater _pubUpdater;

  @override
  String get description => 'confims config is set';

  static const String commandName = 'doctor';

  @override
  String get name => commandName;

  late ConfigRepo? config = ConfigRepo.fromEnv();

  late GitHostRepo gitRepo = GitlabHostRepo();

  @override
  Future<int> run() async {
    try {
      // ? local config check
      if (config != null) {
        _logger.info('local config has been set');
        final confim = _logger.confirm(config!.toJson().toString());
        if (confim) {
          return ExitCode.success.code;
        }
      }

      // ? set new config

      // ? git dir check
      if (!(await gitRepo.gitDir)) {
        _logger.err('current dir is no a git repo');
        return ExitCode.ioError.code;
      }
      _logger.info('set new config: ');
      config = await _inputConfig(config: config);
      await config!.toEnv();

      return ExitCode.success.code;
    } catch (e) {
      print(e);
      return ExitCode.ioError.code;
    }
  }

  // @override
  // Future<int> run() async {
  //   try {
  //     await _git();
  //     final localConfig = _localConfig();
  //     final inputConfig = await _inputConfig(
  //       config: localConfig,
  //     );
  //     await _saveConfig(
  //       inputConfig,
  //     );
  //     return ExitCode.success.code;
  //   } catch (e) {
  //     print(e);
  //     return ExitCode.ioError.code;
  //   }
  // }

  Future<void> _git() async {
    // TODO verify in git repo
    final gitVerifyProgress = _logger.progress('Checking for git');
    // ignore: cascade_invocations
    var gitDir = await GitDir.isGitDir(p.current);
    if (!gitDir) {
      gitVerifyProgress.fail('git not found in current dir');
      throw Exception('not git repo');
    }
    gitVerifyProgress.complete('git found');
  }

  Future<ConfigRepo> _inputConfig({ConfigRepo? config}) async {
    final configProgress = _logger.progress('config input');
    final jiraUser = _logger.prompt(
      'ATLASSIAN_USER',
      defaultValue: config?.jiraUser,
    );
    final jiraApiKey = _logger.prompt(
      'ATLASSIAN_API_TOKEN',
      defaultValue: config?.jiraApiToken,
    );
    final ticketFlow = _logger.prompt(
      'TICKET_FLOW',
      defaultValue: config?.ticketFlow,
    );
    final branchFlow = _logger.prompt(
      'BRANCH_FLOW',
      defaultValue: config?.branchFlow,
    );

    final input = ConfigRepo(
      jiraUser: jiraUser,
      jiraApiToken: jiraApiKey,
      branchFlow: branchFlow.split(','),
      ticketFlow: ticketFlow.split(','),
    );
    configProgress.complete('config inputted');
    return input;
  }
}
