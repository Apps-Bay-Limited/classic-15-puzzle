import 'package:classic_15_puzzle/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Paired label/value display for dialog result summaries.
class ResultStatItem extends StatelessWidget {
  final String label;
  final String value;

  const ResultStatItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Column(
        children: [
          Text(label, style: AppTypography.statLabel(context)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: AppTypography.statValueLarge(context)),
          ),
        ],
      ),
    );
  }
}
