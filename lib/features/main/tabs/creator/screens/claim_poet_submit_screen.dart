import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/portrait.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/sukhan_chip.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poet_providers.dart';
import '../providers/creator_providers.dart';
import '../utils/api_error_messages.dart';

/// Submit proof URL + optional note for an existing-poet claim.
/// Loads the target poet's profile to render the "claiming" header card.
class ClaimPoetSubmitScreen extends ConsumerStatefulWidget {
  const ClaimPoetSubmitScreen({super.key, required this.publicId});
  final String publicId;

  @override
  ConsumerState<ClaimPoetSubmitScreen> createState() =>
      _ClaimPoetSubmitScreenState();
}

class _ClaimPoetSubmitScreenState extends ConsumerState<ClaimPoetSubmitScreen> {
  final _proofCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _proofCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final poetAsync = ref.watch(poetDetailProvider(widget.publicId));
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _appBar(),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          poetAsync.when(
            data: (p) => _ClaimingCard(
              urduName: p.name,
              romanName: p.shortBio,
              years: _years(p.birthYear, p.deathYear ?? 0),
              imageUrl: p.profileImageUrl,
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text("Couldn't load poet info — please try again.",
                  style: SukhanText.italic(
                    size: 12,
                    color: AppColors.error,
                  )),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Send us proof',
                    style: SukhanText.display(
                      size: 18,
                      color: AppColors.textPrimaryLight,
                      weight: FontWeight.w600,
                      letterSpacing: -0.18,
                    )),
                const SizedBox(height: 4),
                Text('ایک ربط جو ثابت کرے کہ آپ ہی ہیں',
                    textDirection: TextDirection.rtl,
                    style: SukhanText.nastaleeq(
                      size: 13,
                      color: AppColors.textSecondaryLight,
                    )),
                const SizedBox(height: 8),
                Text(
                  'Editors review within 48 hours. Acceptable: a personal site, a verified social profile, or a publisher page that mentions you.',
                  style: SukhanText.italic(
                    size: 12,
                    color: AppColors.textSecondaryLight,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _LabelledRow(
                  english: 'Proof URL',
                  urdu: 'تصدیقی ربط',
                  child: _UrlField(controller: _proofCtrl),
                ),
                const SizedBox(height: 14),
                _LabelledRow(
                  english: 'Note to editors',
                  urdu: '(optional)',
                  urduIsHint: true,
                  child: _NoteField(controller: _noteCtrl),
                ),
                const SizedBox(height: 16),
                _whatHappensNextCallout(),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
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
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.backgroundLight,
                            ),
                          )
                        : const Text('Submit for review'),
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

  PreferredSizeWidget _appBar() {
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
          Text("Verify it's you",
              style: SukhanText.display(
                size: 17,
                color: AppColors.textPrimaryLight,
                weight: FontWeight.w600,
                height: 1.1,
                letterSpacing: -0.17,
              )),
          Text('تصدیق کریں',
              textDirection: TextDirection.rtl,
              style: SukhanText.nastaleeq(
                size: 12,
                color: AppColors.textSecondaryLight,
              )),
        ],
      ),
      titleSpacing: 0,
    );
  }

  String _years(int birth, int death) {
    if (birth <= 0 && death <= 0) return '';
    if (death > 0 && birth > 0) return '$birth – $death';
    if (birth > 0) return '$birth – ';
    return '$death';
  }

  Widget _whatHappensNextCallout() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.goldSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WHAT HAPPENS NEXT',
              style: SukhanText.eyebrow(color: AppColors.secondaryDark)),
          const SizedBox(height: 6),
          Text(
            "Editors review within 48 hours. You'll see a banner on your profile until it resolves. We'll notify you the moment it's approved.",
            style: SukhanText.italic(
              size: 12,
              color: AppColors.textPrimaryLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final url = _proofCtrl.text.trim();
    if (url.isEmpty || !url.startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid http(s) URL')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(creatorServiceProvider).claimPoet(
            publicId: widget.publicId,
            proofUrl: url,
            note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          );
      ref.invalidate(ownedPoetProvider);
      if (!mounted) return;
      _showPendingSheet();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyApiMessage(e, CreatorAction.claimPoet))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showPendingSheet() {
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
                  color: AppColors.goldSoft,
                ),
                child: Text(
                  '۞',
                  style: TextStyle(
                    fontFamily: AppTypography.urduFontFamily,
                    fontSize: 26,
                    color: AppColors.secondary,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text("Submitted — we'll review within 48h",
                  style: SukhanText.display(
                    size: 22,
                    color: AppColors.textPrimaryLight,
                    weight: FontWeight.w600,
                    letterSpacing: -0.22,
                  )),
              const SizedBox(height: 6),
              Text('درخواست بھیج دی گئی',
                  textDirection: TextDirection.rtl,
                  style: SukhanText.nastaleeq(
                    size: 15,
                    color: AppColors.secondaryDark,
                  )),
              const SizedBox(height: 12),
              Text(
                'Your profile will show a Claim in Review banner until an editor approves the claim. We will notify you the moment that happens.',
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
                    if (mounted) context.go('/main');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.backgroundLight,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back to profile'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ClaimingCard extends StatelessWidget {
  const _ClaimingCard({
    required this.urduName,
    required this.romanName,
    required this.years,
    this.imageUrl,
  });

  final String urduName;
  final String? romanName;
  final String years;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final initial = urduName.isEmpty
        ? 'م'
        : String.fromCharCode(urduName.runes.first);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.secondary),
        ),
        child: Row(
          children: [
            Portrait(
              size: 52,
              initial: initial,
              hue: PortraitHue.gold,
              ring: true,
              imageUrl: imageUrl,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    urduName,
                    textDirection: TextDirection.rtl,
                    style: SukhanText.nastaleeq(
                      size: 18,
                      color: AppColors.textPrimaryLight,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [if (romanName != null) romanName, if (years.isNotEmpty) years]
                        .whereType<String>()
                        .join(' · '),
                    style: SukhanText.italic(
                      size: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const SukhanChip(
              label: 'CLAIMING',
              variant: SukhanChipVariant.gold,
              fontSize: 9,
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelledRow extends StatelessWidget {
  const _LabelledRow({
    required this.english,
    required this.urdu,
    required this.child,
    this.urduIsHint = false,
  });

  final String english;
  final String urdu;
  final Widget child;
  final bool urduIsHint;

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
              const SizedBox(width: 6),
              Text(urdu,
                  textDirection:
                      urduIsHint ? TextDirection.ltr : TextDirection.rtl,
                  style: urduIsHint
                      ? SukhanText.sans(size: 11, color: AppColors.inkSubtle)
                      : SukhanText.nastaleeq(size: 12, color: AppColors.secondary)),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _UrlField extends StatelessWidget {
  const _UrlField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.link, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.url,
              style: SukhanText.sans(
                size: 13,
                color: AppColors.textPrimaryLight,
              ).copyWith(fontFamily: 'monospace'),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'https://yourname.example.com',
                hintStyle: SukhanText.sans(size: 12, color: AppColors.inkSubtle)
                    .copyWith(fontFamily: 'monospace'),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.hairline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      constraints: const BoxConstraints(minHeight: 64),
      child: TextField(
        controller: controller,
        maxLines: 3,
        minLines: 2,
        style: SukhanText.sans(
          size: 13,
          color: AppColors.textPrimaryLight,
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: 'About page links · Press club bio · etc.',
          hintStyle: SukhanText.sans(size: 12, color: AppColors.inkSubtle),
        ),
      ),
    );
  }
}
