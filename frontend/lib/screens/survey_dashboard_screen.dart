import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../navigation/app_navigation.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'survey_screen.dart';

class _SurveyCategory {
  const _SurveyCategory({
    required this.name,
    required this.completed,
    required this.total,
    required this.icon,
    required this.badgeBg,
    required this.iconColor,
    this.wide = false,
  });

  final String name;
  final int completed;
  final int total;
  final IconData icon;
  final Color badgeBg;
  final Color iconColor;
  final bool wide;
}

class SurveyDashboardScreen extends StatelessWidget {
  const SurveyDashboardScreen({super.key});

  static const _categories = [
    _SurveyCategory(
      name: 'जल सर्वे',
      completed: 142,
      total: 200,
      icon: Icons.water_drop_rounded,
      badgeBg: Color(0xFFE3F2FD),
      iconColor: Color(0xFF1565C0),
    ),
    _SurveyCategory(
      name: 'सड़क सर्वे',
      completed: 98,
      total: 150,
      icon: Icons.add_road_rounded,
      badgeBg: Color(0xFFFFF3E0),
      iconColor: Color(0xFFF57C00),
    ),
    _SurveyCategory(
      name: 'नाली सर्वे',
      completed: 76,
      total: 120,
      icon: Icons.waves_rounded,
      badgeBg: Color(0xFFE0F2F1),
      iconColor: Color(0xFF00796B),
    ),
    _SurveyCategory(
      name: 'स्ट्रीट लाइट',
      completed: 54,
      total: 80,
      icon: Icons.lightbulb_rounded,
      badgeBg: Color(0xFFFFF8E1),
      iconColor: Color(0xFFF9A825),
    ),
    _SurveyCategory(
      name: 'परिसंपत्ति सर्वे',
      completed: 31,
      total: 50,
      icon: Icons.apartment_rounded,
      badgeBg: Color(0xFFE8F5E9),
      iconColor: Color(0xFF2E7D32),
      wide: true,
    ),
  ];

  void _openSurvey(BuildContext context, String surveyName) {
    push(
      context,
      SurveyScreen(surveyTitle: '$surveyName फॉर्म'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gridItems = _categories.where((c) => !c.wide).toList();
    final wideItem = _categories.firstWhere((c) => c.wide);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GradientHeader(
            title: 'सर्वे डैशबोर्ड',
            subtitle: 'AMRUT योजना अंतर्गत',
            onBack: () => Navigator.of(context).maybePop(),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.05,
                        ),
                        itemCount: gridItems.length,
                        itemBuilder: (context, index) {
                          final item = gridItems[index];
                          return _SurveyCategoryCard(
                            category: item,
                            onTap: () => _openSurvey(context, item.name),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _SurveyWideCard(
                        category: wideItem,
                        onTap: () => _openSurvey(context, wideItem.name),
                      ),
                      const SizedBox(height: 20),
                      GradientButton(
                        onPressed: () => _openSurvey(context, 'नया सर्वे'),
                        label: '+ नया सर्वे शुरू करें',
                        labelStyle: GoogleFonts.notoSansDevanagari(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SurveyCategoryCard extends StatelessWidget {
  const _SurveyCategoryCard({
    required this.category,
    required this.onTap,
  });

  final _SurveyCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconBadge(category: category),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${category.completed}/${category.total} पूर्ण',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 11,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SurveyWideCard extends StatelessWidget {
  const _SurveyWideCard({
    required this.category,
    required this.onTap,
  });

  final _SurveyCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _IconBadge(category: category),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.completed}/${category.total} पूर्ण',
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 11,
                          color: AppColors.mutedText,
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
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.category});

  final _SurveyCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: category.badgeBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(category.icon, color: category.iconColor, size: 20),
    );
  }
}
