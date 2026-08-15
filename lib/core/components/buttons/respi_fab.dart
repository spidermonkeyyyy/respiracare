import 'package:flutter/material.dart';
import '../../theme/tokens/respi_shapes.dart';

/// Primary floating action button with emergency variant.
class RespiFAB extends StatelessWidget {
  const RespiFAB({
    super.key,
    required this.icon,
    this.label,
    required this.onPressed,
    this.isEmergency = false,
  });

  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  final bool isEmergency;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isEmergency) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.emergency, size: 24),
        label: Text(label ?? 'SOS', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(RespiShapes.full)),
      );
    }

    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        elevation: 2,
        icon: Icon(icon),
        label: Text(label!),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(RespiShapes.full)),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: cs.primaryContainer,
      foregroundColor: cs.onPrimaryContainer,
      elevation: 2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(RespiShapes.full)),
      child: Icon(icon),
    );
  }
}
