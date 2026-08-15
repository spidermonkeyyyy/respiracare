import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Extension on [BuildContext] providing typed navigation helpers.
extension GoRouterX on BuildContext {
  /// Navigate to a named route, passing optional parameters.
  void goToRoute(
    String routeName, {
    Map<String, String>? params,
    Map<String, String>? queryParams,
    Object? extra,
  }) {
    goNamed(
      routeName,
      pathParameters: params ?? const {},
      queryParameters: queryParams ?? const {},
      extra: extra,
    );
  }

  /// Push a new screen on top of the current one.
  void pushTo(String routeName, {Object? extra}) {
    push(routeName, extra: extra);
  }

  /// Pop the current route.
  void goBack({Object? result}) {
    if (canPop()) {
      pop(result);
    }
  }

  /// Pop to the first route.
  void popToRoot() {
    while (canPop()) {
      pop();
    }
  }
}