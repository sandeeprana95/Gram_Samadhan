import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

enum _SurveyInputType { yesNo, yesNoWithAttachments }

class _SurveyStep {
  const _SurveyStep({
    required this.question,
    this.inputType = _SurveyInputType.yesNo,
  });

  final String question;
  final _SurveyInputType inputType;
}

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key, this.surveyTitle = 'जल सर्वे फॉर्म'});

  final String surveyTitle;

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  static const _steps = [
    _SurveyStep(
      question: 'क्या आपके घर में स्वच्छ पेयजल उपलब्ध है?',
    ),
    _SurveyStep(
      question: 'क्या पानी की गुणवत्ता संतोषजनक है?',
    ),
    _SurveyStep(
      question: 'क्या घर में पानी का नल कनेक्शन है?',
      inputType: _SurveyInputType.yesNoWithAttachments,
    ),
    _SurveyStep(
      question: 'क्या पानी का दबाव पर्याप्त है?',
    ),
    _SurveyStep(
      question: 'क्या नल से पानी में कोई दुर्गंध आती है?',
    ),
  ];

  int _currentStep = 0;
  final Map<int, bool?> _answers = {};

  int get _totalSteps => _steps.length;
  double get _progress => (_currentStep + 1) / _totalSteps;
  _SurveyStep get _step => _steps[_currentStep];
  bool? get _currentAnswer => _answers[_currentStep];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GradientHeader(
            title: widget.surveyTitle,
            onBack: _handleBack,
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ProgressBar(progress: _progress),
                            const SizedBox(height: 8),
                            Text(
                              'प्रश्न ${_currentStep + 1}/$_totalSteps',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 12,
                                color: AppColors.mutedText,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _step.question,
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF212121),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _YesNoRow(
                              value: _currentAnswer,
                              onChanged: (v) =>
                                  setState(() => _answers[_currentStep] = v),
                            ),
                            if (_step.inputType ==
                                _SurveyInputType.yesNoWithAttachments) ...[
                              const SizedBox(height: 18),
                              const Row(
                                children: [
                                  Expanded(
                                    child: _UploadTile(
                                      label: 'Geo-tagged photo',
                                      icon: Icons.photo_camera_rounded,
                                      borderColor: AppColors.secondary,
                                      iconColor: AppColors.secondary,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: _UploadTile(
                                      label: 'GPS captured',
                                      icon: Icons.location_on_rounded,
                                      borderColor: AppColors.primary,
                                      iconColor: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'डिजिटल हस्ताक्षर',
                                style: GoogleFonts.notoSansDevanagari(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF212121),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 70,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  'यहाँ हस्ताक्षर करें',
                                  style: GoogleFonts.notoSansDevanagari(
                                    fontSize: 12,
                                    color: AppColors.mutedText,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _handleBack,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF616161),
                                  side: const BorderSide(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: GoogleFonts.notoSansDevanagari(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                child: const Text('पीछे'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SurveyNextButton(
                                label: _currentStep < _totalSteps - 1
                                    ? 'आगे बढ़ें'
                                    : 'जमा करें',
                                onPressed: _handleNext,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _handleNext() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'सर्वे सफलतापूर्वक जमा हुआ',
          style: GoogleFonts.notoSansDevanagari(),
        ),
      ),
    );
    Navigator.of(context).pop();
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 5,
        width: double.infinity,
        child: Stack(
          children: [
            Container(color: AppColors.greyBg),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: const BoxDecoration(gradient: AppGradients.cta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _YesNoRow extends StatelessWidget {
  const _YesNoRow({required this.value, required this.onChanged});

  final bool? value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AnswerChip(
            label: 'हाँ',
            selected: value == true,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _AnswerChip(
            label: 'नहीं',
            selected: value == false,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }
}

class _AnswerChip extends StatelessWidget {
  const _AnswerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF3DE) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.secondary : AppColors.border,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected
                    ? const Color(0xFF27500A)
                    : const Color(0xFF616161),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.label,
    required this.icon,
    required this.borderColor,
    required this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color borderColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: borderColor, radius: 12),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF616161),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurveyNextButton extends StatelessWidget {
  const _SurveyNextButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppGradients.cta,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: Text(
              label,
              style: GoogleFonts.notoSansDevanagari(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
