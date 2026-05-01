import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/sukhan_chip.dart';
import '../models/creator_poem_model.dart';
import '../providers/creator_poems_provider.dart';
import '../providers/creator_providers.dart';

/// Edit a poem's metadata. Per the API docs, only `isPublic`,
/// `yearWritten`, `poetryType`, and `tagSlugs` can be modified — title
/// and content are immutable after creation.
class EditPoemScreen extends ConsumerStatefulWidget {
  const EditPoemScreen({super.key, required this.publicId});
  final String publicId;

  @override
  ConsumerState<EditPoemScreen> createState() => _EditPoemScreenState();
}

class _EditPoemScreenState extends ConsumerState<EditPoemScreen> {
  CreatorPoem? _poem;
  bool _saving = false;
  late String _typeKey;
  late bool _isPublic;
  final _yearCtrl = TextEditingController();
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    super.dispose();
  }

  void _hydrate() {
    final state = ref.read(creatorPoemsProvider);
    final p = state.poems
        .firstWhere((p) => p.publicId == widget.publicId, orElse: () => CreatorPoem(
              publicId: widget.publicId,
              title: '',
              poetryType: 'GHAZAL',
            ));
    _poem = p;
    _typeKey = p.poetryType;
    _isPublic = p.isPublic;
    _tags
      ..clear()
      ..addAll(p.tagSlugs);
  }

  @override
  Widget build(BuildContext context) {
    final p = _poem;
    if (p == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.paperSurface,
        surfaceTintColor: AppColors.paperSurface,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        title: Text('Edit poem', style: SukhanText.display(
          size: 17,
          color: AppColors.textPrimaryLight,
          weight: FontWeight.w600,
        )),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Save',
                style: SukhanText.sans(
                  size: 13,
                  color: AppColors.secondary,
                  weight: FontWeight.w600,
                )),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Read-only preview of title
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: AppColors.paperSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.dividerLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  p.title,
                  textDirection: TextDirection.rtl,
                  style: SukhanText.nastaleeq(
                    size: 20,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Title and content can only be set at compose time.',
                  style: SukhanText.italic(
                    size: 11,
                    color: AppColors.inkSubtle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _label('Visibility', 'دکھاوا'),
          const SizedBox(height: 6),
          SwitchListTile.adaptive(
            value: _isPublic,
            onChanged: (v) => setState(() => _isPublic = v),
            tileColor: AppColors.surfaceLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppColors.dividerLight),
            ),
            activeThumbColor: AppColors.primary,
            title: Text(_isPublic ? 'Public' : 'Draft',
                style: SukhanText.sans(
                  size: 13,
                  weight: FontWeight.w600,
                )),
            subtitle: Text(
              _isPublic ? 'Visible to readers and search.' : 'Only you can see this.',
              style: SukhanText.italic(
                size: 11,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _label('Type', 'صنف'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: PoetryType.all
                .map((t) => SukhanChip(
                      label: t.urduLabel,
                      variant: _typeKey == t.apiKey
                          ? SukhanChipVariant.green
                          : SukhanChipVariant.ghost,
                      fontFamily: AppTypography.urduFontFamily,
                      textDirection: TextDirection.rtl,
                      fontSize: 12,
                      onTap: () => setState(() => _typeKey = t.apiKey),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          _label('Year written', 'سنہ تخلیق'),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.hairline),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: _yearCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'YYYY',
                contentPadding: EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String en, String ur) {
    return Row(
      children: [
        Text(en,
            style: SukhanText.sans(
              size: 12,
              color: AppColors.textPrimaryLight,
              weight: FontWeight.w600,
            )),
        const SizedBox(width: 8),
        Text(ur,
            textDirection: TextDirection.rtl,
            style: SukhanText.nastaleeq(
              size: 12,
              color: AppColors.secondary,
            )),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final patch = <String, dynamic>{
        'isPublic': _isPublic,
        'poetryType': _typeKey,
        'tagSlugs': _tags,
      };
      final year = int.tryParse(_yearCtrl.text.trim());
      if (year != null) patch['yearWritten'] = year;

      final updated = await ref
          .read(creatorServiceProvider)
          .updatePoem(widget.publicId, patch);
      ref.read(creatorPoemsProvider.notifier).replace(updated);
      router.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Poem updated')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not update: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
