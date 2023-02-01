import 'package:atlassian_apis/jira_platform.dart';
import 'package:ticket_host_repo/src/models/ticket.dart';

class JiraTicket extends Ticket {
  JiraTicket({
    required super.key,
    required super.title,
    required super.status,
    super.assignee,
  });

  static Ticket fromDynamic(IssueBean data) => JiraTicket(
        key: data.key!,
        status: data.fields!['status']['name'] as String,
        title: data.fields!['summary'] as String,
        assignee: data.fields?['assignee']?['displayName'] as String?,
      );
}
