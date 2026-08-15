import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Handles back button behavior for the entire app.
///
/// - On patient/nurse shells: first back tap shows confirmation snackbar
/// - Second back tap within 2 seconds exits the app
class BackButtonHandler extends StatefulWidget {
  const BackButtonHandler({super.key, required this.child});

  final Widget child;

  @override
  State<BackButtonHandler> createState() => _BackButtonHandlerState();
}

class _BackButtonHandlerState extends State<BackButtonHandler> {
  DateTime? _lastBackPress;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress(context);
      },
      child: widget.child,
    );
  }

  void _handleBackPress(BuildContext context) {
    final now = DateTime.now();
    if (_lastBackPress != null && now.difference(_lastBackPress!) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
    } else {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appuyez à nouveau pour quitter'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}