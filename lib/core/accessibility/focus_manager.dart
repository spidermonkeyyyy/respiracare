import 'package:flutter/material.dart';

/// Centralized focus management for RespiraCare.
///
/// Handles:
/// - Moving focus between form fields
/// - Trapping focus in modals
/// - Restoring focus after dialogs close
/// - Initial focus on screen open
class RespiFocusManager {
  RespiFocusManager._();

  /// Moves focus to the next field in a form.
  static void next(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Moves focus to the previous field in a form.
  static void previous(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Requests focus on a specific node.
  static void request(FocusNode node) {
    node.requestFocus();
  }

  /// Unfocuses all fields (dismisses keyboard).
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Creates a focus traversal group for a form.
  static Widget formTraversal({
    required List<Widget> children,
    TraversalDirection direction = TraversalDirection.down,
  }) {
    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// A widget that traps focus within its subtree (for modals/dialogs).
class FocusTrap extends StatelessWidget {
  const FocusTrap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      canRequestFocus: true,
      child: child,
    );
  }
}

/// Restores focus to a previously focused node when disposed.
class FocusRestorer extends StatefulWidget {
  const FocusRestorer({super.key, required this.child});

  final Widget child;

  @override
  State<FocusRestorer> createState() => _FocusRestorerState();
}

class _FocusRestorerState extends State<FocusRestorer> {
  FocusNode? _previousFocus;

  @override
  void initState() {
    super.initState();
    _previousFocus = FocusManager.instance.primaryFocus;
  }

  @override
  void dispose() {
    _previousFocus?.requestFocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// A focusable action that responds to keyboard shortcuts.
class KeyboardAction extends StatelessWidget {
  const KeyboardAction({
    super.key,
    required this.child,
    required this.shortcut,
    required this.onInvoke,
  });

  final Widget child;
  final SingleActivator shortcut;
  final VoidCallback onInvoke;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {shortcut: onInvoke},
      child: Focus(
        canRequestFocus: false,
        descendantsAreFocusable: true,
        child: child,
      ),
    );
  }
}
