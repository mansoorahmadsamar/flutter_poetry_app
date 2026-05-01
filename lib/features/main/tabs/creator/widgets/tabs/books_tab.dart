import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/corner_frame.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/gold_divider.dart';
import '../../models/creator_book_model.dart';
import '../../providers/creator_providers.dart';

/// Books tab — list rows with cover thumbnail + PDF/EPUB download stats.
/// Empty list renders the Borges-paraphrase manuscript card from the design.
class BooksTab extends ConsumerWidget {
  const BooksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(creatorBooksProvider);
    return booksAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Could not load books: $e',
              style: SukhanText.italic(
                size: 12,
                color: AppColors.error,
              )),
        ),
      ),
      data: (books) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
          children: [
            Row(
              children: [
                Text(
                  '${books.length} BOOKS',
                  style: SukhanText.eyebrow(color: AppColors.secondary),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () =>
                      GoRouter.of(context).push('/main/creator/books/new'),
                  icon: const Icon(Icons.add, size: 12),
                  label: const Text('Upload'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: const StadiumBorder(),
                    textStyle: SukhanText.sans(
                      size: 11,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...books.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BookTile(book: b),
                )),
            if (books.isEmpty) const _BorgesEmpty(),
          ],
        );
      },
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book});
  final CreatorBook book;

  @override
  Widget build(BuildContext context) {
    final initial = book.title.isEmpty
        ? 'ک'
        : String.fromCharCode(book.title.runes.first);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerLight),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: book.coverUrl != null
                  ? DecorationImage(
                      image: NetworkImage(book.coverUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              gradient: book.coverUrl == null
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryDark, AppColors.primary],
                    )
                  : null,
            ),
            padding: const EdgeInsets.all(6),
            child: book.coverUrl == null
                ? Text(
                    initial,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.urduFontFamily,
                      fontSize: 18,
                      color: AppColors.secondaryLight,
                      height: 1.2,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  textDirection: TextDirection.rtl,
                  style: SukhanText.nastaleeq(
                    size: 16,
                    color: AppColors.textPrimaryLight,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  '${book.publisher ?? ""}${book.yearPublished != null ? " · ${book.yearPublished}" : ""}',
                  style: SukhanText.italic(
                    size: 11,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (book.hasPdf) ...[
                      const Icon(Icons.picture_as_pdf,
                          size: 11, color: AppColors.inkSubtle),
                      const SizedBox(width: 4),
                      Text(
                        'PDF · ${book.pdfDownloads}',
                        style: SukhanText.sans(
                          size: 10,
                          color: AppColors.inkSubtle,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (book.hasEpub) ...[
                      const Icon(Icons.menu_book_outlined,
                          size: 11, color: AppColors.inkSubtle),
                      const SizedBox(width: 4),
                      Text(
                        'EPUB · ${book.epubDownloads}',
                        style: SukhanText.sans(
                          size: 10,
                          color: AppColors.inkSubtle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, size: 16, color: AppColors.inkSubtle),
        ],
      ),
    );
  }
}

class _BorgesEmpty extends StatelessWidget {
  const _BorgesEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: CornerFrame(
        inset: 12,
        length: 18,
        color: AppColors.secondary,
        decoration: BoxDecoration(
          color: AppColors.paperSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.secondary),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          children: [
            Text(
              '"کتاب وہ دروازہ ہے جو ہر بار کھلتا ہے"',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: SukhanText.nastaleeq(
                size: 14,
                color: AppColors.primary,
                height: 1.9,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '— Borges, paraphrased',
              style: SukhanText.italic(
                size: 10,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),
            const GoldDivider(width: 80, ornament: null, muted: true),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () =>
                  GoRouter.of(context).push('/main/creator/books/new'),
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Upload your first book'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.backgroundLight,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: const StadiumBorder(),
                elevation: 0,
                textStyle: SukhanText.sans(
                  size: 11,
                  weight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
