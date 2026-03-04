import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/widgets/standard_app_bar.dart';
import '../providers/app_content_providers.dart';

/// Detail screen for app content pages (About, Privacy Policy, Terms, etc.)
class AppContentDetailScreen extends ConsumerWidget {
  final String contentKey;
  final String title;

  const AppContentDetailScreen({
    super.key,
    required this.contentKey,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(appContentDetailProvider(contentKey));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StandardAppBar(title: title),
      body: contentAsync.when(
        data: (content) => _buildContent(context, content.content, content.languageCode),
        loading: () => _buildLoading(),
        error: (error, _) => _buildError(context, ref),
      ),
    );
  }

  Widget _buildContent(BuildContext context, String content, String languageCode) {
    final isRtl = languageCode == 'ur';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(
          content,
          style: isRtl
              ? GoogleFonts.notoNastaliqUrdu(
                  fontSize: 16,
                  height: 2.2,
                  color: const Color(0xFF2C2C2C),
                )
              : GoogleFonts.roboto(
                  fontSize: 15,
                  height: 1.7,
                  color: const Color(0xFF2C2C2C),
                ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load content',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => ref.invalidate(appContentDetailProvider(contentKey)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
