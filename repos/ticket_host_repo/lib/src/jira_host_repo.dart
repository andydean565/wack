import 'package:atlassian_apis/jira_platform.dart';
import 'package:ticket_host_repo/src/models/jira_ticket.dart';
import 'package:ticket_host_repo/src/models/ticket.dart';

import 'ticket_host_repo.dart';

class JiraHostRepo extends TicketHostRepo {
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
  Future<Ticket> getTickets(List<String> keys) {
    var jira = _createClient();

    // TODO: implement getTickets
    throw UnimplementedError();
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
}
