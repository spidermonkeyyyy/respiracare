import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/components/buttons/respi_button.dart';
import '../../../core/navigation/route_names.dart';
import '../providers/auth_provider.dart';

/// Shows a graceful re-authentication modal when session expires.
class SessionExpiryHandler extends ConsumerStatefulWidget {
  const SessionExpiryHandler({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SessionExpiryHandler> createState() =>
      _SessionExpiryHandlerState();
}

class _SessionExpiryHandlerState extends ConsumerState<SessionExpiryHandler> {
  bool _showingDialog = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.status == AuthStatus.error &&
          next.errorMessage != null &&
          !_showingDialog) {
        // Check if error looks like a session expired / JWT error
        final msg = next.errorMessage!.toLowerCase();
        if (msg.contains('expired') ||
            msg.contains('jwt') ||
            msg.contains('token') ||
            msg.contains('session')) {
          _showReAuthDialog(context);
        }
      }
    });

    return widget.child;
  }

  void _showReAuthDialog(BuildContext context) {
    _showingDialog = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          icon: const Icon(Icons.timer_off_outlined, size: 48),
          title: const Text('Session Expired'),
          content: const Text(
            'For your security, your session has expired. '
            'Please sign in again to continue.',
          ),
          actions: [
            RespiButton(
              label: 'Sign In Again',
              onPressed: () {
                _showingDialog = false;
                Navigator.of(context).pop();
                context.go(RouteNames.signIn);
              },
            ),
          ],
        ),
      ),
    );
  }
}
