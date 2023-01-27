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

  String get branch => '$key-$parsedTitle';
  String get parsedTitle => title.replaceAll(' ', '_').toLowerCase();

  static Ticket fromJira(IssueBean issue) {
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
