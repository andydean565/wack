import 'package:flutter/material.dart';
import 'package:ticket_host_repo/ticket_host_repo.dart';

class TicketInfo extends StatelessWidget {
  final Ticket ticket;
  const TicketInfo({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(
            'key: ${ticket.key}',
          ),
          Text(
            'status: ${ticket.status}',
          ),
          Text(
            'title: ${ticket.title}',
          ),
        ],
      ),
    );
  }
}
