import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wack_ui/src/widgets/ticket_info.dart';

import '../stores/stores.dart';
import '../widgets/widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DashboardAppBar(),
      bottomNavigationBar: const BottomNav(),
      extendBody: true,
      body: Column(
        children: [
          if (Provider.of<DashboardStore>(context).branch != null)
            if (Provider.of<DashboardStore>(context).ticket != null)
              TicketInfo(ticket: Provider.of<DashboardStore>(context).ticket!),
        ],
      ),
    );
  }
}
