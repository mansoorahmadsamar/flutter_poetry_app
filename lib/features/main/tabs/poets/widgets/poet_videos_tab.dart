import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/poet_providers.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';

class PoetVideosTab extends ConsumerWidget {
  final String publicId;

  const PoetVideosTab({super.key, required this.publicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videos = ref.watch(poetVideosProvider(publicId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return videos.when(
      data: (videoList) {
        if (videoList.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text('No videos available'),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(AppSpacing.md),
          itemCount: videoList.length,
          itemBuilder: (context, index) {
            final video = videoList[index];
            return Card(
              margin: EdgeInsets.only(bottom: AppSpacing.md),
              child: InkWell(
                onTap: () => _launchVideo(context, video.videoUrl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    if (video.thumbnailUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppSpacing.radiusMd),
                        ),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: video.thumbnailUrl!,
                              fit: BoxFit.cover,
                              height: 180,
                              width: double.infinity,
                              placeholder: (context, url) => Container(
                                height: 180,
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 180,
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
                                child: Icon(Icons.video_library),
                              ),
                            ),
                            // Play Button Overlay
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.3),
                                child: Center(
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Duration Badge
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _formatDuration(video.duration),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        height: 180,
                        color: isDark ? Colors.grey[800] : Colors.grey[300],
                        child: Center(
                          child: Icon(Icons.video_library),
                        ),
                      ),
                    // Video Info
                    Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          // Video Meta
                          Row(
                            children: [
                              Icon(Icons.videocam,
                                  size: 14, color: Colors.grey),
                              SizedBox(width: 6),
                              Text(
                                _getVideoTypeLabel(video.videoType),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall,
                              ),
                              if (video.yearRecorded != null) ...[
                                SizedBox(width: AppSpacing.md),
                                Icon(Icons.calendar_today,
                                    size: 14, color: Colors.grey),
                                SizedBox(width: 6),
                                Text(
                                  '${video.yearRecorded}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                                ),
                              ],
                            ],
                          ),
                          if (video.description != null) ...[
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              video.description!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          SizedBox(height: AppSpacing.sm),
                          // Watch Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.play_arrow),
                              label: Text('Watch Video'),
                              onPressed: () =>
                                  _launchVideo(context, video.videoUrl),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusSm),
                                ),
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
          child: Text('Failed to load videos'),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  String _getVideoTypeLabel(String videoType) {
    switch (videoType) {
      case 'RECITATION':
        return 'Recitation';
      case 'DOCUMENTARY':
        return 'Documentary';
      case 'INTERVIEW':
        return 'Interview';
      case 'PERFORMANCE':
        return 'Performance';
      case 'ANALYSIS':
        return 'Analysis';
      default:
        return videoType;
    }
  }

  Future<void> _launchVideo(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open video')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening video: $e')),
      );
    }
  }
}
