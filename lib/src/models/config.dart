import 'dart:io';
import 'dart:math';

import 'package:dotenv/dotenv.dart';
import 'package:path/path.dart' as p;

class Config {
  Config({
    required this.jiraUser,
    required this.jiraApiToken,
  });

  final String jiraUser;
  final String jiraApiToken;

  String get maskedToken => jiraApiToken.substring(
        max(jiraApiToken.length - 5, 0),
        jiraApiToken.length,
      );

  Future<void> toEnv() async {
    await File('${p.current}/.env').writeAsString(
        'ATLASSIAN_USER=$jiraUser\nATLASSIAN_API_TOKEN=$jiraApiToken');
  }

  static Config? fromEnv() {
    try {
      final env = DotEnv(includePlatformEnvironment: true)..load();
      if (!env.isEveryDefined(['ATLASSIAN_USER', 'ATLASSIAN_API_TOKEN'])) {
        return null;
      }

      final jiraUser = env['ATLASSIAN_USER'];
      final jiraApiToken = env['ATLASSIAN_API_TOKEN'];
      return Config(
        jiraUser: jiraUser!,
        jiraApiToken: jiraApiToken!,
      );
    } catch (e) {
      return null;
    }
  }
}
