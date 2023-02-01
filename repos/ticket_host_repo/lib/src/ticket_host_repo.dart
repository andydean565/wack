import 'dart:ffi';

import 'package:ticket_host_repo/src/models/ticket.dart';

export 'jira_host_repo.dart';

abstract class TicketHostRepo {
  Future<Ticket> getTicket(String key);

  bool ticketKeyValidate(String key);

  Future<Ticket> getTickets(List<String> keys);

  Future<List<Ticket>> searchTickets(
    List<String>? status,
    String? project, {
    bool me = false,
    int skip = 0,
    int maxResults = 10,
  });
}
