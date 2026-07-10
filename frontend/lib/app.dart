import 'package:flutter/material.dart';

import 'navigation/role_navigation.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

class PanchayatApp extends StatefulWidget {
  const PanchayatApp({super.key});

  @override
  State<PanchayatApp> createState() => _PanchayatAppState();
}

class _PanchayatAppState extends State<PanchayatApp> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();

  bool _splashCompleted = false;
  bool _returningFromBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _returningFromBackground = true;
      return;
    }

    if (state == AppLifecycleState.resumed &&
        _splashCompleted &&
        _returningFromBackground) {
      _returningFromBackground = false;
      _showSplashAgain();
    }
  }

  void _showSplashAgain() {
    _navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => SplashScreen(onComplete: _onSplashComplete),
      ),
      (_) => false,
    );
  }

  void _onSplashComplete(AuthSession? session) {
    _splashCompleted = true;

    final nextScreen = session != null && session.isValid
        ? dashboardForRole(session.role)
        : const LoginScreen();

    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Panchayat Grievance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: SplashScreen(onComplete: _onSplashComplete),
    );
  }
}
