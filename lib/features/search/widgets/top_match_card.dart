import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';

/// Top match card for autocomplete suggestions
///
/// Features:
/// - Shows above grouped autocomplete results
/// - Row layout with avatar, content, arrow
/// - Supports Poet and Poem types
/// - Multi-language display (Urdu/English/Hindi)
/// - Primary green accent
class TopMatchCard extends StatelessWidget {
  final String title;
  final String type; // "poet" or "poem"
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback onTap;

  const TopMatchCard({
    super.key,
    required this.title,
    required this.type,
    this.subtitle,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrdu = _isUrduText(title);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Leading: Avatar or Icon
              _buildLeadingAvatar(isDark),

              SizedBox(width: AppSpacing.md),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getTypeLabel(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.xs),

                    // Title/Name
                    Text(
                      title,
                      textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                      style: TextStyle(
                        fontSize: isUrdu ? 21 : 18,
                        fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                        height: isUrdu ? 1.8 : 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Subtitle (if available)
                    if (subtitle != null) ...[
                      SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.black.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(width: AppSpacing.sm),

              // Trailing: Arrow
              Icon(
                Icons.arrow_forward,
                size: 20,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingAvatar(bool isDark) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      );
    }

    // Fallback icon
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        type == 'poet' ? Icons.person : Icons.book,
        size: 30,
        color: AppColors.primary,
      ),
    );
  }

  String _getTypeLabel() {
    switch (type.toLowerCase()) {
      case 'poet':
        return 'POET / شاعر';
      case 'poem':
        return 'POEM / نظم';
      default:
        return type.toUpperCase();
    }
  }

  /// Detect if text is primarily Urdu
  bool _isUrduText(String text) {
    final urduPattern = RegExp(r'[\u0600-\u06FF]');
    final urduMatches = urduPattern.allMatches(text).length;
    return urduMatches > text.length / 3;
  }
}
