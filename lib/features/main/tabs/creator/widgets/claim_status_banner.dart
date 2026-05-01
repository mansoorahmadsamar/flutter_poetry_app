import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import '../models/claim_status.dart';
import '../models/owned_poet_model.dart';

/// Persistent banner shown on the profile tab when the user has a
/// `PENDING` or `REJECTED` claim. Pulsing gold disc animates the ۞ glyph
/// to keep the "in review" state alive.
class ClaimStatusBanner extends StatefulWidget {
  const ClaimStatusBanner({
    super.key,
    required this.poet,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
  });

  final OwnedPoet poet;
  final EdgeInsets margin;

  @override
  State<ClaimStatusBanner> createState() => _ClaimStatusBannerState();
}

class _ClaimStatusBannerState extends State<ClaimStatusBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRejected = widget.poet.claimStatus == ClaimStatus.rejected;
    final eyebrow = isRejected ? 'CLAIM REJECTED' : 'CLAIM IN REVIEW';
    final headline = isRejected ? 'Resubmit needed' : 'Verifying';

    // Prefer the admin's rejection reason, fall back to the reviewer note,
    // then to a generic message. Pending claims show relative submit time.
    final String subtitle;
    if (isRejected) {
      subtitle = widget.poet.claimRejectionReason ??
          widget.poet.claimReviewerNote ??
          'Your previous proof was rejected. Try again.';
    } else {
      subtitle = _submittedAgo(widget.poet.claimedAt);
    }

    return Padding(
      padding: widget.margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (isRejected) {
              context.push('/main/become-poet/claim/${widget.poet.publicId}');
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isRejected ? AppColors.error : AppColors.secondary,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isRejected
                    ? [
                        AppColors.error.withValues(alpha: 0.08),
                        AppColors.paperSurface,
                      ]
                    : const [AppColors.goldSoft, AppColors.paperSurface],
              ),
            ),
            child: Stack(
              children: [
                // Diagonal stripe accent on the left edge
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: (isRejected
                              ? AppColors.error
                              : AppColors.secondary)
                          .withValues(alpha: 0.6),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Row(
                    children: [
                      _PulsingDisc(controller: _ctrl, isRejected: isRejected),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eyebrow,
                              style: SukhanText.eyebrow(
                                color: isRejected
                                    ? AppColors.error
                                    : AppColors.secondaryDark,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  headline,
                                  style: SukhanText.display(
                                    size: 14,
                                    color: AppColors.textPrimaryLight,
                                    weight: FontWeight.w600,
                                    height: 1.2,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    widget.poet.penName ?? widget.poet.name,
                                    textDirection: TextDirection.rtl,
                                    overflow: TextOverflow.ellipsis,
                                    style: SukhanText.nastaleeq(
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: SukhanText.italic(
                                size: 11,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '›',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          color: isRejected
                              ? AppColors.error
                              : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _submittedAgo(DateTime? claimedAt) {
    if (claimedAt == null) return 'Submitted recently · usually 24–48h';
    final delta = DateTime.now().difference(claimedAt);
    String relative;
    if (delta.inMinutes < 60) {
      relative = '${delta.inMinutes.clamp(1, 59)}m ago';
    } else if (delta.inHours < 24) {
      relative = '${delta.inHours}h ago';
    } else {
      relative = '${delta.inDays}d ago';
    }
    return 'Submitted $relative · usually 24–48h';
  }
}

class _PulsingDisc extends StatelessWidget {
  const _PulsingDisc({required this.controller, required this.isRejected});

  final AnimationController controller;
  final bool isRejected;

  @override
  Widget build(BuildContext context) {
    final color = isRejected ? AppColors.error : AppColors.secondary;
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        final spread = 8.0 * t;
        final opacity = (1 - t) * 0.5;
        return Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: opacity),
                spreadRadius: spread,
                blurRadius: 0,
              ),
            ],
          ),
          child: Text(
            '۞',
            style: TextStyle(
              fontFamily: AppTypography.urduFontFamily,
              fontSize: 18,
              height: 1,
              color: AppColors.backgroundLight,
            ),
          ),
        );
      },
    );
  }
}
