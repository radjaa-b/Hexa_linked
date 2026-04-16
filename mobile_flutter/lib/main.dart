import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:resident_app/core/navigation/app_route.dart';
import 'package:resident_app/core/navigation/main_navigation_screen.dart';
import 'package:resident_app/features/auth/screens/activate_account_screen.dart';
import 'package:resident_app/features/auth/screens/login_screen.dart';
import 'package:resident_app/features/auth/screens/welcome_screen.dart';
import 'package:resident_app/features/auth/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final hasResidentSession = await AuthService.isLoggedIn();
  final initialAppLaunch = await _resolveInitialAppLaunch();

  runApp(
    MyApp(isLoggedIn: hasResidentSession, initialAppLaunch: initialAppLaunch),
  );
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final _AppLaunch initialAppLaunch;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.initialAppLaunch,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  late final _AppLaunch _initialAppLaunch = widget.initialAppLaunch;

  @override
  void initState() {
    super.initState();
    _listenForIncomingLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _listenForIncomingLinks() {
    if (kIsWeb) return;

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      final launch = _appLaunchFromUri(uri);
      if (launch == null || !launch.shouldOpen) return;

      final arguments = launch.routeName == '/activate'
          ? {'token': launch.token}
          : null;

      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        launch.routeName,
        (route) => false,
        arguments: arguments,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Residents App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      initialRoute: _initialAppLaunch.shouldOpen
          ? _initialAppLaunch.routeName
          : widget.isLoggedIn
          ? '/home'
          : '/welcome',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return fadeSlideRoute(const MainNavigationScreen());
          case '/welcome':
            return fadeSlideRoute(const WelcomeScreen());
          case '/login':
            return fadeSlideRoute(const LoginScreen());
          case '/activate':
            final token =
                _extractActivationToken(settings.arguments) ??
                _initialAppLaunch.token;
            return fadeSlideRoute(ActivateAccountScreen(token: token));
          default:
            final fallback = _initialAppLaunch.shouldOpen
                ? (_initialAppLaunch.routeName == '/activate'
                      ? ActivateAccountScreen(token: _initialAppLaunch.token)
                      : const LoginScreen())
                : widget.isLoggedIn
                ? const MainNavigationScreen()
                : const WelcomeScreen();
            return fadeSlideRoute(fallback);
        }
      },
    );
  }
}

class _AppLaunch {
  final bool shouldOpen;
  final String routeName;
  final String? token;

  const _AppLaunch({
    this.shouldOpen = false,
    this.routeName = '/welcome',
    this.token,
  });
}

Future<_AppLaunch> _resolveInitialAppLaunch() async {
  final fromBase = _resolveAppLaunchFromBaseUri();
  if (fromBase.shouldOpen) {
    return fromBase;
  }

  if (!kIsWeb) {
    try {
      final appLinks = AppLinks();
      final initialUri = await appLinks.getInitialLink();
      final fromMobileLink = _appLaunchFromUri(initialUri);
      if (fromMobileLink != null) {
        return fromMobileLink;
      }
    } catch (_) {
      // Ignore unavailable or malformed initial links.
    }
  }

  return const _AppLaunch();
}

_AppLaunch _resolveAppLaunchFromBaseUri() {
  final direct = _appLaunchFromUri(Uri.base);
  if (direct != null) return direct;

  final fragment = Uri.base.fragment.trim();
  if (fragment.isNotEmpty) {
    final normalizedFragment = fragment.startsWith('/')
        ? fragment
        : '/$fragment';
    final fragmentUri = Uri.tryParse(normalizedFragment);
    final fragmentLaunch = _appLaunchFromUri(fragmentUri);
    if (fragmentLaunch != null) return fragmentLaunch;
  }

  return const _AppLaunch();
}

_AppLaunch? _appLaunchFromUri(Uri? uri) {
  if (uri == null) return null;

  final token = uri.queryParameters['token']?.trim();
  final segments = uri.pathSegments
      .where((segment) => segment.isNotEmpty)
      .map((segment) => segment.toLowerCase())
      .toList();

  final host = uri.host.toLowerCase();

  final isActivationPath =
      segments.contains('activate') ||
      segments.contains('activation') ||
      host == 'activate' ||
      host == 'activation';

  final isLoginPath = segments.contains('login') || host == 'login';

  if (isLoginPath) {
    return const _AppLaunch(shouldOpen: true, routeName: '/login');
  }

  if (isActivationPath) {
    return _AppLaunch(
      shouldOpen: true,
      routeName: '/activate',
      token: (token != null && token.isNotEmpty) ? token : null,
    );
  }

  return null;
}

String? _extractActivationToken(Object? arguments) {
  if (arguments is String) {
    final token = arguments.trim();
    return token.isEmpty ? null : token;
  }

  if (arguments is Map<Object?, Object?>) {
    final token = arguments['token'];
    if (token is String) {
      final normalizedToken = token.trim();
      return normalizedToken.isEmpty ? null : normalizedToken;
    }
  }

  return null;
}
