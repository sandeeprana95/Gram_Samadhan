import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_role.dart';
import '../navigation/app_navigation.dart';
import '../navigation/role_navigation.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _role = UserRole.citizen;
  bool _otpSent = false;
  bool _showAltOptions = false;

  final _mobileController = TextEditingController();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpControllers = List.generate(4, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (final node in _otpFocusNodes) {
      node.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _userIdController.dispose();
    _passwordController.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _continue() async {
    await AuthService.saveLogin(role: _role);
    if (!mounted) return;
    pushReplacement(context, dashboardForRole(_role));
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _onCitizenPrimaryTap() {
    if (!_otpSent) {
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ओटीपी भेजा गया',
            style: GoogleFonts.notoSansDevanagari(),
          ),
        ),
      );
      return;
    }
    _continue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _TopSection(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      const _WelcomeSection(),
                      const SizedBox(height: 20),
                      if (_role == UserRole.citizen) ...[
                        _buildMobileField(),
                        if (_otpSent) ...[
                          const SizedBox(height: 16),
                          _buildOtpRow(),
                        ],
                        const SizedBox(height: 16),
                        GradientButton(
                          onPressed: _onCitizenPrimaryTap,
                          label: _otpSent
                              ? 'ओटीपी सत्यापित करें'
                              : 'ओटीपी भेजें',
                          trailingIcon: _otpSent
                              ? Icons.verified_rounded
                              : Icons.send_rounded,
                          labelStyle: GoogleFonts.notoSansDevanagari(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      const _OrDivider(),
                      const SizedBox(height: 16),
                      _AltOptionsTile(
                        expanded: _showAltOptions,
                        onTap: () =>
                            setState(() => _showAltOptions = !_showAltOptions),
                      ),
                      if (_showAltOptions) ...[
                        const SizedBox(height: 14),
                        _RolePicker(
                          selected: _role,
                          onChanged: (role) => setState(() => _role = role),
                        ),
                        if (_role != UserRole.citizen) ...[
                          const SizedBox(height: 14),
                          _buildStaffField(
                            label: 'यूज़र ID',
                            icon: Icons.person_rounded,
                            controller: _userIdController,
                          ),
                          const SizedBox(height: 12),
                          _buildStaffField(
                            label: 'पासवर्ड',
                            icon: Icons.lock_rounded,
                            controller: _passwordController,
                            obscure: true,
                          ),
                          const SizedBox(height: 16),
                          GradientButton(
                            onPressed: _continue,
                            label: 'लॉगिन करें',
                            icon: Icons.login_rounded,
                            labelStyle: GoogleFonts.notoSansDevanagari(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 24),
                      const _FeatureIconsRow(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                const _VillageIllustration(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14, top: 6),
                  child: Text(
                    '© 2026 पंचायत समाधान। सभी अधिकार सुरक्षित।',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 10,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'मोबाइल नंबर',
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _mobileController,
          keyboardType: TextInputType.phone,
          style: GoogleFonts.notoSansDevanagari(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.phone_android_rounded,
              color: AppColors.mutedText,
            ),
            hintText: 'अपना मोबाइल नंबर दर्ज करें',
            hintStyle: GoogleFonts.notoSansDevanagari(
              fontSize: 13,
              color: AppColors.mutedText,
            ),
            filled: true,
            fillColor: AppColors.background,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.border, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        final focused = _otpFocusNodes[index].hasFocus;
        final filled = _otpControllers[index].text.isNotEmpty;

        return SizedBox(
          width: 44,
          height: 44,
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => _onOtpChanged(index, value),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.background,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: focused || filled
                      ? AppColors.primary
                      : AppColors.border,
                  width: focused ? 2 : 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStaffField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.mutedText),
            filled: true,
            fillColor: AppColors.background,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.border, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopSection extends StatelessWidget {
  const _TopSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF37474F), width: 1.5),
              ),
              child: const Icon(
                Icons.home_work_outlined,
                size: 18,
                color: Color(0xFF37474F),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.header,
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  children: const [
                    TextSpan(
                      text: 'पंचायत',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                    TextSpan(
                      text: 'समाधान',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'आपकी समस्या, हमारा समाधान',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 12,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'स्वागत है!',
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'कृपया लॉगिन करके जारी रखें',
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 12,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'या',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 12,
              color: AppColors.mutedText,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }
}

class _AltOptionsTile extends StatelessWidget {
  const _AltOptionsTile({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.groups_rounded,
                color: AppColors.secondaryText,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'अन्य विकल्प (Officer / Admin)',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF212121),
                  ),
                ),
              ),
              Icon(
                expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: AppColors.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RolePicker extends StatelessWidget {
  const _RolePicker({required this.selected, required this.onChanged});

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleChip(
            label: 'Officer',
            selected: selected == UserRole.officer,
            onTap: () => onChanged(UserRole.officer),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RoleChip(
            label: 'Admin',
            selected: selected == UserRole.admin,
            onTap: () => onChanged(UserRole.admin),
          ),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.orangeTint : AppColors.greyBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.primary : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}

class _FeatureIconsRow extends StatelessWidget {
  const _FeatureIconsRow();

  static const _items = [
    (
      icon: Icons.visibility_rounded,
      label: 'पारदर्शिता',
      bg: AppColors.greenTint,
      fg: AppColors.secondary,
    ),
    (
      icon: Icons.bolt_rounded,
      label: 'त्वरित समाधान',
      bg: AppColors.orangeTint,
      fg: AppColors.primary,
    ),
    (
      icon: Icons.shield_rounded,
      label: 'सुरक्षित',
      bg: AppColors.greenTint,
      fg: AppColors.secondary,
    ),
    (
      icon: Icons.volunteer_activism_rounded,
      label: 'जन सेवा',
      bg: AppColors.orangeTint,
      fg: AppColors.primary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final item in _items)
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.bg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.fg, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 9,
                    color: AppColors.secondaryText,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _VillageIllustration extends StatelessWidget {
  const _VillageIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: CustomPaint(
        painter: _VillageScenePainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _VillageScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Rolling hills
    final hillPaint1 = Paint()..color = const Color(0xFFA5D6A7);
    final hillPaint2 = Paint()..color = const Color(0xFF81C784);

    final hill1 = Path()
      ..moveTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.25, h * 0.55, w * 0.5, h * 0.68)
      ..quadraticBezierTo(w * 0.75, h * 0.82, w, h * 0.65)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hill1, hillPaint1);

    final hill2 = Path()
      ..moveTo(0, h * 0.82)
      ..quadraticBezierTo(w * 0.35, h * 0.68, w * 0.65, h * 0.78)
      ..quadraticBezierTo(w * 0.85, h * 0.88, w, h * 0.75)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hill2, hillPaint2);

    // Sun
    canvas.drawCircle(
      Offset(w * 0.15, h * 0.22),
      14,
      Paint()..color = const Color(0xFFFFCA28),
    );

    // Winding path
    final pathPaint = Paint()
      ..color = const Color(0xFFD7CCC8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(w * 0.1, h * 0.88)
      ..quadraticBezierTo(w * 0.35, h * 0.72, w * 0.5, h * 0.8)
      ..quadraticBezierTo(w * 0.7, h * 0.9, w * 0.88, h * 0.78);
    canvas.drawPath(path, pathPaint);

    // Tree
    final trunkPaint = Paint()..color = const Color(0xFF8D6E63);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.62),
          width: 10,
          height: 28,
        ),
        const Radius.circular(3),
      ),
      trunkPaint,
    );
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.48),
      22,
      Paint()..color = const Color(0xFF66BB6A),
    );

    // Houses
    _drawHouse(canvas, Offset(w * 0.28, h * 0.58), 0.9);
    _drawHouse(canvas, Offset(w * 0.72, h * 0.62), 0.75);
  }

  void _drawHouse(Canvas canvas, Offset base, double scale) {
    final bodyW = 34.0 * scale;
    final bodyH = 26.0 * scale;

    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(base.dx, base.dy),
        width: bodyW,
        height: bodyH,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFFFF8E1));

    final roof = Path()
      ..moveTo(base.dx - bodyW * 0.6, base.dy - bodyH * 0.45)
      ..lineTo(base.dx, base.dy - bodyH * 0.95)
      ..lineTo(base.dx + bodyW * 0.6, base.dy - bodyH * 0.45)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFF8D6E63));

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(base.dx, base.dy + bodyH * 0.1),
        width: 10 * scale,
        height: 12 * scale,
      ),
      Paint()..color = const Color(0xFF5D4037),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
