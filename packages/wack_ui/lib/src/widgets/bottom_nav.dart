import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wack_ui/src/stores/stores.dart';
import 'package:wack_ui/src/widgets/widgets.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                BranchSelector(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
