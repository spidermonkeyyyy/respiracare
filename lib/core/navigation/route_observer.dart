import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'navigation_history_provider.dart';

/// Observes route changes and updates navigation history.
class RespiRouteObserver extends NavigatorObserver {
  RespiRouteObserver(this.ref);

  final Ref ref;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      final routeName = route.settings.name!;
      // Defer to avoid modifying a provider during widget tree building.
      Future.microtask(
        () => ref.read(navigationHistoryProvider.notifier).push(routeName),
      );
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    Future.microtask(
      () => ref.read(navigationHistoryProvider.notifier).pop(),
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name != null) {
      final routeName = newRoute!.settings.name!;
      Future.microtask(
        () => ref.read(navigationHistoryProvider.notifier).replace(routeName),
      );
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (route.settings.name != null) {
      Future.microtask(
        () => ref.read(navigationHistoryProvider.notifier).pop(),
      );
    }
  }
}

/// Provider for the route observer.
final routeObserverProvider = Provider<RespiRouteObserver>((ref) {
  return RespiRouteObserver(ref);
});
