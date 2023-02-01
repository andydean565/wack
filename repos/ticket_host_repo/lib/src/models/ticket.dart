// ignore_for_file: avoid_dynamic_calls

import 'package:atlassian_apis/jira_platform.dart';
import 'package:ticket_host_repo/src/models/jira_ticket.dart';

abstract class Ticket {
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

  static Ticket fromDynamic(dynamic data) {
    switch (data.runtimeType) {
      case IssueBean:
        return JiraTicket.fromDynamic(data);
      default:
        throw Exception('unkown ticket type: ${data.runtimeType}');
    }
  }

  @override
  String toString() {
    return '''[$key] $title\nstatus: $status | assigned: $assignee (reporting to $reporter) | points: $storyPoints''';
  }
}
