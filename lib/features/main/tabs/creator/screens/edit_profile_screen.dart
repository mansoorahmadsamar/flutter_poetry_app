import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/portrait.dart';
import '../models/creator_translation_model.dart';
import '../models/owned_poet_model.dart';
import '../providers/creator_providers.dart';
import '../utils/api_error_messages.dart';

/// Edit profile + translation manager + facts pencil-to-edit shortcut.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

/// In-memory snapshot of the four translatable fields for one language.
/// Lets us swap language tabs without losing what the user has typed —
/// the live controllers are flushed into this cache on every tab change.
class _LangFields {
  String penName;
  String name;
  String shortBio;
  String biography;

  _LangFields({
    this.penName = '',
    this.name = '',
    this.shortBio = '',
    this.biography = '',
  });

  bool get isAnyNotEmpty =>
      penName.trim().isNotEmpty ||
      name.trim().isNotEmpty ||
      shortBio.trim().isNotEmpty ||
      biography.trim().isNotEmpty;
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

  /// Per-language draft cache. Snapshot of each language's four
  /// translatable fields, keyed by ISO code (ur/en/hi). Survives tab
  /// switches; committed to the server only on Save.
  final Map<String, _LangFields> _langDrafts = {};

  /// True once we've seeded the cache from `creatorTranslationsProvider`.
  /// Prevents re-running on every rebuild (which would overwrite the
  /// user's live edits).
  bool _translationsSeeded = false;

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
          // Seed the cache for ALL three languages once translations
          // arrive. We can't use the translations list directly — that
          // endpoint strips shortBio/biography (returns hasShortBio
          // /hasBiography flags only). Instead, fire one
          // `GET /api/me/poet-profile?lang=XX` per language we know exists
          // and merge the rich response into _langDrafts. Gated by
          // [_translationsSeeded] so it only runs once per screen open.
          if (!_translationsSeeded) {
            translationsAsync.whenData((list) {
              if (list.isEmpty) return;
              _translationsSeeded = true;
              _loadAllLanguageDrafts(list);
            });
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
            children: [
              _avatarRow(poet),
              const SizedBox(height: 18),
              _settingsSection(poet),
              const SizedBox(height: 18),
              translationsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (list) => _languagePicker(list),
              ),
              const SizedBox(height: 16),
              _fields(),
            ],
          );
        },
      ),
    );
  }

  void _hydrateFromPoet(OwnedPoet poet) {
    _editingLang = poet.primaryLanguageCode;
    // Seed the cache with the primary-language values from the poet object
    // so the cache is the single source of truth even before any tab
    // switch. Other languages will be lazily seeded from
    // [creatorTranslationsProvider] the first time the user visits them
    // (see [_switchLanguage]).
    _langDrafts[_editingLang] = _LangFields(
      penName: poet.penName ?? '',
      name: poet.name,
      shortBio: poet.shortBio ?? '',
      biography: poet.biography ?? '',
    );
    _restoreControllersFromCache(_editingLang);
    _yearBornCtrl.text = poet.birthYear?.toString() ?? '';
    _era = poet.era;
    _gender = poet.gender;
  }

  /// Fetch the full per-language profile for every language the user has
  /// translations in. The translations LIST endpoint omits shortBio/
  /// biography (returns hasShortBio/hasBiography flags only) so we need
  /// the dedicated profile endpoint per language to populate the cache
  /// with editable text. Fires the 3 GETs in parallel.
  Future<void> _loadAllLanguageDrafts(List<CreatorTranslation> list) async {
    final svc = ref.read(creatorServiceProvider);
    final codes = list.map((t) => t.languageCode).toSet().toList();
    final results = await Future.wait(
      codes.map((c) => svc.getMyPoetProfile(lang: c).then(
            (p) => MapEntry(c, p),
            onError: (Object _) => null,
          )),
    );
    if (!mounted) return;
    for (final entry in results.whereType<MapEntry<String, OwnedPoet>>()) {
      final code = entry.key;
      final p = entry.value;
      _langDrafts[code] = _LangFields(
        penName: p.penName ?? '',
        name: p.name,
        shortBio: p.shortBio ?? '',
        biography: p.biography ?? '',
      );
    }
    // Mirror the (now-richer) cache entry for the current tab into the
    // live controllers so the user immediately sees the loaded text.
    setState(() {
      _restoreControllersFromCache(_editingLang);
    });
  }

  /// Flush the live controllers' text into the cache entry for [code].
  void _snapshotControllersToCache(String code) {
    final entry = _langDrafts[code] ?? _LangFields();
    entry.penName = _penNameCtrl.text;
    entry.name = _fullNameCtrl.text;
    entry.shortBio = _shortBioCtrl.text;
    entry.biography = _bioCtrl.text;
    _langDrafts[code] = entry;
  }

  /// Populate the live controllers from the cache entry for [code]. If
  /// nothing is cached, the controllers are cleared so the user sees a
  /// blank form (callers seed from server values when appropriate).
  void _restoreControllersFromCache(String code) {
    final entry = _langDrafts[code];
    _penNameCtrl.text = entry?.penName ?? '';
    _fullNameCtrl.text = entry?.name ?? '';
    _shortBioCtrl.text = entry?.shortBio ?? '';
    _bioCtrl.text = entry?.biography ?? '';
  }

  Widget _avatarRow(OwnedPoet poet) {
    return Row(
      children: [
        GestureDetector(
          onTap: _saving ? null : _pickAndUploadAvatar,
          child: Stack(
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
                    border:
                        Border.all(color: AppColors.backgroundLight, width: 2),
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

  /// Tap-the-avatar handler: source picker → image_picker → upload via
  /// `CreatorService.uploadImage(isProfileImage: true)` → invalidate the
  /// owned-poet provider so the hero portrait refreshes. Pattern mirrored
  /// from `gallery_tab._uploadImage`.
  Future<void> _pickAndUploadAvatar() async {
    final messenger = ScaffoldMessenger.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dividerLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pick from gallery'),
              onTap: () => Navigator.of(sheetCtx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(sheetCtx).pop(ImageSource.camera),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );
    if (picked == null) return;
    try {
      await ref.read(creatorServiceProvider).uploadImage(
            filePath: picked.path,
            isProfileImage: true,
          );
      ref.invalidate(ownedPoetProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('Profile picture updated')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(friendlyApiMessage(e, CreatorAction.uploadImage)),
      ));
    }
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
    setState(() {
      // (1) Snapshot what the user just typed for the OUTGOING language so
      // their in-progress edits survive the tab switch.
      _snapshotControllersToCache(_editingLang);

      _editingLang = code;

      // (2) If the INCOMING language has never been edited in this session,
      // seed its cache entry from the server translation (or leave blank).
      if (!_langDrafts.containsKey(code)) {
        final tr = byCode[code];
        _langDrafts[code] = _LangFields(
          penName: tr?.penName ?? '',
          name: tr?.name ?? '',
          shortBio: tr?.shortBio ?? '',
          biography: tr?.biography ?? '',
        );
      }

      // (3) Restore controllers from the cache for the new language.
      _restoreControllersFromCache(code);
    });
  }

  /// Per-language translatable fields. Birth year is intentionally NOT
  /// here — it's identity and lives in [_identityCard].
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
      ],
    );
  }

  /// Settings-style section above the language tabs. Two tappable rows:
  /// (1) Birth year — opens a calendar picker; only the year is persisted
  /// because the backend currently stores `birthYear` as an int. (Backend
  /// can add a `birthDate` later without changing this UI.)
  /// (2) Facts — pushes the dedicated Facts screen, which already manages
  /// per-language facts on its own.
  Widget _settingsSection(OwnedPoet poet) {
    final year = int.tryParse(_yearBornCtrl.text.trim());
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Column(
        children: [
          _SettingsRow(
            icon: Icons.calendar_today_outlined,
            english: 'Birth year',
            urdu: 'سنہ پیدائش',
            value: year?.toString() ?? 'Set',
            onTap: _pickBirthYear,
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.dividerLight,
            indent: 14,
            endIndent: 14,
          ),
          _SettingsRow(
            icon: Icons.fact_check_outlined,
            english: 'Facts',
            urdu: 'حقائق',
            value: 'Edit',
            onTap: () => GoRouter.of(context).push('/main/creator/facts'),
          ),
        ],
      ),
    );
  }

  /// Open a calendar picker for birth date. Defaults to Jan 1 of the
  /// current birthYear (or 1950 if unset). Only the year is persisted to
  /// the server — month/day are ignored for now.
  Future<void> _pickBirthYear() async {
    final currentYear = int.tryParse(_yearBornCtrl.text.trim());
    final initial = currentYear != null
        ? DateTime(currentYear, 1, 1)
        : DateTime(1950, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1200, 1, 1),
      lastDate: DateTime.now(),
      helpText: 'Select birth year',
      // Force the wheel/spinner mode so the user lands on year-picking
      // quickly — the underlying field is just the year.
      initialDatePickerMode: DatePickerMode.year,
      initialEntryMode: DatePickerEntryMode.calendar,
    );
    if (picked == null) return;
    setState(() {
      _yearBornCtrl.text = picked.year.toString();
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    var action = CreatorAction.updatePoetProfile;
    try {
      // Flush the currently-visible tab into the cache so we don't lose
      // edits made since the last tab switch.
      _snapshotControllersToCache(_editingLang);

      final svc = ref.read(creatorServiceProvider);
      final translations = ref.read(creatorTranslationsProvider).valueOrNull ??
          const <CreatorTranslation>[];

      String? primaryLang = translations
          .where((t) => t.isPrimary)
          .map((t) => t.languageCode)
          .firstOrNull;
      // Fall back to the in-state primary if the translations list hasn't
      // arrived yet (rare, but be safe).
      primaryLang ??= _editingLang;

      // ── Identity (birth year, era, gender) → PUT /api/me/poet-profile ──
      final identity = <String, dynamic>{
        if (int.tryParse(_yearBornCtrl.text.trim()) != null)
          'birthYear': int.parse(_yearBornCtrl.text.trim()),
        if (_era != null) 'era': _era,
        if (_gender != null) 'gender': _gender,
      };
      if (identity.isNotEmpty) {
        action = CreatorAction.updatePoetProfile;
        await svc.updateMyPoetProfile(identity, lang: primaryLang);
      }

      // ── Per-language translatable fields ──
      // Walk every cached language; pick the right endpoint per language
      // (primary → profile update; existing → translation update; new →
      // translation add). Skip languages with nothing typed.
      for (final entry in _langDrafts.entries) {
        final code = entry.key;
        final f = entry.value;
        if (!f.isAnyNotEmpty) continue;

        final translatable = <String, dynamic>{
          if (f.name.trim().isNotEmpty) 'name': f.name.trim(),
          if (f.penName.trim().isNotEmpty) 'penName': f.penName.trim(),
          if (f.shortBio.trim().isNotEmpty) 'shortBio': f.shortBio.trim(),
          if (f.biography.trim().isNotEmpty) 'biography': f.biography.trim(),
        };
        if (translatable.isEmpty) continue;

        final isPrimary = code == primaryLang;
        if (isPrimary) {
          action = CreatorAction.updatePoetProfile;
          await svc.updateMyPoetProfile(translatable, lang: code);
        } else if (translations.any((t) => t.languageCode == code)) {
          action = CreatorAction.updateTranslation;
          await svc.updateTranslation(code, translatable);
        } else {
          action = CreatorAction.addTranslation;
          await svc.addTranslation(
            languageCode: code,
            name: translatable['name'] as String? ?? code,
            penName: translatable['penName'] as String?,
            shortBio: translatable['shortBio'] as String?,
            biography: translatable['biography'] as String?,
          );
        }
      }

      ref.invalidate(ownedPoetProvider);
      ref.invalidate(creatorTranslationsProvider);
      router.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(friendlyApiMessage(e, action))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

/// One row in the settings section above the language tabs. Icon · bilingual
/// label · value · chevron, fully tappable. Use for poet-identity fields
/// (e.g. birth year) and shortcuts to dedicated screens (e.g. Facts) so
/// the language tabs only carry translatable content.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.english,
    required this.urdu,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String english;
  final String urdu;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Text(english,
                        style: SukhanText.sans(
                          size: 14,
                          color: AppColors.textPrimaryLight,
                          weight: FontWeight.w600,
                        )),
                    const SizedBox(width: 6),
                    Text(urdu,
                        textDirection: TextDirection.rtl,
                        style: SukhanText.nastaleeq(
                          size: 12,
                          color: AppColors.secondary,
                        )),
                  ],
                ),
              ),
              Text(value,
                  style: SukhanText.italic(
                    size: 12,
                    color: AppColors.textSecondaryLight,
                  )),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.inkSubtle),
            ],
          ),
        ),
      ),
    );
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
  });

  final String english;
  final String urdu;
  final TextEditingController controller;
  final bool isUrdu;
  final int minLines;
  final int maxLines;

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
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
