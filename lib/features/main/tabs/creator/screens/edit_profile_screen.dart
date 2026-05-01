import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/portrait.dart';
import '../models/creator_translation_model.dart';
import '../models/owned_poet_model.dart';
import '../providers/creator_providers.dart';

/// Edit profile + translation manager + facts pencil-to-edit shortcut.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  String _editingLang = 'ur';
  bool _saving = false;

  final _penNameCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _shortBioCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _yearBornCtrl = TextEditingController();
  String? _era;
  String? _gender;
  bool _hydrated = false;

  @override
  void dispose() {
    _penNameCtrl.dispose();
    _fullNameCtrl.dispose();
    _shortBioCtrl.dispose();
    _bioCtrl.dispose();
    _yearBornCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ownedAsync = ref.watch(ownedPoetProvider);
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
            Text('Edit profile',
                style: SukhanText.display(
                  size: 17,
                  color: AppColors.textPrimaryLight,
                  weight: FontWeight.w600,
                  height: 1.1,
                  letterSpacing: -0.17,
                )),
            Text('پروفائل ترتیب دیں',
                textDirection: TextDirection.rtl,
                style: SukhanText.nastaleeq(
                  size: 11,
                  color: AppColors.textSecondaryLight,
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              _saving ? 'Saving…' : 'Save',
              style: SukhanText.sans(
                size: 13,
                color: AppColors.secondary,
                weight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ownedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('$e')),
        data: (poet) {
          if (poet == null) {
            return const Center(child: Text('No poet to edit'));
          }
          if (!_hydrated) {
            _hydrateFromPoet(poet);
            _hydrated = true;
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
            children: [
              _avatarRow(poet),
              const SizedBox(height: 18),
              translationsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (list) => _languagePicker(list),
              ),
              const SizedBox(height: 16),
              _fields(),
              const SizedBox(height: 20),
              _factsCard(),
            ],
          );
        },
      ),
    );
  }

  void _hydrateFromPoet(OwnedPoet poet) {
    _penNameCtrl.text = poet.penName ?? '';
    _fullNameCtrl.text = poet.name;
    _shortBioCtrl.text = poet.shortBio ?? '';
    _bioCtrl.text = poet.biography ?? '';
    _yearBornCtrl.text = poet.birthYear?.toString() ?? '';
    _era = poet.era;
    _gender = poet.gender;
    _editingLang = poet.primaryLanguageCode;
  }

  Widget _avatarRow(OwnedPoet poet) {
    return Row(
      children: [
        Stack(
          children: [
            Portrait(
              size: 72,
              initial: poet.displayInitial,
              hue: PortraitHue.gold,
              ring: true,
              imageUrl: poet.profileImageUrl,
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(color: AppColors.backgroundLight, width: 2),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 11,
                  color: AppColors.backgroundLight,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile image',
                  style: SukhanText.sans(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  )),
              const SizedBox(height: 2),
              Text('Tap avatar — pick from gallery or upload',
                  style: SukhanText.italic(
                    size: 11,
                    color: AppColors.textSecondaryLight,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _languagePicker(List<CreatorTranslation> translations) {
    final entries = SupportedLanguage.all.take(3).toList(); // ur/en/hi from design
    final byCode = {for (final t in translations) t.languageCode: t};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Row(
            children: [
              Text('EDITING IN',
                  style: SukhanText.eyebrow(color: AppColors.secondary)),
              const SizedBox(width: 8),
              Text('زبان منتخب کریں',
                  textDirection: TextDirection.rtl,
                  style: SukhanText.nastaleeq(
                    size: 12,
                    color: AppColors.secondary,
                  )),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.dividerLight),
          ),
          child: Row(
            children: entries.map((l) {
              final on = _editingLang == l.code;
              final tr = byCode[l.code];
              final isPrimary = tr?.isPrimary ?? (l.code == 'ur');
              final isEmpty = tr == null;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _switchLanguage(l.code, byCode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                    decoration: BoxDecoration(
                      color: on ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l.nativeName,
                          textDirection:
                              l.isUrdu ? TextDirection.rtl : TextDirection.ltr,
                          style: l.isUrdu
                              ? SukhanText.nastaleeq(
                                  size: 16,
                                  color: on
                                      ? AppColors.backgroundLight
                                      : (isEmpty
                                          ? AppColors.inkSubtle
                                          : AppColors.textPrimaryLight),
                                )
                              : SukhanText.sans(
                                  size: 13,
                                  weight: on ? FontWeight.w600 : FontWeight.w500,
                                  color: on
                                      ? AppColors.backgroundLight
                                      : (isEmpty
                                          ? AppColors.inkSubtle
                                          : AppColors.textPrimaryLight),
                                ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isPrimary
                              ? 'PRIMARY'
                              : (isEmpty ? '+ ADD' : 'COMPLETE'),
                          style: SukhanText.eyebrow(
                            size: 8,
                            color: on
                                ? AppColors.secondaryLight
                                : (isEmpty
                                    ? AppColors.inkSubtle
                                    : AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _switchLanguage(
      String code, Map<String, CreatorTranslation> byCode) async {
    if (_editingLang == code) return;
    final tr = byCode[code];
    setState(() {
      _editingLang = code;
      // Hydrate fields from selected language. When switching back, the user
      // sees the values they previously saved — backend is source of truth.
      if (tr != null) {
        _penNameCtrl.text = tr.penName ?? '';
        _fullNameCtrl.text = tr.name ?? '';
        _shortBioCtrl.text = tr.shortBio ?? '';
        _bioCtrl.text = tr.biography ?? '';
      } else {
        _penNameCtrl.clear();
        _fullNameCtrl.clear();
        _shortBioCtrl.clear();
        _bioCtrl.clear();
      }
    });
  }

  Widget _fields() {
    final lang = SupportedLanguage.byCode(_editingLang);
    final urdu = lang.isUrdu;
    return Column(
      children: [
        _Field(
          english: 'Pen name',
          urdu: 'تخلص',
          controller: _penNameCtrl,
          isUrdu: urdu,
        ),
        const SizedBox(height: 12),
        _Field(
          english: 'Full name',
          urdu: 'پورا نام',
          controller: _fullNameCtrl,
          isUrdu: urdu,
        ),
        const SizedBox(height: 12),
        _Field(
          english: 'Short bio',
          urdu: 'مختصر تعارف',
          controller: _shortBioCtrl,
          isUrdu: urdu,
          minLines: 2,
          maxLines: 4,
        ),
        const SizedBox(height: 12),
        _Field(
          english: 'Biography',
          urdu: 'تفصیلی تعارف',
          controller: _bioCtrl,
          isUrdu: urdu,
          minLines: 3,
          maxLines: 8,
        ),
        const SizedBox(height: 12),
        _Field(
          english: 'Birth year',
          urdu: 'سنہ پیدائش',
          controller: _yearBornCtrl,
          isUrdu: false,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _factsCard() {
    return GestureDetector(
      onTap: () => GoRouter.of(context).push('/main/creator/facts'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.dividerLight),
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            const Icon(Icons.fact_check_outlined, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Facts',
                          style: SukhanText.display(
                            size: 14,
                            color: AppColors.textPrimaryLight,
                            weight: FontWeight.w600,
                          )),
                      const SizedBox(width: 8),
                      Text('حقائق',
                          textDirection: TextDirection.rtl,
                          style: SukhanText.nastaleeq(
                            size: 12,
                            color: AppColors.secondary,
                          )),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap pencil to add or remove facts in any language.',
                    style: SukhanText.italic(
                      size: 11,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, size: 14, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final svc = ref.read(creatorServiceProvider);
      final translations = ref.read(creatorTranslationsProvider).valueOrNull ??
          const <CreatorTranslation>[];
      final isPrimary = translations.any(
        (t) => t.languageCode == _editingLang && t.isPrimary,
      );

      final patch = <String, dynamic>{
        if (_fullNameCtrl.text.trim().isNotEmpty) 'name': _fullNameCtrl.text.trim(),
        if (_penNameCtrl.text.trim().isNotEmpty) 'penName': _penNameCtrl.text.trim(),
        if (_shortBioCtrl.text.trim().isNotEmpty) 'shortBio': _shortBioCtrl.text.trim(),
        if (_bioCtrl.text.trim().isNotEmpty) 'biography': _bioCtrl.text.trim(),
        if (_era != null) 'era': _era,
        if (_gender != null) 'gender': _gender,
        if (int.tryParse(_yearBornCtrl.text.trim()) != null)
          'birthYear': int.parse(_yearBornCtrl.text.trim()),
      };

      if (isPrimary) {
        await svc.updateMyPoetProfile(patch, lang: _editingLang);
      } else {
        // Translation update; if it doesn't exist yet, POST it.
        final exists = translations.any((t) => t.languageCode == _editingLang);
        if (exists) {
          await svc.updateTranslation(_editingLang, patch);
        } else {
          await svc.addTranslation(
            languageCode: _editingLang,
            name: patch['name'] as String? ?? _editingLang,
            penName: patch['penName'] as String?,
            shortBio: patch['shortBio'] as String?,
            biography: patch['biography'] as String?,
          );
        }
      }
      ref.invalidate(ownedPoetProvider);
      ref.invalidate(creatorTranslationsProvider);
      router.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not save: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.english,
    required this.urdu,
    required this.controller,
    required this.isUrdu,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String english;
  final String urdu;
  final TextEditingController controller;
  final bool isUrdu;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Row(
            children: [
              Text(english,
                  style: SukhanText.sans(
                    size: 12,
                    weight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  )),
              const SizedBox(width: 8),
              Text(urdu,
                  textDirection: TextDirection.rtl,
                  style: SukhanText.nastaleeq(
                    size: 12,
                    color: AppColors.secondary,
                  )),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.hairline),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Directionality(
            textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
            child: TextField(
              controller: controller,
              minLines: minLines,
              maxLines: maxLines,
              keyboardType: keyboardType,
              textAlign: isUrdu ? TextAlign.right : TextAlign.left,
              textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
              style: isUrdu
                  ? SukhanText.nastaleeq(
                      size: 16,
                      color: AppColors.textPrimaryLight,
                      height: 1.85,
                    )
                  : SukhanText.sans(
                      size: 14,
                      color: AppColors.textPrimaryLight,
                    ),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
