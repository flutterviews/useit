part of 'extensions.dart';

/// Extension for safe navigation operations
extension NavigationExtension on BuildContext {
  /// Check if context is mounted
  bool get isMounted {
    try {
      return mounted;
    } catch (e) {
      return false;
    }
  }

  /// Check if can pop
  bool canPop() {
    if (!isMounted) return false;

    try {
      return GoRouter.of(this).canPop();
    } catch (_) {
      return Navigator.canPop(this);
    }
  }

  /// Safe pop with result
  /// Automatically handles both GoRouter and Navigator
  void popSafe<T extends Object?>([T? result]) {
    if (!isMounted) {
      LogService.w('Attempted to pop on unmounted context');
      return;
    }

    try {
      if (canPop()) {
        GoRouter.of(this).pop(result);
      } else {
        LogService.w('Cannot pop, no routes to pop');
      }
    } catch (e) {
      LogService.w('GoRouter pop failed, trying Navigator: $e');
      try {
        if (Navigator.canPop(this)) {
          Navigator.pop<T>(this, result);
        }
      } catch (navError) {
        LogService.e('Navigator pop also failed: $navError');
      }
    }
  }

  /// Pop until named route
  void popUntilNamed<T extends Object?>(String routeName, [T? result]) {
    if (!isMounted) {
      LogService.w('Attempted to pop until named on unmounted context');
      return;
    }

    try {
      final router = GoRouter.of(this);
      final routes = [...router.routerDelegate.currentConfiguration.routes];

      for (int i = routes.length - 1; i >= 0; i--) {
        final route = routes[i];
        if (route is GoRoute && route.name == routeName) {
          break;
        }
        if (router.canPop()) {
          router.pop(result);
        }
      }
    } catch (e) {
      LogService.e('Pop until named failed: $e');
    }
  }

  /// Navigate to named route
  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    if (!isMounted) {
      LogService.w('Attempted to push on unmounted context');
      return Future.value(null);
    }

    try {
      return GoRouter.of(this).pushNamed<T>(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
      );
    } catch (e) {
      LogService.e('Push named failed: $e');
      return Future.value(null);
    }
  }

  /// Go to named route (replace current route)
  void goNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    if (!isMounted) {
      LogService.w('Attempted to go on unmounted context');
      return;
    }

    try {
      GoRouter.of(this).goNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
      );
    } catch (e) {
      LogService.e('Go named failed: $e');
    }
  }

  /// Replace current route with named route
  Future<T?> replaceNamed<T extends Object?>(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    if (!isMounted) {
      LogService.w('Attempted to replace on unmounted context');
      return Future.value(null);
    }

    try {
      return GoRouter.of(this).replaceNamed<T>(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
      );
    } catch (e) {
      LogService.e('Replace named failed: $e');
      return Future.value(null);
    }
  }

  /// Pop all routes until root
  void popUntilRoot() {
    if (!isMounted) {
      LogService.w('Attempted to pop until root on unmounted context');
      return;
    }

    try {
      while (canPop()) {
        GoRouter.of(this).pop();
      }
    } catch (e) {
      LogService.e('Pop until root failed: $e');
    }
  }
}

/// Extension for GoRouter utilities
extension GoRouterExtension on GoRouter {
  /// Pop until named route
  void popUntilNamed<T extends Object?>(String routeName, [T? result]) {
    final routeStacks = [...routerDelegate.currentConfiguration.routes];

    for (int i = routeStacks.length - 1; i >= 0; i--) {
      final route = routeStacks[i];

      if (route is GoRoute && route.name == routeName) {
        break;
      }

      if (i != 0 && routeStacks[i - 1] is ShellRoute) {
        final matchList = routerDelegate.currentConfiguration;
        restore(matchList.remove(matchList.matches.last));
      } else {
        pop(result);
      }
    }
  }

  /// Get current route name
  String? get currentRouteName {
    try {
      final route = routerDelegate.currentConfiguration.last.route;
      return route.name;
    } catch (e) {
      LogService.e('Failed to get current route name: $e');
      return null;
    }
  }

  /// Get current location
  String get currentLocation {
    try {
      return routeInformationProvider.value.uri.toString();
    } catch (e) {
      LogService.e('Failed to get current location: $e');
      return '/';
    }
  }

  /// Check if route is current
  bool isCurrentRoute(String routeName) {
    return currentRouteName == routeName;
  }
}
