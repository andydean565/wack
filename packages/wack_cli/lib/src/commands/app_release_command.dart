import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

/// {@template tickets_command}
/// A command which creates a new release for the app.
/// {@endtemplate}
class AppReleaseCommand extends Command<int> {
  /// {@macro app_release_command}

  @override
  String get description => 'create a new release for the app';

  static const String commandName = 'app release';

  @override
  String get name => commandName;

  @override
  Future<int> run() async {
    await Process.run('./scripts/app_release.sh', [], runInShell: true);
    return ExitCode.success.code;
  }
}
