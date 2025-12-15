import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';

class ShareOptionsSheet extends StatelessWidget {
  final String coupletId;

  const ShareOptionsSheet({
    super.key,
    required this.coupletId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),

            Text(
              'Share Couplet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: AppSpacing.lg),

            // Share as text option
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Share as Text'),
              subtitle: const Text('Share verses as plain text'),
              onTap: () {
                Navigator.pop(context);
                _shareAsText(context);
              },
            ),

            // Share as image option (NEW)
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Share as Image'),
              subtitle: const Text('Use templates or custom background'),
              trailing: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Text(
                  'New',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/image-poetry/generate/$coupletId',
                );
              },
            ),

            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _shareAsText(BuildContext context) {
    // TODO: Implement text sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text sharing coming soon')),
    );
  }
}
