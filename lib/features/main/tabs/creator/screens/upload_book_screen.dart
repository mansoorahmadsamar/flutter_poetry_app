import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/sukhan_chip.dart';
import '../providers/creator_providers.dart';

/// Upload a book — title, year, description, optional PDF/EPUB binary,
/// optional cover image. Multipart submit to /api/me/poet/books.
class UploadBookScreen extends ConsumerStatefulWidget {
  const UploadBookScreen({super.key});

  @override
  ConsumerState<UploadBookScreen> createState() => _UploadBookScreenState();
}

class _UploadBookScreenState extends ConsumerState<UploadBookScreen> {
  final _titleCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _publisherCtrl = TextEditingController();
  final String _languageCode = 'ur';
  String? _filePath;
  String? _fileType;
  String? _coverPath;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _yearCtrl.dispose();
    _descCtrl.dispose();
    _publisherCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Text('New book',
                style: SukhanText.display(
                  size: 17,
                  color: AppColors.textPrimaryLight,
                  weight: FontWeight.w600,
                  height: 1.1,
                )),
            Text('نئی کتاب',
                textDirection: TextDirection.rtl,
                style: SukhanText.nastaleeq(
                  size: 12,
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
                weight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _Field(label: 'Title', urdu: 'عنوان', controller: _titleCtrl, isUrdu: true),
          const SizedBox(height: 12),
          _Field(label: 'Year', urdu: 'سنہ', controller: _yearCtrl, isUrdu: false, keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          _Field(label: 'Publisher', urdu: 'ناشر', controller: _publisherCtrl, isUrdu: true),
          const SizedBox(height: 12),
          _Field(
            label: 'Description',
            urdu: 'تفصیل',
            controller: _descCtrl,
            isUrdu: true,
            minLines: 3,
            maxLines: 6,
          ),
          const SizedBox(height: 16),
          _filePickerCard(),
          const SizedBox(height: 12),
          _coverPickerCard(),
        ],
      ),
    );
  }

  Widget _filePickerCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerLight),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Book file',
                  style: SukhanText.sans(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  )),
              const SizedBox(width: 8),
              Text('کتاب کی فائل',
                  textDirection: TextDirection.rtl,
                  style: SukhanText.nastaleeq(
                    size: 12,
                    color: AppColors.secondary,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          if (_filePath != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _filePath!.split('/').last,
                      style: SukhanText.sans(
                        size: 12,
                        color: AppColors.textPrimaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_fileType != null) ...[
                    const SizedBox(width: 8),
                    SukhanChip(
                      label: _fileType!,
                      variant: SukhanChipVariant.gold,
                      fontSize: 9,
                    ),
                  ],
                ],
              ),
            ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _pickFile('PDF'),
                icon: const Icon(Icons.picture_as_pdf, size: 14),
                label: const Text('PDF'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: const StadiumBorder(),
                  textStyle: SukhanText.sans(
                    size: 11,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _pickFile('EPUB'),
                icon: const Icon(Icons.menu_book_outlined, size: 14),
                label: const Text('EPUB'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: const StadiumBorder(),
                  textStyle: SukhanText.sans(
                    size: 11,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              if (_filePath != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppColors.error),
                  onPressed: () => setState(() {
                    _filePath = null;
                    _fileType = null;
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _coverPickerCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerLight),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Cover image',
                  style: SukhanText.sans(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  )),
              const SizedBox(width: 8),
              Text('سرورق',
                  textDirection: TextDirection.rtl,
                  style: SukhanText.nastaleeq(
                    size: 12,
                    color: AppColors.secondary,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          if (_coverPath != null)
            Text(
              _coverPath!.split('/').last,
              style: SukhanText.italic(
                size: 12,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickCover,
            icon: const Icon(Icons.image_outlined, size: 14),
            label: Text(_coverPath == null ? 'Pick cover' : 'Replace cover'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: const StadiumBorder(),
              textStyle: SukhanText.sans(
                size: 11,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: type == 'PDF' ? ['pdf'] : ['epub'],
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.first;
    if (f.path == null) return;
    setState(() {
      _filePath = f.path;
      _fileType = type;
    });
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 90,
    );
    if (picked == null) return;
    setState(() => _coverPath = picked.path);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final svc = ref.read(creatorServiceProvider);
      final book = await svc.createBook(
        title: title,
        yearPublished: int.tryParse(_yearCtrl.text.trim()),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        publisher:
            _publisherCtrl.text.trim().isEmpty ? null : _publisherCtrl.text.trim(),
        languageCode: _languageCode,
        filePath: _filePath,
        fileType: _fileType,
      );
      if (_coverPath != null) {
        await svc.uploadBookFile(
          publicId: book.publicId,
          filePath: _coverPath!,
          kind: 'cover',
        );
      }
      ref.invalidate(creatorBooksProvider);
      router.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Book uploaded')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.urdu,
    required this.controller,
    required this.isUrdu,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
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
              Text(label,
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
                contentPadding: EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
