import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/core/widgets/localized_text.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/couplet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/widgets/couplet_engagement_buttons.dart';

class CoupletCard extends ConsumerStatefulWidget {
  final CoupletModel couplet;
  final VoidCallback? onTap;
  final String? poemPublicId; // Optional: for invalidating the coupletsProvider

  const CoupletCard({
    super.key,
    required this.couplet,
    this.onTap,
    this.poemPublicId,
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
    final couplet = widget.couplet;
    final languageCode = ref.watch(selectedLanguageProvider);
    final isUrdu = languageCode == 'ur';

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
              if (couplet.coupletTypeName != null)
                Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Chip(
                    label: Text(
                      couplet.coupletTypeName!,
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

              // Verses - show romanization only for non-Urdu languages
              ...couplet.verses.map((verse) => _buildVerseText(verse, isUrdu)),

              // Engagement buttons (shown on tap/long-press)
              if (_showEngagementButtons) ...[
                SizedBox(height: AppSpacing.md),
                Divider(color: Colors.grey[300]),
                SizedBox(height: AppSpacing.sm),
                CoupletEngagementButtons(
                  couplet: couplet,
                  poemPublicId: widget.poemPublicId,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build verse text with optional romanization
  /// For Urdu: Show only the Arabic script text
  /// For English/Hindi: Show primary text + romanized text (if available)
  Widget _buildVerseText(VerseModel verse, bool isUrdu) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          // Primary verse text (always shown)
          LocalizedText(
            verse.text,
            style: const TextStyle(
              fontSize: 20,
              height: 1.8,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          // Romanized text (only for non-Urdu if available)
          if (!isUrdu && verse.romanizedText != null && verse.romanizedText!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              verse.romanizedText!,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
