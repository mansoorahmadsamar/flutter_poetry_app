import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import '../models/poem_model.dart';
import '../providers/poet_providers.dart';

class PoemCard extends ConsumerWidget {
  final PoemModel poem;
  final VoidCallback onTap;

  const PoemCard({
    super.key,
    required this.poem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrdu = ref.watch(selectedLanguageProvider) == 'ur';

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with Jameel Noori font for Urdu
              Text(
                poem.getDisplayTitle(isUrdu ? 'ur' : 'en'),
                style: isUrdu
                    ? TextStyle(
                        fontFamily: 'Jameel Noori Nastaleeq',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 2.0,
                      )
                    : Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
              ),
              SizedBox(height: AppSpacing.sm),

              // Content preview (first 3 lines) with Jameel Noori font
              Text(
                poem.getDisplayText(isUrdu ? 'ur' : 'en'),
                style: poem.isRTL(isUrdu ? 'ur' : 'en')
                    ? TextStyle(
                        fontFamily: 'Jameel Noori Nastaleeq',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        height: 2.2,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      )
                    : Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textDirection: poem.isRTL(isUrdu ? 'ur' : 'en')
                    ? TextDirection.rtl
                    : TextDirection.ltr,
              ),

              SizedBox(height: AppSpacing.md),

              // Metadata row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Poetry type badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPoetryTypeColor(poem.poetryType),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      poem.poetryTypeUrduName ?? _getPoetryTypeLabel(poem.poetryType),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Stats
                  Row(
                    children: [
                      Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        '${poem.likeCount}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(width: AppSpacing.md),
                      Icon(Icons.visibility, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        _formatNumber(poem.viewCount),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPoetryTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'GHAZAL':
        return Colors.purple;
      case 'NAZAM':
      case 'NAZM':
        return Colors.blue;
      case 'VERSE':
        return Colors.green;
      case 'RUBAI':
      case 'RUBAAI':
        return Colors.orange;
      case 'AZAD_NAZAM':
        return Colors.teal;
      case 'QATTA':
        return Colors.indigo;
      case 'MARSIYA':
        return Colors.deepPurple;
      case 'HAMD':
        return Colors.amber;
      case 'NAAT':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }

  String _getPoetryTypeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'GHAZAL':
        return 'Ghazal';
      case 'NAZAM':
      case 'NAZM':
        return 'Nazam';
      case 'VERSE':
        return 'Verse';
      case 'RUBAI':
      case 'RUBAAI':
        return 'Rubai';
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
      case 'MANQABAT':
        return 'Manqabat';
      case 'MASNAVI':
        return 'Masnavi';
      case 'QASIDA':
        return 'Qasida';
      default:
        return type;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
