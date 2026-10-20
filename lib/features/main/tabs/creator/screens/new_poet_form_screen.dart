import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_poetry_app/core/auth/auth_provider.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/providers/user_provider.dart';
import '../models/creator_translation_model.dart';
import '../providers/creator_providers.dart';
import '../utils/api_error_messages.dart';

/// Form for creating a brand-new poet profile.
/// On submit: POST /api/me/poet-profile → silent JWT refresh → invalidate
/// ownedPoetProvider → push success sheet → pop to creator dashboard.
class NewPoetFormScreen extends ConsumerStatefulWidget {
  const NewPoetFormScreen({super.key});

  @override
  ConsumerState<NewPoetFormScreen> createState() => _NewPoetFormScreenState();
}

class _NewPoetFormScreenState extends ConsumerState<NewPoetFormScreen> {
  final _penNameCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  String _languageCode = 'ur';
  bool _submitting = false;

  static const _bioMax = 160;

  @override
  void initState() {
    super.initState();
    _bioCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _penNameCtrl.dispose();
    _fullNameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 12),
          _ProgressBar(filled: 2, total: 3),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tell us who you are',
                    style: SukhanText.display(
                      size: 22,
                      color: AppColors.textPrimaryLight,
                      weight: FontWeight.w500,
                      letterSpacing: -0.22,
                    )),
                const SizedBox(height: 4),
                Text('اپنا تعارف لکھیں',
                    textDirection: TextDirection.rtl,
                    style: SukhanText.nastaleeq(
                      size: 14,
                      color: AppColors.secondary,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _avatarPlaceholder(),
                const SizedBox(height: 14),
                _LabelledField(
                  english: 'Pen name',
                  urdu: 'تخلص',
                  child: _UrduTextField(
                    controller: _penNameCtrl,
                    hint: 'حمزؔہ',
                  ),
                ),
                const SizedBox(height: 14),
                _LabelledField(
                  english: 'Full name',
                  urdu: 'پورا نام',
                  child: _PlainTextField(
                    controller: _fullNameCtrl,
                    hint: 'Your name',
                  ),
                ),
                const SizedBox(height: 14),
                _LabelledField(
                  english: 'Primary language',
                  urdu: 'بنیادی زبان',
                  child: _LanguageDropdown(
                    value: _languageCode,
                    onChanged: (c) => setState(() => _languageCode = c),
                  ),
                ),
                const SizedBox(height: 14),
                _LabelledField(
                  english: 'Short bio',
                  urdu: 'مختصر تعارف',
                  trailing: Text(
                    '${_bioCtrl.text.length} / $_bioMax',
                    style: SukhanText.eyebrow(
                      size: 10,
                      color: AppColors.inkSubtle,
                    ),
                  ),
                  child: _UrduTextField(
                    controller: _bioCtrl,
                    hint: 'کراچی سے غزل گو…',
                    maxLines: 3,
                    maxLength: _bioMax,
                  ),
                ),
                const SizedBox(height: 20),
                _submitButton(),
                const SizedBox(height: 8),
                Text(
                  'Instantly verified · you can edit anything later',
                  style: SukhanText.italic(
                    size: 11,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.paperSurface,
      surfaceTintColor: AppColors.paperSurface,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New poet page',
              style: SukhanText.display(
                size: 17,
                color: AppColors.textPrimaryLight,
                weight: FontWeight.w600,
                height: 1.1,
                letterSpacing: -0.17,
              )),
          Text('نیا شاعر صفحہ',
              textDirection: TextDirection.rtl,
              style: SukhanText.nastaleeq(
                size: 12,
                color: AppColors.textSecondaryLight,
              )),
        ],
      ),
      titleSpacing: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Text(
              '2 of 2',
              style: SukhanText.sans(
                size: 12,
                color: AppColors.inkSubtle,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.secondary,
          style: BorderStyle.solid,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                ),
                child: Text('ح',
                    style: TextStyle(
                      fontFamily: AppTypography.urduFontFamily,
                      fontSize: 24,
                      color: AppColors.secondaryLight,
                      height: 1,
                    )),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary,
                    border: Border.all(
                      color: AppColors.surfaceLight,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 12,
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
                Text('Add a profile image',
                    style: SukhanText.sans(
                      size: 13,
                      weight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    )),
                const SizedBox(height: 2),
                Text('JPG or PNG · square works best',
                    style: SukhanText.italic(
                      size: 11,
                      color: AppColors.textSecondaryLight,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    final canSubmit =
        _penNameCtrl.text.trim().isNotEmpty || _fullNameCtrl.text.trim().isNotEmpty;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: !canSubmit || _submitting ? null : _submit,
        icon: _submitting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.backgroundLight),
              )
            : const Icon(Icons.check, size: 16),
        label: Text(_submitting ? 'Creating…' : 'Make my page live'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.backgroundLight,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: SukhanText.sans(
            size: 14,
            weight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final pen = _penNameCtrl.text.trim();
    final full = _fullNameCtrl.text.trim();
    final bio = _bioCtrl.text.trim();
    final name = full.isNotEmpty ? full : pen;
    if (name.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final svc = ref.read(creatorServiceProvider);
      await svc.createPoetProfile(
        primaryLanguageCode: _languageCode,
        name: name,
        penName: pen.isEmpty ? null : pen,
        shortBio: bio.isEmpty ? null : bio,
      );

      // Silently refresh JWT so ROLE_POET appears in the access token.
      await ref.read(authProvider.notifier).refreshAccessToken();
      ref.invalidate(ownedPoetProvider);
      ref.invalidate(userProfileProvider);

      if (!mounted) return;
      _showSuccessSheet();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyApiMessage(e, CreatorAction.createPoetProfile)),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.greenSoft,
                ),
                child: const Icon(Icons.check, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 16),
              Text('Your poet page is live!',
                  style: SukhanText.display(
                    size: 22,
                    color: AppColors.textPrimaryLight,
                    weight: FontWeight.w600,
                    letterSpacing: -0.22,
                  )),
              const SizedBox(height: 6),
              Text('آپ کا صفحہ تیار ہے',
                  textDirection: TextDirection.rtl,
                  style: SukhanText.nastaleeq(
                    size: 15,
                    color: AppColors.secondary,
                  )),
              const SizedBox(height: 12),
              Text(
                'Compose your first poem, set up your gallery, or polish your bio whenever you like.',
                style: SukhanText.italic(
                  size: 13,
                  color: AppColors.textSecondaryLight,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(sheetCtx).pop();
                    if (mounted) {
                      context.go('/main');
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
                  child: const Text('Open my dashboard'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.filled, required this.total});
  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(total, (i) {
          final on = i < filled;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 4),
              height: 3,
              decoration: BoxDecoration(
                color: on ? AppColors.secondary : AppColors.dividerLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LabelledField extends StatelessWidget {
  const _LabelledField({
    required this.english,
    required this.urdu,
    required this.child,
    this.trailing,
  });

  final String english;
  final String urdu;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Row(
            children: [
              Text(english,
                  style: SukhanText.sans(
                    size: 12,
                    color: AppColors.textPrimaryLight,
                    weight: FontWeight.w600,
                  )),
              const SizedBox(width: 8),
              Text(urdu,
                  textDirection: TextDirection.rtl,
                  style: SukhanText.nastaleeq(
                    size: 12,
                    color: AppColors.secondary,
                  )),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _UrduTextField extends StatelessWidget {
  const _UrduTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.hairline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          minLines: 1,
          maxLength: maxLength,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: SukhanText.nastaleeq(
            size: 18,
            color: AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            counterText: '',
            isCollapsed: true,
            border: InputBorder.none,
            hintText: hint,
            hintStyle: SukhanText.nastaleeq(
              size: 16,
              color: AppColors.inkSubtle,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
          ),
        ),
      ),
    );
  }
}

class _PlainTextField extends StatelessWidget {
  const _PlainTextField({required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.hairline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: controller,
        style: SukhanText.sans(
          size: 14,
          color: AppColors.textPrimaryLight,
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: SukhanText.sans(
            size: 14,
            color: AppColors.inkSubtle,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.hairline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.inkSubtle),
          items: SupportedLanguage.all
              .map((l) => DropdownMenuItem(
                    value: l.code,
                    child: Row(
                      children: [
                        Text(l.englishName,
                            style: SukhanText.sans(
                              size: 14,
                              color: AppColors.textPrimaryLight,
                            )),
                        const SizedBox(width: 8),
                        Text(
                          l.nativeName,
                          textDirection: l.isUrdu
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          style: l.isUrdu
                              ? SukhanText.nastaleeq(
                                  size: 14,
                                  color: AppColors.secondary,
                                )
                              : SukhanText.sans(
                                  size: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
