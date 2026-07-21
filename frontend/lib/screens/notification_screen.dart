import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

enum _NotifKind { resolved, assigned, submitted, rejected }

class _NotifItem {
  const _NotifItem({
    required this.kind,
    required this.title,
    required this.description,
    required this.time,
  });

  final _NotifKind kind;
  final String title;
  final String description;
  final String time;
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  static const _notifications = [
    _NotifItem(
      kind: _NotifKind.submitted,
      title: 'Complaint submitted',
      description: 'PG-2026-0148 · Your damaged road complaint was registered successfully',
      time: '2 hours ago',
    ),
    _NotifItem(
      kind: _NotifKind.assigned,
      title: 'Complaint assigned',
      description: 'PG-2026-0142 · Street light issue assigned to Rajesh Kumar, JE',
      time: '5 hours ago',
    ),
    _NotifItem(
      kind: _NotifKind.resolved,
      title: 'Complaint resolved',
      description: 'PG-2026-0130 · Drainage issue at Badshahpur has been resolved',
      time: 'Yesterday',
    ),
    _NotifItem(
      kind: _NotifKind.rejected,
      title: 'Complaint rejected',
      description: 'PG-2026-0125 · Complaint rejected due to insufficient information',
      time: '2 days ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _NotifHeader(
            onBack: showBackButton
                ? () => Navigator.of(context).maybePop()
                : null,
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
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 72,
                    color: AppColors.border,
                  ),
                  itemBuilder: (context, index) =>
                      _NotifRow(item: _notifications[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifHeader extends StatelessWidget {
  const _NotifHeader({required this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(8, topPadding + 8, AppSpacing.screen, 26),
      decoration: const BoxDecoration(gradient: AppGradients.header),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              tooltip: 'Back',
            )
          else
            const SizedBox(width: 12),
          Text(
            'Notifications',
            style: GoogleFonts.notoSansDevanagari(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  const _NotifRow({required this.item});

  final _NotifItem item;

  ({Color bg, Color fg, IconData icon}) get _style {
    switch (item.kind) {
      case _NotifKind.resolved:
        return (
          bg: AppColors.greenTint,
          fg: AppColors.resolvedText,
          icon: Icons.check_circle_rounded,
        );
      case _NotifKind.assigned:
        return (
          bg: AppColors.blueTint,
          fg: AppColors.inProgressText,
          icon: Icons.assignment_ind_rounded,
        );
      case _NotifKind.submitted:
        return (
          bg: AppColors.orangeTint,
          fg: AppColors.pendingText,
          icon: Icons.mark_email_unread_rounded,
        );
      case _NotifKind.rejected:
        return (
          bg: AppColors.rejectedBg,
          fg: AppColors.rejectedText,
          icon: Icons.cancel_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screen,
        vertical: 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: style.bg,
            foregroundColor: style.fg,
            child: Icon(style.icon, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF616161),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.time,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
