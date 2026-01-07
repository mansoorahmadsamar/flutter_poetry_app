import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';

/// Poet result card for search results
///
/// Features:
/// - Circular avatar with poet image or initials
/// - Poet name in Nastaliq (if Urdu)
/// - Era dates below name
/// - Warm parchment background
/// - Rounded corners with subtle shadow
class PoetResultCard extends ConsumerWidget {
  final PoetSummary poet;
  final String? era;

  const PoetResultCard({
    super.key,
    required this.poet,
    this.era,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrdu = _isUrduText(poet.name);

    return Container(
      width: 160,
      margin: EdgeInsets.only(right: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            'poet-detail',
            pathParameters: {'publicId': poet.publicId},
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular avatar
              _buildAvatar(poet, isDark, isUrdu),

              SizedBox(height: AppSpacing.md),

              // Poet name
              Text(
                poet.name,
                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isUrdu ? 21 : 16,
                  fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                  height: isUrdu ? 1.8 : 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (era != null) ...[
                SizedBox(height: AppSpacing.xs),
                Text(
                  era!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(PoetSummary poet, bool isDark, bool isUrdu) {
    if (poet.profileImageUrl != null && poet.profileImageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(poet.profileImageUrl!),
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      );
    }

    // Fallback to initials
    return CircleAvatar(
      radius: 40,
      backgroundColor: isDark
          ? AppColors.primary.withValues(alpha: 0.2)
          : AppColors.primary.withValues(alpha: 0.1),
      child: Text(
        poet.name.isNotEmpty ? poet.name[0] : 'P',
        style: TextStyle(
          fontSize: 28,
          fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  bool _isUrduText(String text) {
    final urduPattern = RegExp(r'[\u0600-\u06FF]');
    final urduMatches = urduPattern.allMatches(text).length;
    return urduMatches > text.length / 3;
  }
}
