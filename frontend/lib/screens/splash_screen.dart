import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

import '../navigation/app_navigation.dart';
import '../navigation/role_navigation.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

typedef SplashCompleteCallback = void Function(AuthSession? session);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.onComplete});

  final SplashCompleteCallback? onComplete;

  static const Duration minDisplayDuration = Duration(seconds: 3);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isBootstrapping = false;
  bool _hasFinished = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (_isBootstrapping || _hasFinished) return;
    _isBootstrapping = true;

    final startedAt = DateTime.now();
    final session = await AuthService.getSession();

    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < SplashScreen.minDisplayDuration) {
      await Future<void>.delayed(SplashScreen.minDisplayDuration - elapsed);
    }

    if (!mounted || _hasFinished) return;
    _hasFinished = true;
    _finish(session);
  }

  void _finish(AuthSession? session) {
    if (widget.onComplete != null) {
      widget.onComplete!(session);
      return;
    }

    final nextScreen = session != null && session.isValid
        ? dashboardForRole(session.role)
        : const LoginScreen();
    pushReplacement(context, nextScreen);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SizedBox(
          width: double.infinity,
          height: screenHeight,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: AppGradients.header),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: double.infinity,
                    height: 340,
                    child: const _SplashIllustration(),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        'पंचायत समाधान',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansDevanagari(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'आपकी समस्या, हमारा समाधान',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansDevanagari(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 40,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _dot(active: true),
                          const SizedBox(width: 8),
                          _dot(active: false),
                          const SizedBox(width: 8),
                          _dot(active: false),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '© 2026 पंचायत समाधान। सभी अधिकार सुरक्षित।',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansDevanagari(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot({required bool active}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? Colors.white
            : Colors.white.withValues(alpha: 0.4),
      ),
    );
  }
}

class _SplashIllustration extends StatelessWidget {
  const _SplashIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SplashVillagePainter(),
      size: Size.infinite,
    );
  }
}

class _SplashVillagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Soft glow circles
    canvas.drawCircle(
      center,
      130,
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );
    canvas.drawCircle(
      Offset(center.dx + 18, center.dy - 12),
      100,
      Paint()..color = Colors.white.withValues(alpha: 0.1),
    );

    // Rolling ground
    final ground = Path()
      ..moveTo(size.width * 0.08, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.58,
        size.width * 0.5,
        size.height * 0.68,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.8,
        size.width * 0.92,
        size.height * 0.66,
      )
      ..lineTo(size.width * 0.92, size.height * 0.88)
      ..lineTo(size.width * 0.08, size.height * 0.88)
      ..close();
    canvas.drawPath(
      ground,
      Paint()..color = Colors.white.withValues(alpha: 0.15),
    );

    // Houses
    _drawHouse(
      canvas,
      Offset(size.width * 0.28, size.height * 0.62),
      scale: 1.0,
    );
    _drawHouse(
      canvas,
      Offset(size.width * 0.74, size.height * 0.64),
      scale: 0.85,
    );

    // Tree
    final treeCenter = Offset(size.width * 0.5, size.height * 0.52);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(treeCenter.dx, treeCenter.dy + 28),
          width: 12,
          height: 34,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF8D6E63),
    );
    canvas.drawCircle(
      treeCenter,
      34,
      Paint()..color = const Color(0xFF66BB6A),
    );
    canvas.drawCircle(
      Offset(treeCenter.dx - 26, treeCenter.dy + 6),
      18,
      Paint()..color = const Color(0xFF81C784),
    );
    canvas.drawCircle(
      Offset(treeCenter.dx + 26, treeCenter.dy + 4),
      16,
      Paint()..color = const Color(0xFF81C784),
    );

    // Villagers
    final figures = [
      Offset(size.width * 0.38, size.height * 0.7),
      Offset(size.width * 0.44, size.height * 0.72),
      Offset(size.width * 0.56, size.height * 0.72),
      Offset(size.width * 0.62, size.height * 0.7),
    ];
    for (final pos in figures) {
      _drawFigure(canvas, pos);
    }
  }

  void _drawHouse(Canvas canvas, Offset base, {required double scale}) {
    final bodyW = 38.0 * scale;
    final bodyH = 28.0 * scale;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx, base.dy),
          width: bodyW,
          height: bodyH,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );

    final roof = Path()
      ..moveTo(base.dx - bodyW * 0.62, base.dy - bodyH * 0.42)
      ..lineTo(base.dx, base.dy - bodyH)
      ..lineTo(base.dx + bodyW * 0.62, base.dy - bodyH * 0.42)
      ..close();
    canvas.drawPath(
      roof,
      Paint()..color = const Color(0xFFFFCC80),
    );
  }

  void _drawFigure(Canvas canvas, Offset base) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.35);

    canvas.drawCircle(Offset(base.dx, base.dy - 14), 7, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx, base.dy + 4),
          width: 14,
          height: 20,
        ),
        const Radius.circular(6),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
