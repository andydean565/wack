// ignore_for_file: avoid_dynamic_calls

import 'package:atlassian_apis/jira_platform.dart';

class Ticket {
  Ticket({
    required this.key,
    required this.title,
    required this.status,
    this.assignee,
    this.storyPoints,
    this.reporter,
  });

  final String key;
  final String title;
  final String status;
  final String? assignee;
  final String? storyPoints;
  final String? reporter;

  static Ticket fromJira(IssueBean issue) {
    // print(issue.fields?['assignee']);
    // for (var i = 0; i < issue.fields!.entries.length; i++) {
    //   print(issue.fields!.entries.toList()[i].key);
    //   print(issue.fields!.entries.toList()[i].value);
    // }
    return Ticket(
      key: issue.key!,
      status: issue.fields!['status']['name'] as String,
      title: issue.fields!['summary'] as String,
      assignee: (issue.fields?['assignee']?['displayName'] as String?),
    );
  }

  @override
  String toString() {
    return '''[$key] $title\nstatus: $status | assigned: $assignee (reporting to $reporter) | points: $storyPoints''';
  }
}
