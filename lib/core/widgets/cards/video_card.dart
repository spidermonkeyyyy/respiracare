import 'package:flutter/material.dart';
import 'package:respiracare/app/theme/colors.dart';
import 'package:respiracare/app/theme/radius.dart';
import 'package:respiracare/app/theme/spacing.dart';
import 'package:respiracare/app/theme/typography.dart';
import 'app_card.dart';

class VideoCard extends StatelessWidget {
  final String title;
  final String durationText;
  final String? categoryTag;
  final VoidCallback? onTap;

  const VideoCard({
    super.key,
    required this.title,
    required this.durationText,
    this.categoryTag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Thumbnail Placeholder Container
          Container(
            height: 140.0,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.medium),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.play_circle_fill_rounded,
                  size: 48.0,
                  color: AppColors.surface.withValues(alpha: 0.9),
                ),
                Positioned(
                  right: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Text(
                      durationText,
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                ),
                if (categoryTag != null)
                  Positioned(
                    left: AppSpacing.sm,
                    top: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        categoryTag!,
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              title,
              style: AppTypography.titleLarge.copyWith(fontSize: 16.0),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
