import 'package:flutter/material.dart';

class DiagnosisChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const DiagnosisChip({
    super.key,
    required this.label,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      onPressed: onTap,
      onDeleted: onDelete,
    );
  }
}
