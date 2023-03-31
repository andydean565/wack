import 'dart:convert';
import 'dart:io';
import 'package:config_repo/config_repo.dart';
import 'package:git/git.dart';

import 'package:args/command_runner.dart';
import 'package:git_host_repo/git_host_repo.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:wack_cli/src/command_runner.dart';
import 'package:wack_cli/src/version.dart';
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
      await _git();
      _logger.info('set new config: ');
      config = await _inputConfig(config: config);
      await config!.toEnv();

      return ExitCode.success.code;
    } catch (e) {
      print(e);
      return ExitCode.ioError.code;
    }
  }

  Future<void> _git() async {
    final gitVerifyProgress = _logger.progress('Checking for git');
    final gitDir = await GitDir.isGitDir(p.current);
    if (!gitDir) {
      gitVerifyProgress.fail('git not found in current dir');
      throw Exception('not git repo');
    }
    gitVerifyProgress.complete('git found');
  }

  Future<ConfigRepo> _inputConfig({ConfigRepo? config}) async {
    final configProgress = _logger.progress('config input');
    final ticketRepo = _logger.prompt(
      'TICKET_REPO',
      defaultValue: config?.ticketRepo ?? 'jira',
    );
    final gitRepo = _logger.prompt(
      'GIT_REPO',
      defaultValue: config?.gitRepo ?? 'gitlab',
    );
    final gitlabToken = _logger.prompt(
      'GITLAB_API_TOKEN',
      defaultValue: config?.gitlabToken,
    );
    final jiraUser = _logger.prompt(
      'JIRA_USER',
      defaultValue: config?.jiraUser,
    );
    final jiraApiKey = _logger.prompt(
      'JIRA_API_TOKEN',
      defaultValue: config?.jiraApiToken,
    );

    final input = ConfigRepo(
      gitlabToken: gitlabToken,
      gitRepo: gitRepo,
      ticketRepo: ticketRepo,
      jiraUser: jiraUser,
      jiraApiToken: jiraApiKey,
    );
    configProgress.complete('config inputted');
    return input;
  }
}
