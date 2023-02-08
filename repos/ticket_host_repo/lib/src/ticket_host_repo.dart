import 'dart:ffi';

import 'package:ticket_host_repo/src/models/ticket.dart';

export 'jira_host_repo.dart';

abstract class TicketHostRepo {
  Future<Ticket> getTicket(String key);

  bool ticketKeyValidate(String key);

  bool containsTicket(String data, String key) {
    final ticketKeyRegex = RegExp('($key)-*');
    return ticketKeyRegex.hasMatch(data.toUpperCase());
  }

  List<String> findKey(String key);

  Future<List<Ticket>> getTickets(List<String> keys);

  Future<List<Ticket>> searchTickets(
    List<String>? status,
    String? project, {
    bool me = false,
    int skip = 0,
    int maxResults = 10,
  });
}
