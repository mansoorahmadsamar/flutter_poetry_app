import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/widgets/localized_text.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/couplet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/widgets/couplet_engagement_buttons.dart';

class CoupletCard extends ConsumerStatefulWidget {
  final CoupletModel couplet;
  final VoidCallback? onTap;

  const CoupletCard({
    super.key,
    required this.couplet,
    this.onTap,
  });

  @override
  ConsumerState<CoupletCard> createState() => _CoupletCardState();
}

class _CoupletCardState extends ConsumerState<CoupletCard> {
  bool _showEngagementButtons = false;

  void _toggleEngagementButtons() {
    setState(() {
      _showEngagementButtons = !_showEngagementButtons;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? _toggleEngagementButtons,
      onLongPress: _toggleEngagementButtons,
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Couplet type badge
              if (widget.couplet.coupletTypeName != null)
                Align(
                  alignment: Alignment.topLeft,
                  child: Chip(
                    label: Text(
                      widget.couplet.coupletTypeName!,
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    labelPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                  ),
                ),

              SizedBox(height: AppSpacing.sm),

              // Verses
              ...widget.couplet.verses.map((verse) => Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: LocalizedText(
                      verse.text,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 1.8,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )),

              // Engagement buttons (shown on tap/long-press)
              if (_showEngagementButtons) ...[
                SizedBox(height: AppSpacing.md),
                Divider(color: Colors.grey[300]),
                SizedBox(height: AppSpacing.sm),
                CoupletEngagementButtons(couplet: widget.couplet),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
