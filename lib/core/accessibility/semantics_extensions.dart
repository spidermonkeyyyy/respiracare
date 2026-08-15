import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Extensions for adding accessibility semantics to widgets.
extension SemanticsX on Widget {
  /// Wraps this widget with a semantic button.
  Widget semanticButton({
    required String label,
    String? hint,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint,
      onTap: onTap,
      child: this,
    );
  }

  /// Wraps this widget with a semantic heading.
  Widget semanticHeading({required int level}) {
    return Semantics(
      header: true,
      child: this,
    );
  }

  /// Marks this widget as a live region that announces changes.
  Widget liveRegion({bool polite = true}) {
    return Semantics(
      liveRegion: true,
      child: this,
    );
  }

  /// Hides this widget from screen readers.
  Widget excludeSemantics() {
    return ExcludeSemantics(child: this);
  }

  /// Merges child semantics into this widget.
  Widget mergeSemantics() {
    return MergeSemantics(child: this);
  }

  /// Adds a custom accessibility action.
  Widget withAction({
    required String name,
    required VoidCallback handler,
  }) {
    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: name): handler,
      },
      child: this,
    );
  }
}

/// A widget that announces text changes to screen readers.
class ScreenReaderAnnouncement extends StatefulWidget {
  const ScreenReaderAnnouncement({
    super.key,
    required this.message,
    this.delay = Duration.zero,
  });

  final String message;
  final Duration delay;

  @override
  State<ScreenReaderAnnouncement> createState() => _ScreenReaderAnnouncementState();
}

class _ScreenReaderAnnouncementState extends State<ScreenReaderAnnouncement> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) {
        SemanticsService.sendAnnouncement(
          View.of(context),
          widget.message,
          TextDirection.ltr,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Announces a message when a condition becomes true.
class ConditionalAnnouncement extends StatelessWidget {
  const ConditionalAnnouncement({
    super.key,
    required this.condition,
    required this.message,
    this.child,
  });

  final bool condition;
  final String message;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (condition) {
      return Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScreenReaderAnnouncement(message: message),
            if (child != null) child!,
          ],
        ),
      );
    }
    return child ?? const SizedBox.shrink();
  }
}
