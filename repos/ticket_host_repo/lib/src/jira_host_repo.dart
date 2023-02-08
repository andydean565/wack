import 'dart:ffi';

import 'package:atlassian_apis/jira_platform.dart';
import 'package:ticket_host_repo/src/models/jira_ticket.dart';
import 'package:ticket_host_repo/src/models/ticket.dart';

import 'ticket_host_repo.dart';

class JiraHostRepo extends TicketHostRepo {
  final RegExp _ticketKeyRegex = RegExp(
    '((?!([A-Za-z0-9a-z]{1,10})-?\$)[A-Za-z]{1}[A-Za-z0-9]+-[1-9][0-9]*)',
  );

  final String user;
  final String token;
  JiraHostRepo({required this.user, required this.token});

  JiraPlatformApi _createClient() {
    final client = ApiClient.basicAuthentication(
      Uri.https('wisetribe.atlassian.net', ''),
      user: user,
      apiToken: token,
    );
    return JiraPlatformApi(client);
  }

  @override
  Future<Ticket> getTicket(String key) async {
    var jira = _createClient();
    var result = await jira.issues.getIssue(issueIdOrKey: key);
    var ticket = JiraTicket.fromDynamic(result);
    return ticket;
  }

  @override
  Future<List<Ticket>> getTickets(List<String> keys) async {
    var jira = _createClient();
    var query = 'key in (${keys.join(',')}) order by created DESC';
    var result = await jira.issueSearch.searchForIssuesUsingJqlPost(
      body: SearchRequestBean(
        startAt: 0,
        maxResults: 100,
        jql: query,
      ),
    );
    return result.issues.map(JiraTicket.fromDynamic).toList();
  }

  @override
  Future<List<Ticket>> searchTickets(
    List<String>? status,
    String? project, {
    bool me = false,
    int skip = 0,
    int maxResults = 10,
  }) async {
    var jira = _createClient();

    var statuses = status
        ?.map((e) {
          if (e.contains(' ')) {
            return '"$e"';
          }
          return '$e';
        })
        .toList()
        .join(',');

    var statements = [
      if (me) 'assignee in (currentUser())',
      if (statuses != null) 'status IN ($statuses)',
      if (project != null) 'project = $project'
    ];

    print(statements);

    var query = statements.join(' AND ');
    query = '${query} order by created DESC';

    var result = await jira.issueSearch.searchForIssuesUsingJqlPost(
      body: SearchRequestBean(
        startAt: skip,
        maxResults: maxResults,
        jql: query,
      ),
    );
    return result.issues.map(JiraTicket.fromDynamic).toList();
  }

  @override
  bool ticketKeyValidate(String key) {
    return _ticketKeyRegex.hasMatch(key);
  }

  @override
  List<String> findKey(String value) => _ticketKeyRegex
      .allMatches(value)
      .toList()
      .map(
        (e) => value.substring(e.start, e.end),
      )
      .toList();
}
