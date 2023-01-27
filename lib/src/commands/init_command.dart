import 'dart:convert';
import 'dart:io';
import 'package:git/git.dart';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:wize/src/command_runner.dart';
import 'package:wize/src/version.dart';
import 'package:path/path.dart' as p;

import '../models/models.dart';

/// {@template update_command}
/// A command which updates the CLI.
/// {@endtemplate}
class InitCommand extends Command<int> {
  /// {@macro update_command}
  InitCommand({
    required Logger logger,
    PubUpdater? pubUpdater,
  })  : _logger = logger,
        _pubUpdater = pubUpdater ?? PubUpdater();

  final Logger _logger;
  final PubUpdater _pubUpdater;

  @override
  String get description => 'init wize cli';

  static const String commandName = 'init';

  @override
  String get name => commandName;

  @override
  Future<int> run() async {
    try {
      await _git();
      final localConfig = _localConfig();
      final inputConfig = await _inputConfig(
        config: localConfig,
      );
      await _saveConfig(
        inputConfig,
      );
      return ExitCode.success.code;
    } catch (e) {
      print(e);
      return ExitCode.ioError.code;
    }
  }

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

  Config? _localConfig() => Config.fromEnv();

  Future<void> _saveConfig(Config config) => config.toEnv();

  Future<Config> _inputConfig({Config? config}) async {
    final configProgress = _logger.progress('config input');
    final jiraUser = _logger.prompt(
      'ATLASSIAN_USER',
      defaultValue: config?.jiraUser,
    );
    final jiraApiKey = _logger.prompt(
      'ATLASSIAN_API_TOKEN',
      defaultValue: config?.jiraApiToken,
    );

    final input = Config(
      jiraUser: jiraUser,
      jiraApiToken: jiraApiKey,
    );
    configProgress.complete('config inputted');
    return input;
  }
}
