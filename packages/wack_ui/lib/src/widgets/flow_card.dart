import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class FlowCard extends StatelessWidget {
  final List<String> flow;
  final String branch;
  const FlowCard({super.key, required this.flow, required this.branch});

  @override
  Widget build(BuildContext context) {
    final branches = flow.where((element) => element != 'null');
    return Row(
      children: [
        if (!branches.contains(branch)) Text(branch),
        for (var f in branches) ...[
          Text(
            f,
            style: TextStyle(
              fontWeight: f == branch ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
          if (branches.last != f) Text('=>'),
        ],
      ],
    );
  }
}
