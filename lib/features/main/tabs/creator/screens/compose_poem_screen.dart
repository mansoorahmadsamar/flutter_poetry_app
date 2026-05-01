import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/gold_divider.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/sukhan_chip.dart';
import '../models/creator_poem_model.dart';
import '../providers/creator_poems_provider.dart';
import '../providers/creator_providers.dart';

enum ComposeVariant { metaVisible, distractionFree, sherHelper }

extension on ComposeVariant {
  String get prefKey {
    switch (this) {
      case ComposeVariant.metaVisible:
        return 'meta-visible';
      case ComposeVariant.distractionFree:
        return 'distraction-free';
      case ComposeVariant.sherHelper:
        return 'sher-helper';
    }
  }
}

const _composeVariantPrefKey = 'creator.compose.variant';

/// Compose poem — 3 variants from the design.
/// User's last-used variant is persisted via SharedPreferences.
class ComposePoemScreen extends ConsumerStatefulWidget {
  const ComposePoemScreen({super.key});

  @override
  ConsumerState<ComposePoemScreen> createState() => _ComposePoemScreenState();
}

class _ComposePoemScreenState extends ConsumerState<ComposePoemScreen> {
  ComposeVariant _variant = ComposeVariant.metaVisible;
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _typeKey = 'GHAZAL';
  String _languageCode = 'ur';
  bool _isPublic = true;
  bool _publishing = false;
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _loadVariant();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadVariant() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _variant = composeVariantFromPref(prefs.getString(_composeVariantPrefKey));
    });
  }

  Future<void> _setVariant(ComposeVariant v) async {
    setState(() => _variant = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_composeVariantPrefKey, v.prefKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: _ComposeHeader(
          isPublishing: _publishing,
          onBack: () => Navigator.of(context).maybePop(),
          onPublish: _publish,
          onChangeVariant: _setVariant,
          variant: _variant,
        ),
      ),
      body: Column(
        children: [
          if (_variant != ComposeVariant.distractionFree)
            _MetaStrip(
              typeKey: _typeKey,
              onTypeChange: (t) => setState(() => _typeKey = t),
              languageCode: _languageCode,
              onLanguageChange: (l) => setState(() => _languageCode = l),
              isPublic: _isPublic,
              onIsPublicChange: (b) => setState(() => _isPublic = b),
              tags: _tags,
              onTagsChange: (t) => setState(() {
                _tags
                  ..clear()
                  ..addAll(t);
              }),
            ),
          _titleField(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: GoldDivider(width: 200, muted: true, ornament: '۞'),
          ),
          Expanded(
            child: _variant == ComposeVariant.sherHelper
                ? _SherCanvas(controller: _bodyCtrl)
                : _PlainCanvas(controller: _bodyCtrl),
          ),
          _KeyboardHintBar(
            languageCode: _languageCode,
            onLanguageChange: (l) => setState(() => _languageCode = l),
          ),
        ],
      ),
    );
  }

  Widget _titleField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: _titleCtrl,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: SukhanText.nastaleeq(
                size: 24,
                color: AppColors.textPrimaryLight,
                weight: FontWeight.w500,
                height: 1.3,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'عنوان…',
                hintStyle: SukhanText.nastaleeq(
                  size: 22,
                  color: AppColors.inkSubtle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Title · auto-translit on save',
            textAlign: TextAlign.right,
            style: SukhanText.italic(
              size: 12,
              color: AppColors.inkSubtle,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _publish() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and body are required')),
      );
      return;
    }
    setState(() => _publishing = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final poem = await ref.read(creatorServiceProvider).composePoem(
            title: title,
            content: body,
            poetryType: _typeKey,
            languageCode: _languageCode,
            tagSlugs: _tags,
            isPublic: _isPublic,
          );
      ref.read(creatorPoemsProvider.notifier).prepend(poem);
      ref.invalidate(creatorAnalyticsProvider);
      if (!mounted) return;
      router.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(_isPublic ? 'Poem published' : 'Saved as draft'),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not publish: $e')));
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }
}

ComposeVariant composeVariantFromPref(String? v) {
  switch (v) {
    case 'distraction-free':
      return ComposeVariant.distractionFree;
    case 'sher-helper':
      return ComposeVariant.sherHelper;
    default:
      return ComposeVariant.metaVisible;
  }
}

