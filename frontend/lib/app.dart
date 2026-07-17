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

class _PanchayatAppState extends State<PanchayatApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  void _onSplashComplete(AuthSession? session) {
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
      title: 'Mhari Panchayat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: SplashScreen(onComplete: _onSplashComplete),
    );
  }
}
