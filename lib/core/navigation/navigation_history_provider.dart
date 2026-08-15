import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the current and previous routes for navigation-aware behavior.
class NavigationHistory {
  const NavigationHistory({
    this.currentRoute,
    this.previousRoute,
    this.routeStack = const [],
  });

  final String? currentRoute;
  final String? previousRoute;
  final List<String> routeStack;

  bool get canGoBack => routeStack.length > 1;

  NavigationHistory copyWith({
    String? currentRoute,
    String? previousRoute,
    List<String>? routeStack,
  }) {
    return NavigationHistory(
      currentRoute: currentRoute ?? this.currentRoute,
      previousRoute: previousRoute ?? this.previousRoute,
      routeStack: routeStack ?? this.routeStack,
    );
  }
}

class NavigationHistoryNotifier extends StateNotifier<NavigationHistory> {
  NavigationHistoryNotifier() : super(const NavigationHistory());

  void push(String route) {
    state = state.copyWith(
      currentRoute: route,
      previousRoute: state.currentRoute,
      routeStack: [...state.routeStack, route],
    );
  }

  void pop() {
    if (state.routeStack.isEmpty) return;
    final newStack = List<String>.from(state.routeStack)..removeLast();
    state = state.copyWith(
      currentRoute: newStack.isNotEmpty ? newStack.last : null,
      previousRoute: state.currentRoute,
      routeStack: newStack,
    );
  }

  void replace(String route) {
    final newStack = List<String>.from(state.routeStack);
    if (newStack.isNotEmpty) newStack.removeLast();
    newStack.add(route);
    state = state.copyWith(
      currentRoute: route,
      previousRoute: state.currentRoute,
      routeStack: newStack,
    );
  }

  void clear() {
    state = const NavigationHistory();
  }
}

/// Provider for navigation history state.
final navigationHistoryProvider = StateNotifierProvider<NavigationHistoryNotifier, NavigationHistory>(
  (ref) => NavigationHistoryNotifier(),
);