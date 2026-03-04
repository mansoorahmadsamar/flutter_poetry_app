import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';

/// Coming soon placeholder state for Dictionary and Watch segments
///
/// Features:
/// - Center column layout
/// - Construction/upcoming icon
/// - Clear messaging
/// - Minimal design
class ComingSoonState extends StatelessWidget {
  final DiscoverSegment segment;

  const ComingSoonState({
    super.key,
    required this.segment,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = _getTitle();
    final description = _getDescription();

    return Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.3),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: TextStyle(
                fontSize: 15,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.black.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    return 'Coming Soon';
  }

  String _getDescription() {
    return 'This feature is coming soon';
  }
}
