import 'package:flutter/material.dart';

/// RespiraCare Animation Durations
abstract class AppAnimationDuration {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

/// Reusable Fade Animation Widget
class AppFadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const AppFadeAnimation({
    super.key,
    required this.child,
    this.duration = AppAnimationDuration.normal,
    this.delay = Duration.zero,
    this.curve = Curves.easeInOut,
  });

  @override
  State<AppFadeAnimation> createState() => _AppFadeAnimationState();
}

class _AppFadeAnimationState extends State<AppFadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: widget.child,
    );
  }
}

/// Reusable Slide Animation Widget
enum SlideDirection { up, down, left, right }

class AppSlideAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final SlideDirection direction;
  final double offset;

  const AppSlideAnimation({
    super.key,
    required this.child,
    this.duration = AppAnimationDuration.normal,
    this.delay = Duration.zero,
    this.direction = SlideDirection.up,
    this.offset = 24.0,
  });

  @override
  State<AppSlideAnimation> createState() => _AppSlideAnimationState();
}

class _AppSlideAnimationState extends State<AppSlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    Offset beginOffset;
    switch (widget.direction) {
      case SlideDirection.up:
        beginOffset = Offset(0, widget.offset / 100);
        break;
      case SlideDirection.down:
        beginOffset = Offset(0, -widget.offset / 100);
        break;
      case SlideDirection.left:
        beginOffset = Offset(widget.offset / 100, 0);
        break;
      case SlideDirection.right:
        beginOffset = Offset(-widget.offset / 100, 0);
        break;
    }

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}

/// Reusable Scale Animation Widget
class AppScaleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double initialScale;

  const AppScaleAnimation({
    super.key,
    required this.child,
    this.duration = AppAnimationDuration.fast,
    this.delay = Duration.zero,
    this.initialScale = 0.9,
  });

  @override
  State<AppScaleAnimation> createState() => _AppScaleAnimationState();
}

class _AppScaleAnimationState extends State<AppScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.initialScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}
