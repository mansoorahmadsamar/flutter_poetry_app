import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/poet_providers.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';

class PoetBooksTab extends ConsumerWidget {
  final String publicId;

  const PoetBooksTab({super.key, required this.publicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(poetBooksProvider(publicId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return books.when(
      data: (bookList) {
        if (bookList.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text('No books available'),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(AppSpacing.md),
          itemCount: bookList.length,
          itemBuilder: (context, index) {
            final book = bookList[index];
            return Card(
              margin: EdgeInsets.only(bottom: AppSpacing.md),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Cover
                    if (book.coverImageUrl != null)
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        child: CachedNetworkImage(
                          imageUrl: book.coverImageUrl!,
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 80,
                            height: 120,
                            color: isDark
                                ? Colors.grey[800]
                                : Colors.grey[300],
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 80,
                            height: 120,
                            color: isDark
                                ? Colors.grey[800]
                                : Colors.grey[300],
                            child: Icon(Icons.book),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 80,
                        height: 120,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey[800]
                              : Colors.grey[300],
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Icon(Icons.book),
                      ),
                    SizedBox(width: AppSpacing.lg),
                    // Book Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (book.subtitle != null) ...[
                            SizedBox(height: 4),
                            Text(
                              book.subtitle!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontStyle: FontStyle.italic),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          SizedBox(height: AppSpacing.sm),
                          // Book Meta
                          Row(
                            children: [
                              if (book.yearPublished != null) ...[
                                Icon(Icons.calendar_today,
                                    size: 14, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  '${book.yearPublished}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                                ),
                                SizedBox(width: AppSpacing.md),
                              ],
                              Icon(Icons.language,
                                  size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                book.languageName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall,
                              ),
                            ],
                          ),
                          if (book.description != null) ...[
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              book.description!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          SizedBox(height: AppSpacing.sm),
                          // Book Type Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSm),
                            ),
                            child: Text(
                              _getBookTypeLabel(book.bookType),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Text('Failed to load books'),
        ),
      ),
    );
  }

  String _getBookTypeLabel(String bookType) {
    switch (bookType) {
      case 'POETRY_COLLECTION':
        return 'Poetry Collection';
      case 'BIOGRAPHY':
        return 'Biography';
      case 'CRITICISM':
        return 'Literary Criticism';
      case 'ANTHOLOGY':
        return 'Anthology';
      default:
        return bookType;
    }
  }
}
