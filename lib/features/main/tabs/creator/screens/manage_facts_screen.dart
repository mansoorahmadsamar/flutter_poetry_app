import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/sukhan_chip.dart';
import '../models/creator_translation_model.dart';
import '../providers/creator_providers.dart';
import '../utils/api_error_messages.dart';

/// Read-only list of facts with swipe-to-delete + add bottom sheet.
class ManageFactsScreen extends ConsumerWidget {
  const ManageFactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factsAsync = ref.watch(creatorFactsProvider);
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
            Text('Facts',
                style: SukhanText.display(
                  size: 17,
                  color: AppColors.textPrimaryLight,
                  weight: FontWeight.w600,
                  height: 1.1,
                )),
            Text('حقائق',
                textDirection: TextDirection.rtl,
                style: SukhanText.nastaleeq(
                  size: 12,
                  color: AppColors.textSecondaryLight,
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.backgroundLight,
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add fact'),
      ),
      body: factsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (facts) {
          if (facts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No facts yet — add a verse credit, an awarded prize, or a stage you read at.',
                  textAlign: TextAlign.center,
                  style: SukhanText.italic(
                    size: 13,
                    color: AppColors.textSecondaryLight,
                    height: 1.6,
                  ),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
            itemCount: facts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final f = facts[i];
              final lang = SupportedLanguage.byCode(f.languageCode);
              return Dismissible(
                key: ValueKey(f.publicId),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline, color: AppColors.error),
                ),
                onDismissed: (_) async {
                  final messenger = ScaffoldMessenger.of(ctx);
                  try {
                    await ref.read(creatorServiceProvider).deleteFact(f.publicId);
                    ref.invalidate(creatorFactsProvider);
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(friendlyApiMessage(e, CreatorAction.deleteFact)),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.dividerLight),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '• ${f.fact}',
                          textDirection: lang.isUrdu
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          style: lang.isUrdu
                              ? SukhanText.nastaleeq(
                                  size: 14,
                                  color: AppColors.textPrimaryLight,
                                  height: 1.7,
                                )
                              : SukhanText.sans(
                                  size: 13,
                                  color: AppColors.textPrimaryLight,
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SukhanChip(
                        label: f.languageCode.toUpperCase(),
                        variant: SukhanChipVariant.ghost,
                        fontSize: 9,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddSheet(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    var lang = 'ur';
    final messenger = ScaffoldMessenger.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 140),
                    decoration: BoxDecoration(
                      color: AppColors.dividerLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('New fact',
                      style: SukhanText.display(
                        size: 18,
                        color: AppColors.textPrimaryLight,
                        weight: FontWeight.w600,
                      )),
                  const SizedBox(height: 4),
                  Text('نیا حقیقت',
                      textDirection: TextDirection.rtl,
                      style: SukhanText.nastaleeq(
                        size: 13,
                        color: AppColors.secondary,
                      )),
                  const SizedBox(height: 14),
                  Row(
                    children: SupportedLanguage.all.take(4).map((l) {
                      final on = lang == l.code;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: SukhanChip(
                          label: l.englishName,
                          variant: on
                              ? SukhanChipVariant.green
                              : SukhanChipVariant.ghost,
                          fontSize: 11,
                          onTap: () => setSheetState(() => lang = l.code),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.paperSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Directionality(
                      textDirection: SupportedLanguage.byCode(lang).isUrdu
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: TextField(
                        controller: ctrl,
                        autofocus: true,
                        minLines: 2,
                        maxLines: 4,
                        style: SupportedLanguage.byCode(lang).isUrdu
                            ? SukhanText.nastaleeq(
                                size: 15,
                                color: AppColors.textPrimaryLight,
                              )
                            : SukhanText.sans(
                                size: 13,
                                color: AppColors.textPrimaryLight,
                              ),
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: '…',
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final text = ctrl.text.trim();
                        if (text.isEmpty) return;
                        Navigator.of(ctx).pop();
                        try {
                          await ref
                              .read(creatorServiceProvider)
                              .addFact(fact: text, languageCode: lang);
                          ref.invalidate(creatorFactsProvider);
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(friendlyApiMessage(e, CreatorAction.addFact)),
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.backgroundLight,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Add fact'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