class _ComposeHeader extends StatelessWidget {
  const _ComposeHeader({
    required this.isPublishing,
    required this.onBack,
    required this.onPublish,
    required this.onChangeVariant,
    required this.variant,
  });

  final bool isPublishing;
  final VoidCallback onBack;
  final VoidCallback onPublish;
  final ValueChanged<ComposeVariant> onChangeVariant;
  final ComposeVariant variant;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paperSurface,
        border: Border(bottom: BorderSide(color: AppColors.dividerLight)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onBack,
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('New poem',
                        style: SukhanText.display(
                          size: 15,
                          color: AppColors.textPrimaryLight,
                          weight: FontWeight.w600,
                          height: 1.1,
                          letterSpacing: -0.15,
                        )),
                    Text('نئی شاعری',
                        textDirection: TextDirection.rtl,
                        style: SukhanText.nastaleeq(
                          size: 11,
                          color: AppColors.inkSubtle,
                        )),
                  ],
                ),
              ),
              PopupMenuButton<ComposeVariant>(
                position: PopupMenuPosition.under,
                icon: const Icon(Icons.tune, size: 18),
                initialValue: variant,
                onSelected: onChangeVariant,
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: ComposeVariant.metaVisible,
                    child: Text('Meta visible'),
                  ),
                  PopupMenuItem(
                    value: ComposeVariant.distractionFree,
                    child: Text('Distraction-free'),
                  ),
                  PopupMenuItem(
                    value: ComposeVariant.sherHelper,
                    child: Text('Sher helper ✦'),
                  ),
                ],
              ),
              FilledButton(
                onPressed: isPublishing ? null : onPublish,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundLight,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  shape: const StadiumBorder(),
                  textStyle: SukhanText.sans(
                    size: 12,
                    weight: FontWeight.w600,
                  ),
                ),
                child: isPublishing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.backgroundLight),
                      )
                    : const Text('Publish'),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaStrip extends StatelessWidget {
  const _MetaStrip({
    required this.typeKey,
    required this.onTypeChange,
    required this.languageCode,
    required this.onLanguageChange,
    required this.isPublic,
    required this.onIsPublicChange,
    required this.tags,
    required this.onTagsChange,
  });

  final String typeKey;
  final ValueChanged<String> onTypeChange;
  final String languageCode;
  final ValueChanged<String> onLanguageChange;
  final bool isPublic;
  final ValueChanged<bool> onIsPublicChange;
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChange;

  @override
  Widget build(BuildContext context) {
    final type = PoetryType.byKey(typeKey);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paperSurface,
        border: Border(bottom: BorderSide(color: AppColors.dividerLight)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            PopupMenuButton<String>(
              position: PopupMenuPosition.under,
              initialValue: typeKey,
              onSelected: onTypeChange,
              itemBuilder: (_) => PoetryType.all
                  .map((p) => PopupMenuItem(
                        value: p.apiKey,
                        child: Row(
                          children: [
                            Text(p.englishLabel,
                                style: SukhanText.sans(
                                  size: 13,
                                  color: AppColors.textPrimaryLight,
                                )),
                            const SizedBox(width: 8),
                            Text(p.urduLabel,
                                textDirection: TextDirection.rtl,
                                style: SukhanText.nastaleeq(
                                  size: 14,
                                  color: AppColors.secondary,
                                )),
                          ],
                        ),
                      ))
                  .toList(),
              child: SukhanChip(
                label: type.urduLabel,
                variant: SukhanChipVariant.green,
                fontFamily: AppTypography.urduFontFamily,
                fontSize: 12,
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(width: 6),
            PopupMenuButton<String>(
              position: PopupMenuPosition.under,
              initialValue: languageCode,
              onSelected: onLanguageChange,
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'ur', child: Text('Urdu')),
                PopupMenuItem(value: 'en', child: Text('English')),
                PopupMenuItem(value: 'hi', child: Text('Hindi')),
                PopupMenuItem(value: 'fa', child: Text('Persian')),
              ],
              child: SukhanChip(
                label: languageCode.toUpperCase(),
                variant: SukhanChipVariant.outline,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 6),
            for (final tag in tags) ...[
              SukhanChip(
                label: '# $tag',
                variant: SukhanChipVariant.ghost,
                fontSize: 11,
                onTap: () => onTagsChange(
                  tags.where((t) => t != tag).toList(),
                ),
              ),
              const SizedBox(width: 6),
            ],
            SukhanChip(
              label: '+ Add tag',
              variant: SukhanChipVariant.ghost,
              fontSize: 11,
              onTap: () async {
                final added = await _promptForTag(context);
                if (added != null && added.isNotEmpty) {
                  onTagsChange([...tags, added]);
                }
              },
            ),
            const SizedBox(width: 6),
            SukhanChip(
              label: isPublic ? '🌍 Public' : '🔒 Draft',
              variant: SukhanChipVariant.outline,
              fontSize: 11,
              onTap: () => onIsPublicChange(!isPublic),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _promptForTag(BuildContext context) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: const Text('Add tag'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'theme, mood, season…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(ctrl.text.trim()),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _PlainCanvas extends StatelessWidget {
  const _PlainCanvas({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          controller: controller,
          maxLines: null,
          expands: true,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.multiline,
          style: SukhanText.nastaleeq(
            size: 20,
            color: AppColors.textPrimaryLight,
            height: 2.3,
          ),
          decoration: InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            hintText: 'غزل، نظم یا قطعہ لکھیں…',
            hintStyle: SukhanText.nastaleeq(
              size: 18,
              color: AppColors.inkSubtle,
              height: 2.3,
            ),
          ),
        ),
      ),
    );
  }
}

/// Sher helper — splits the body by blank lines into couplet cards with
/// gold left guides. Each block is a `\n\n`-separated section.
class _SherCanvas extends StatefulWidget {
  const _SherCanvas({required this.controller});
  final TextEditingController controller;

  @override
  State<_SherCanvas> createState() => _SherCanvasState();
}

class _SherCanvasState extends State<_SherCanvas> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final blocks = widget.controller.text.split('\n\n');
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
          children: [
            for (var i = 0; i < blocks.length; i++)
              if (blocks[i].trim().isNotEmpty)
                _ShereTile(index: i, content: blocks[i]),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.hairline),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.centerRight,
              child: Text(
                '+ نیا شعر شامل کریں',
                textDirection: TextDirection.rtl,
                style: SukhanText.italic(
                  size: 12,
                  color: AppColors.inkSubtle,
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
        // Hidden text field driving the canvas — focus stays here when typing.
        Positioned.fill(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: widget.controller,
              maxLines: null,
              expands: true,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              style: SukhanText.nastaleeq(
                size: 20,
                color: AppColors.textPrimaryLight.withValues(alpha: 0),
                height: 2.3,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.fromLTRB(18, 8, 18, 16),
                fillColor: Colors.transparent,
              ),
              cursorColor: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ShereTile extends StatelessWidget {
  const _ShereTile({required this.index, required this.content});
  final int index;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.goldSoft.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: const Border(
          left: BorderSide(color: AppColors.secondary, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SHER ${(index + 1).toString().padLeft(2, '0')}',
            style: SukhanText.eyebrow(
              color: AppColors.secondary,
              size: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: SukhanText.nastaleeq(
              size: 19,
              color: AppColors.textPrimaryLight,
              height: 2.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyboardHintBar extends StatelessWidget {
  const _KeyboardHintBar({
    required this.languageCode,
    required this.onLanguageChange,
  });

  final String languageCode;
  final ValueChanged<String> onLanguageChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paperSurface,
        border: Border(top: BorderSide(color: AppColors.dividerLight)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          for (final entry in const [
            ['ur', 'اردو'],
            ['ROMAN', 'Roman'],
            ['en', 'EN'],
          ]) ...[
            SukhanChip(
              label: entry[1],
              variant: languageCode == entry[0]
                  ? SukhanChipVariant.green
                  : SukhanChipVariant.ghost,
              fontSize: 10,
              fontFamily:
                  entry[0] == 'ur' ? AppTypography.urduFontFamily : null,
              textDirection: entry[0] == 'ur'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              onTap: () => onLanguageChange(entry[0] == 'ROMAN' ? 'ur' : entry[0]),
            ),
            const SizedBox(width: 6),
          ],
          const Spacer(),
          Text(
            '↵ MISRA · ↵↵ SHER',
            style: SukhanText.eyebrow(
              size: 9,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
