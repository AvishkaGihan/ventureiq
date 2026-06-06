import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ventureiq_app/core/theme/app_colors.dart';
import 'package:ventureiq_app/core/theme/app_spacing.dart';
import 'package:ventureiq_app/core/theme/app_typography.dart';
import 'package:ventureiq_app/features/auth/domain/usage_entity.dart';
import 'package:ventureiq_app/features/auth/presentation/usage_providers.dart';

/// Profile usage indicator for monthly report generation.
class UsageIndicator extends ConsumerWidget {
  const UsageIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(usageNotifierProvider);

    return usage.when(
      loading: () => const _UsageShell(
        child: LinearProgressIndicator(
          minHeight: 6,
          color: AppColors.electricViolet,
          backgroundColor: AppColors.surface200,
        ),
      ),
      error: (error, stackTrace) => _UsageShell(
        child: Text(
          'Usage unavailable',
          style: AppTypography.bodySm.copyWith(color: AppColors.textTertiary),
        ),
      ),
      data: (status) => _UsageShell(child: _UsageContent(status: status)),
    );
  }
}

class _UsageShell extends StatelessWidget {
  const _UsageShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Monthly report usage',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: AppColors.surface050,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.surface300),
        ),
        child: child,
      ),
    );
  }
}

class _UsageContent extends StatelessWidget {
  const _UsageContent({required this.status});

  final UsageStatus status;

  @override
  Widget build(BuildContext context) {
    final isUnlimited = status.reportsLimit == 0;
    final usedLabel = isUnlimited
        ? 'Unlimited'
        : '${status.reportsUsed}/${status.reportsLimit}';
    final accent = !isUnlimited && status.reportsUsed >= 2
        ? AppColors.cautionAmber
        : AppColors.electricViolet;
    final progress = isUnlimited
        ? 1.0
        : (status.reportsUsed / status.reportsLimit).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Reports used this month',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            _TierBadge(label: status.tier, isUnlimited: isUnlimited),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        Row(
          children: [
            Text(
              usedLabel,
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  color: accent,
                  backgroundColor: AppColors.surface200,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({
    required this.label,
    required this.isUnlimited,
  });

  final String label;
  final bool isUnlimited;

  @override
  Widget build(BuildContext context) {
    final text = isUnlimited ? 'Unlimited' : label.toUpperCase();

    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface150,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.surface300),
      ),
      child: Text(
        text,
        style: AppTypography.micro.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
