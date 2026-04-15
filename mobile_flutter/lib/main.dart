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
  final initialActivationLaunch = await _resolveInitialActivationLaunch();

  runApp(
    MyApp(
      isLoggedIn: hasResidentSession,
      initialActivationLaunch: initialActivationLaunch,
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final _ActivationLaunch initialActivationLaunch;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.initialActivationLaunch,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  late final _ActivationLaunch _initialActivationLaunch =
      widget.initialActivationLaunch;

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
      final launch = _activationLaunchFromUri(uri);
      if (launch == null || !launch.shouldOpen) return;

      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/activate',
        (route) => false,
        arguments: {'token': launch.token},
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
      initialRoute: _initialActivationLaunch.shouldOpen
          ? '/activate'
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
                _initialActivationLaunch.token;
            return fadeSlideRoute(ActivateAccountScreen(token: token));
          default:
            final fallback = _initialActivationLaunch.shouldOpen
                ? ActivateAccountScreen(token: _initialActivationLaunch.token)
                : widget.isLoggedIn
                    ? const MainNavigationScreen()
                    : const WelcomeScreen();
            return fadeSlideRoute(fallback);
        }
      },
    );
  }
}

class _ActivationLaunch {
  final bool shouldOpen;
  final String? token;

  const _ActivationLaunch({
    this.shouldOpen = false,
    this.token,
  });
}

Future<_ActivationLaunch> _resolveInitialActivationLaunch() async {
  final fromBase = _resolveActivationLaunchFromBaseUri();
  if (fromBase.shouldOpen) {
    return fromBase;
  }

  if (!kIsWeb) {
    try {
      final appLinks = AppLinks();
      final initialUri = await appLinks.getInitialLink();
      final fromMobileLink = _activationLaunchFromUri(initialUri);
      if (fromMobileLink != null) {
        return fromMobileLink;
      }
    } catch (_) {
      // Ignore unavailable or malformed initial links and continue normally.
    }
  }

  return const _ActivationLaunch();
}

_ActivationLaunch _resolveActivationLaunchFromBaseUri() {
  final direct = _activationLaunchFromUri(Uri.base);
  if (direct != null) return direct;

  final fragment = Uri.base.fragment.trim();
  if (fragment.isNotEmpty) {
    final normalizedFragment = fragment.startsWith('/')
        ? fragment
        : '/$fragment';
    final fragmentUri = Uri.tryParse(normalizedFragment);
    final fragmentLaunch = _activationLaunchFromUri(fragmentUri);
    if (fragmentLaunch != null) return fragmentLaunch;
  }

  return const _ActivationLaunch();
}

_ActivationLaunch? _activationLaunchFromUri(Uri? uri) {
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
  final hasToken = token != null && token.isNotEmpty;

  if (!isActivationPath && !hasToken) {
    return null;
  }

  return _ActivationLaunch(
    shouldOpen: true,
    token: hasToken ? token : null,
  );
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
