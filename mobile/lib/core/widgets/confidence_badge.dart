import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ventureiq_app/core/constants/enums.dart';
import 'package:ventureiq_app/core/theme/app_spacing.dart';
import 'package:ventureiq_app/core/theme/app_typography.dart';

/// Visual variant for the [ConfidenceBadge].
enum ConfidenceBadgeVariant {
  /// Default pill: muted background + colored text + dot + label. ~24dp height.
  pill,

  /// Compact pill: color dot + percentage only, no label text. ~20dp height.
  compact,

  /// Large pill: color dot + percentage + label text (e.g., "92% — Verified"). ~32dp height.
  large,
}

/// Institutional-grade confidence badge widget.
///
/// Displays a confidence score as a pill-shaped badge with color-coded levels:
/// - **High** (≥80%): green (`verifiedGreen`)
/// - **Mid** (50–79%): amber (`cautionAmber`)
/// - **Low** (<50%): red (`warningRed`)
///
/// Uses triple redundancy (color + text label + dot indicator) to meet
/// accessibility requirements. Percentage numbers use JetBrains Mono.
///
/// Three variants: [ConfidenceBadgeVariant.pill] (default),
/// [ConfidenceBadgeVariant.compact], and [ConfidenceBadgeVariant.large].
class ConfidenceBadge extends StatelessWidget {
  /// Creates a confidence badge for the given [score] (0–100).
  const ConfidenceBadge({
    super.key,
    required this.score,
    this.variant = ConfidenceBadgeVariant.pill,
    this.onTap,
  });

  /// Confidence score in the range 0–100.
  final double score;

  /// Visual variant of the badge.
  final ConfidenceBadgeVariant variant;

  /// Optional tap callback. When provided, wraps the badge in a
  /// tappable area with a 48dp minimum touch target.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double safeScore = (score.isNaN || score.isInfinite)
        ? 0.0
        : score.clamp(0.0, 100.0);
    final level = ConfidenceLevel.fromScore(safeScore);
    final percentage = '${safeScore.round()}%';

    Widget badge = Semantics(
      label: '${safeScore.round()} percent confidence, ${level.label}',
      excludeSemantics: true,
      child: _buildBadge(level, percentage),
    );

    if (onTap != null) {
      final double badgeHeight = variant == ConfidenceBadgeVariant.large
          ? 32.0
          : variant == ConfidenceBadgeVariant.pill
              ? 24.0
              : 20.0;
      final double verticalPadding = (48.0 - badgeHeight) / 2;

      badge = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: AppSpacing.space3,
            ),
            child: Semantics(
              button: true,
              label: '${safeScore.round()} percent confidence, ${level.label}',
              excludeSemantics: true,
              child: _buildBadge(level, percentage),
            ),
          ),
        ),
      );
    }

    return badge;
  }

  Widget _buildBadge(ConfidenceLevel level, String percentage) {
    final bgColor = level.color.withValues(alpha: 0.15);

    switch (variant) {
      case ConfidenceBadgeVariant.pill:
        return _PillBadge(
          level: level,
          percentage: percentage,
          bgColor: bgColor,
          height: 24,
        );
      case ConfidenceBadgeVariant.compact:
        return _CompactBadge(
          level: level,
          percentage: percentage,
          bgColor: bgColor,
          height: 20,
        );
      case ConfidenceBadgeVariant.large:
        return _LargeBadge(
          level: level,
          percentage: percentage,
          bgColor: bgColor,
          height: 32,
        );
    }
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({
    required this.level,
    required this.percentage,
    required this.bgColor,
    required this.height,
  });

  final ConfidenceLevel level;
  final String percentage;
  final Color bgColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Dot(color: level.color),
          const SizedBox(width: AppSpacing.space1),
          Text(
            percentage,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: level.color,
            ),
          ),
          const SizedBox(width: AppSpacing.space1),
          Text(
            level.label,
            style: AppTypography.micro.copyWith(
              color: level.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactBadge extends StatelessWidget {
  const _CompactBadge({
    required this.level,
    required this.percentage,
    required this.bgColor,
    required this.height,
  });

  final ConfidenceLevel level;
  final String percentage;
  final Color bgColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Dot(color: level.color, size: 6),
          const SizedBox(width: AppSpacing.space1),
          Text(
            percentage,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: level.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeBadge extends StatelessWidget {
  const _LargeBadge({
    required this.level,
    required this.percentage,
    required this.bgColor,
    required this.height,
  });

  final ConfidenceLevel level;
  final String percentage;
  final Color bgColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Dot(color: level.color, size: 10),
          const SizedBox(width: AppSpacing.space2),
          Text(
            '$percentage — ${level.label}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: level.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small colored dot indicator.
class _Dot extends StatelessWidget {
  const _Dot({
    required this.color,
    this.size = 8,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
