import 'package:flutter/material.dart';

import 'package:ventureiq_app/core/constants/enums.dart';
import 'package:ventureiq_app/core/theme/app_colors.dart';
import 'package:ventureiq_app/core/theme/app_spacing.dart';
import 'package:ventureiq_app/core/theme/app_typography.dart';

/// Error/feedback card with a colored left border.
///
/// Supports four feedback types (Success, Error, Warning, Info) with
/// type-specific color and icon. Includes an optional retry action button.
///
/// Features:
/// - 4dp colored left border per [FeedbackType]
/// - Type icon + message text in a row
/// - Optional retry button meeting 48dp touch target
/// - Screen reader semantics
/// - Dynamic text scaling support
class ErrorCard extends StatelessWidget {
  /// Creates an error/feedback card.
  const ErrorCard({
    super.key,
    required this.type,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  /// The feedback type determining the left border color and icon.
  final FeedbackType type;

  /// The message text displayed in the card body.
  final String message;

  /// Optional callback invoked when the retry button is tapped.
  /// When null, the retry button is not rendered.
  final VoidCallback? onRetry;

  /// Optional custom label for the retry button. Defaults to 'Retry'.
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface050,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.surface300,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd - 1),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: type.color,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        label: '${type.name} feedback: $message',
                        excludeSemantics: true,
                        liveRegion: true,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              type.icon,
                              size: 24,
                              color: type.color,
                            ),
                            const SizedBox(width: AppSpacing.space3),
                            Expanded(
                              child: Text(
                                message,
                                style: AppTypography.body.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onRetry != null) ...[
                        const SizedBox(height: AppSpacing.space3),
                        Semantics(
                          button: true,
                          label: retryLabel ?? 'Retry',
                          child: TextButton(
                            onPressed: onRetry,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.electricViolet,
                              minimumSize: const Size(48, 48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.space4,
                              ),
                            ),
                            child: Text(retryLabel ?? 'Retry'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
