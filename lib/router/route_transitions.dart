import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Extension for creating different page transitions
extension PageTransitionExtension on Widget {
  /// No transition page
  NoTransitionPage noTransition({required GoRouterState state}) {
    return NoTransitionPage(
      key: state.pageKey,
      name: state.name,
      child: this,
    );
  }

  /// Default iOS-style page transition
  CupertinoPage defaultTransition({required GoRouterState state}) {
    return CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: this,
    );
  }

  /// Material page transition
  MaterialPage materialTransition({required GoRouterState state}) {
    return MaterialPage(
      key: state.pageKey,
      name: state.name,
      child: this,
    );
  }

  /// Modal bottom sheet transition
  CustomTransitionPage modalTransition({
    required GoRouterState state,
    bool opaque = false,
    Color? barrierColor,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      name: state.name,
      child: this,
      opaque: opaque,
      barrierColor: barrierColor ?? Colors.black54,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        );
      },
    );
  }

  /// Fade transition
  CustomTransitionPage fadeTransition({
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      name: state.name,
      child: this,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Slide from right transition
  CustomTransitionPage slideFromRightTransition({
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      name: state.name,
      child: this,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        );
      },
    );
  }

  /// Slide from left transition
  CustomTransitionPage slideFromLeftTransition({
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      name: state.name,
      child: this,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        );
      },
    );
  }

  /// Slide from bottom transition
  CustomTransitionPage slideFromBottomTransition({
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      name: state.name,
      child: this,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        );
      },
    );
  }

  /// Scale transition
  CustomTransitionPage scaleTransition({
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      name: state.name,
      child: this,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        );
      },
    );
  }

  /// Rotation transition
  CustomTransitionPage rotationTransition({
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      name: state.name,
      child: this,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        );
      },
    );
  }

  /// Size transition
  CustomTransitionPage sizeTransition({
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      name: state.name,
      child: this,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Align(
          alignment: Alignment.center,
          child: SizeTransition(
            sizeFactor: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Combined fade and scale transition
  CustomTransitionPage fadeScaleTransition({
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      name: state.name,
      child: this,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}