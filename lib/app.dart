import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:useit/app_state/localization.dart';

import 'config/core_config.dart';

/// Core application widget with integrated configuration
/// Replaces MaterialApp with proper configuration management
class CoreApp extends StatefulWidget {
  const CoreApp({
    super.key,
    required this.config,
    required this.appRouter,
    this.title = '',
    this.theme,
    this.darkTheme,
    this.themeMode,
    this.locale,
    this.supportedLocales,
    this.localizationsDelegates,
    this.localeResolutionCallback,
    this.localeListResolutionCallback,
    this.debugShowCheckedModeBanner = false,
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.builder,
    this.onGenerateTitle,
    this.color,
    this.scaffoldMessengerKey,
    this.restorationScopeId,
    this.scrollBehavior,
    this.shortcuts,
    this.actions,
    this.themeAnimationDuration,
    this.themeAnimationCurve,
    this.highContrastTheme,
    this.highContrastDarkTheme,
  });

  final CoreConfig config;
  final GoRouter appRouter;
  final String title;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;
  final Locale? locale;
  final Iterable<Locale>? supportedLocales;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final LocaleResolutionCallback? localeResolutionCallback;
  final LocaleListResolutionCallback? localeListResolutionCallback;
  final bool debugShowCheckedModeBanner;
  final bool debugShowMaterialGrid;
  final bool showPerformanceOverlay;
  final bool checkerboardRasterCacheImages;
  final bool checkerboardOffscreenLayers;
  final bool showSemanticsDebugger;
  final TransitionBuilder? builder;
  final GenerateAppTitle? onGenerateTitle;
  final Color? color;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final String? restorationScopeId;
  final ScrollBehavior? scrollBehavior;
  final Map<ShortcutActivator, Intent>? shortcuts;
  final Map<Type, Action<Intent>>? actions;
  final Duration? themeAnimationDuration;
  final Curve? themeAnimationCurve;
  final ThemeData? highContrastTheme;
  final ThemeData? highContrastDarkTheme;

  @override
  State<CoreApp> createState() => _CoreAppState();
}

class _CoreAppState extends State<CoreApp> {
  @override
  void initState() {
    super.initState();
    // Initialize CoreConfigManager with provided config
    if (!CoreConfigManager.isInitialized) {
      CoreConfigManager.initialize(widget.config);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Basic config
      title: widget.title,
      onGenerateTitle: widget.onGenerateTitle,
      color: widget.color,

      // Theme
      theme: widget.theme,
      darkTheme: widget.darkTheme,
      themeMode: widget.themeMode,
      themeAnimationDuration:
      widget.themeAnimationDuration ?? const Duration(milliseconds: 200),
      themeAnimationCurve: widget.themeAnimationCurve ?? Curves.linear,
      highContrastTheme: widget.highContrastTheme,
      highContrastDarkTheme: widget.highContrastDarkTheme,

      // Localization
      locale: widget.locale,
      supportedLocales: widget.supportedLocales ?? Localization.all,
      localizationsDelegates: [
        ...?widget.localizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: widget.localeResolutionCallback,
      localeListResolutionCallback: widget.localeListResolutionCallback,

      // Router
      routeInformationParser: widget.appRouter.routeInformationParser,
      routeInformationProvider: widget.appRouter.routeInformationProvider,
      routerDelegate: widget.appRouter.routerDelegate,

      // Debug flags
      debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
      debugShowMaterialGrid: widget.debugShowMaterialGrid,
      showPerformanceOverlay: widget.showPerformanceOverlay,
      checkerboardRasterCacheImages: widget.checkerboardRasterCacheImages,
      checkerboardOffscreenLayers: widget.checkerboardOffscreenLayers,
      showSemanticsDebugger: widget.showSemanticsDebugger,

      // Other
      builder: widget.builder,
      scaffoldMessengerKey: widget.scaffoldMessengerKey,
      restorationScopeId: widget.restorationScopeId,
      scrollBehavior: widget.scrollBehavior,
      shortcuts: widget.shortcuts,
      actions: widget.actions,
    );
  }

  @override
  void dispose() {
    // Don't reset config here as it might be used by other parts
    super.dispose();
  }
}