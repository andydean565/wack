import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wack_ui/src/stores/stores.dart';
import 'package:wack_ui/src/widgets/widgets.dart';

class DashboardAppBar extends StatelessWidget with PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Directory: '),
                      Text(Provider.of<AppStore>(context).directory),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Branch: '),
                      Text(
                          Provider.of<DashboardStore>(context).branch ?? 'N/A'),
                    ],
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () =>
                  Provider.of<DashboardStore>(context, listen: false).init(),
              child: const Text('reload'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(150);
}
