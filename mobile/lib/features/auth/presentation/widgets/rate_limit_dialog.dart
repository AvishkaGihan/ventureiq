import 'package:flutter/material.dart';
import 'package:ventureiq_app/core/constants/enums.dart';
import 'package:ventureiq_app/core/theme/app_colors.dart';
import 'package:ventureiq_app/core/theme/app_spacing.dart';
import 'package:ventureiq_app/core/theme/app_typography.dart';
import 'package:ventureiq_app/core/widgets/error_card.dart';

/// Bottom sheet shown when report generation hits the monthly limit.
class RateLimitDialog extends StatelessWidget {
  const RateLimitDialog({
    super.key,
    required this.reportsUsed,
    required this.reportsLimit,
    this.onUpgrade,
  });

  final int reportsUsed;
  final int reportsLimit;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$reportsUsed/$reportsLimit reports used this month',
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.space4),
            const ErrorCard(
              type: FeedbackType.warning,
              message: 'Upgrade to Pro for unlimited reports.',
            ),
            const SizedBox(height: AppSpacing.space6),
            FilledButton.icon(
              onPressed: onUpgrade ?? () => Navigator.of(context).pop(),
              icon: const Icon(Icons.workspace_premium),
              label: const Text('Upgrade to Pro'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.electricViolet,
                foregroundColor: AppColors.textPrimary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
