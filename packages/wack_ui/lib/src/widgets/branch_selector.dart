import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wack_ui/src/stores/stores.dart';

class BranchSelector extends StatelessWidget {
  const BranchSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isDense: true,
        value: Provider.of<DashboardStore>(context).branch,
        items: Provider.of<DashboardStore>(context)
                .branches
                ?.map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ))
                .toList() ??
            [],
        onChanged: (val) {
          if (val == null) {
            return;
          }
          Provider.of<DashboardStore>(context, listen: false).updateBranch(val);
        },
      ),
    );
  }
}
