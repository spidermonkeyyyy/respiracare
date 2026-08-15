import 'package:flutter/material.dart';

/// RespiraCare divider component with semantic outline color.
class RespiDivider extends StatelessWidget {
  const RespiDivider({
    super.key,
    this.height = 1.0,
    this.thickness = 1.0,
    this.indent,
    this.endIndent,
    this.color,
  });

  final double height;
  final double thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Divider(
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color ?? cs.outlineVariant,
    );
  }
}
