import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';

class PoetrySectionHeader extends StatelessWidget {
  final String poetryType;
  final int count;
  final bool isExpanded;
  final VoidCallback onToggle;

  const PoetrySectionHeader({
    super.key,
    required this.poetryType,
    required this.count,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onToggle,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(_getPoetryTypeIcon(poetryType), size: 20),
                SizedBox(width: AppSpacing.sm),
                Text(
                  '${_getPoetryTypeLabel(poetryType)} ($count)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPoetryTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'GHAZAL':
        return Icons.auto_awesome;
      case 'NAZAM':
      case 'NAZM':
        return Icons.article;
      case 'VERSE':
        return Icons.format_quote;
      case 'RUBAI':
      case 'RUBAAI':
        return Icons.format_list_numbered;
      case 'AZAD_NAZAM':
        return Icons.article_outlined;
      case 'QATTA':
        return Icons.note;
      case 'MARSIYA':
        return Icons.text_snippet;
      case 'HAMD':
        return Icons.star;
      case 'NAAT':
        return Icons.brightness_7;
      default:
        return Icons.library_books;
    }
  }

  String _getPoetryTypeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'GHAZAL':
        return 'Ghazals';
      case 'NAZAM':
      case 'NAZM':
        return 'Nazams';
      case 'VERSE':
        return 'Verses';
      case 'RUBAI':
      case 'RUBAAI':
        return 'Rubais';
      case 'AZAD_NAZAM':
        return 'Azad Nazam';
      case 'QATTA':
        return 'Qatta';
      case 'MARSIYA':
        return 'Marsiya';
      case 'HAMD':
        return 'Hamd';
      case 'NAAT':
        return 'Naat';
      default:
        return type;
    }
  }
}
