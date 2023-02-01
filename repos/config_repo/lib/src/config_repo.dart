import 'dart:io';
import 'dart:math';

import 'package:dotenv/dotenv.dart';
import 'package:path/path.dart' as p;

class ConfigRepo {
  ConfigRepo({
    required this.jiraUser,
    required this.jiraApiToken,
    required this.branchFlow,
    required this.ticketFlow,
  });

  final String jiraUser;
  final String jiraApiToken;
  final List<String> branchFlow;
  final List<String> ticketFlow;

  String get maskedToken => jiraApiToken.substring(
        max(jiraApiToken.length - 5, 0),
        jiraApiToken.length,
      );

  Map<String, String> toJson({bool hide = true}) => {
        'ATLASSIAN_USER': jiraUser,
        'ATLASSIAN_API_TOKEN': hide ? '********$maskedToken' : jiraApiToken,
        'BRANCH_FLOW': ticketFlow.join(' => '),
        'TICKET_FLOW': branchFlow.join(' => ')
      };

  Future<void> toEnv() async {
    await File('${p.current}/.env').writeAsString(
      'ATLASSIAN_USER=$jiraUser\nATLASSIAN_API_TOKEN=$jiraApiToken\nBRANCH_FLOW=${branchFlow.join(',')}\nTICKET_FLOW=${ticketFlow.join(',')}',
    );
  }

  static ConfigRepo? fromEnv() {
    try {
      final env = DotEnv(includePlatformEnvironment: true)..load();
      if (!env.isEveryDefined([
        'ATLASSIAN_USER',
        'ATLASSIAN_API_TOKEN',
        'BRANCH_FLOW',
        'TICKET_FLOW'
      ])) {
        return null;
      }
      return ConfigRepo(
        jiraUser: env['ATLASSIAN_USER']!,
        jiraApiToken: env['ATLASSIAN_API_TOKEN']!,
        branchFlow: (env['BRANCH_FLOW']!).split(','),
        ticketFlow: (env['TICKET_FLOW']!).split(','),
      );
    } catch (e) {
      print(e);
      return null;
    }
  }
}
