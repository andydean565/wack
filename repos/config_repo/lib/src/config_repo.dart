import 'dart:io';
import 'dart:math';

import 'package:dotenv/dotenv.dart';
import 'package:path/path.dart' as p;

class ConfigRepo {
  ConfigRepo({
    required this.gitRepo,
    required this.ticketRepo,
    required this.gitlabToken,
    required this.jiraUser,
    required this.jiraApiToken,
  });

  final String gitRepo;
  final String ticketRepo;

  final String gitlabToken;

  final String jiraUser;
  final String jiraApiToken;

  String get maskedJiraToken => jiraApiToken.substring(
        max(jiraApiToken.length - 5, 0),
        jiraApiToken.length,
      );

  String get maskedGitlabToken => gitlabToken.substring(
        max(gitlabToken.length - 5, 0),
        gitlabToken.length,
      );

  Map<String, String> toJson({bool hide = true}) => {
        'TICKET_REPO': ticketRepo,
        'GIT_REPO': gitRepo,
        'JIRA_USER': jiraUser,
        'JIRA_API_TOKEN': hide ? '********$maskedJiraToken' : jiraApiToken,
        'GITLAB_API_TOKEN': hide ? '********$maskedGitlabToken' : gitlabToken,
      };

  Future<void> toEnv() async {
    // ignore: lines_longer_than_80_chars
    await File('${p.current}/.env').writeAsString(
      'TICKET_REPO=$ticketRepo\nGIT_REPO=$gitRepo\nGITLAB_API_TOKEN=$gitlabToken\nJIRA_USER=$jiraUser\nJIRA_API_TOKEN=$jiraApiToken',
    );
  }

  static ConfigRepo? fromEnv({String? file}) {
    try {
      final env = DotEnv(includePlatformEnvironment: true)
        ..load(file != null ? [file] : ['.env']);
      if (!env.isEveryDefined([
        'TICKET_REPO',
        'GIT_REPO',
        'GITLAB_API_TOKEN',
        'JIRA_USER',
        'JIRA_API_TOKEN',
        'BRANCH_FLOW',
        'TICKET_FLOW',
      ])) {
        return null;
      }
      return ConfigRepo(
        ticketRepo: env['TICKET_REPO']!,
        gitRepo: env['GIT_REPO']!,
        gitlabToken: env['GITLAB_API_TOKEN']!,
        jiraUser: env['JIRA_USER']!,
        jiraApiToken: env['JIRA_API_TOKEN']!,
      );
    } catch (e) {
      print(e);
      return null;
    }
  }
}
