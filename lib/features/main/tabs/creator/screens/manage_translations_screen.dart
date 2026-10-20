import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/sukhan_chip.dart';
import '../models/creator_translation_model.dart';
import '../providers/creator_providers.dart';

/// List of all translations + an "Add language" option. Selecting a row
/// pushes back to EditProfileScreen with the chosen language tab active.
class ManageTranslationsScreen extends ConsumerWidget {
  const ManageTranslationsScreen({super.key, this.initialLang = 'en'});

  final String initialLang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationsAsync = ref.watch(creatorTranslationsProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.paperSurface,
        surfaceTintColor: AppColors.paperSurface,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Translations',
                style: SukhanText.display(
                  size: 17,
                  color: AppColors.textPrimaryLight,
                  weight: FontWeight.w600,
                  height: 1.1,
                )),
            Text('ترجمے',
                textDirection: TextDirection.rtl,
                style: SukhanText.nastaleeq(
                  size: 12,
                  color: AppColors.textSecondaryLight,
                )),
          ],
        ),
      ),
      body: translationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (existing) {
          final byCode = {for (final t in existing) t.languageCode: t};
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              for (final l in SupportedLanguage.all)
                _TranslationRow(
                  language: l,
                  translation: byCode[l.code],
                  onTap: () {
                    GoRouter.of(context).pushReplacement(
                      '/main/creator/profile/edit',
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TranslationRow extends StatelessWidget {
  const _TranslationRow({
    required this.language,
    required this.translation,
    required this.onTap,
  });

  final SupportedLanguage language;
  final CreatorTranslation? translation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final exists = translation != null;
    final isPrimary = translation?.isPrimary ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPrimary ? AppColors.secondary : AppColors.dividerLight,
                width: isPrimary ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: exists ? AppColors.greenSoft : AppColors.paperSurface,
                  ),
                  child: Text(
                    language.nativeName,
                    textDirection: language.isUrdu
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    style: language.isUrdu
                        ? SukhanText.nastaleeq(
                            size: 12,
                            color: AppColors.primary,
                          )
                        : SukhanText.sans(
                            size: 11,
                            color: AppColors.primary,
                            weight: FontWeight.w600,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(language.englishName,
                              style: SukhanText.sans(
                                size: 13,
                                color: AppColors.textPrimaryLight,
                                weight: FontWeight.w600,
                              )),
                          if (isPrimary) ...[
                            const SizedBox(width: 6),
                            const SukhanChip(
                              label: 'PRIMARY',
                              variant: SukhanChipVariant.gold,
                              fontSize: 9,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        exists
                            ? '${(translation?.hasShortBio ?? false) ? "Short bio" : "—"} · ${(translation?.hasBiography ?? false) ? "Biography" : "—"}'
                            : 'Not added yet',
                        style: SukhanText.italic(
                          size: 11,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  exists ? Icons.edit : Icons.add,
                  size: 16,
                  color: exists ? AppColors.secondary : AppColors.inkSubtle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
