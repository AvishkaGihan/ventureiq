import 'package:flutter/material.dart';

import 'package:ventureiq_app/core/theme/app_colors.dart';

/// Agent roles in the VentureIQ analysis pipeline.
///
/// Each agent has a unique identity color, display name, icon (emoji),
/// and muted/glow color variants for UI differentiation.
enum AgentRole {
  scout,
  rival,
  cfo,
  devilsAdvocate,
  strategist,
  coordinator;

  /// Human-readable display name for the agent.
  String get displayName {
    switch (this) {
      case AgentRole.scout:
        return 'Scout';
      case AgentRole.rival:
        return 'Rival';
      case AgentRole.cfo:
        return 'CFO';
      case AgentRole.devilsAdvocate:
        return "Devil's Advocate";
      case AgentRole.strategist:
        return 'Strategist';
      case AgentRole.coordinator:
        return 'Coordinator';
    }
  } 

  /// Emoji icon representing the agent.
  String get icon {
    switch (this) {
      case AgentRole.scout:
        return '🔍';
      case AgentRole.rival:
        return '⚔️';
      case AgentRole.cfo:
        return '💰';
      case AgentRole.devilsAdvocate:
        return '😈';
      case AgentRole.strategist:
        return '🎯';
      case AgentRole.coordinator:
        return '🧠';
    }
  }

  /// Primary identity color for the agent.
  Color get color {
    switch (this) {
      case AgentRole.scout:
        return AppColors.scoutFull;
      case AgentRole.rival:
        return AppColors.rivalFull;
      case AgentRole.cfo:
        return AppColors.cfoFull;
      case AgentRole.devilsAdvocate:
        return AppColors.devilsAdvocateFull;
      case AgentRole.strategist:
        return AppColors.strategistFull;
      case AgentRole.coordinator:
        return AppColors.coordinatorFull;
    }
  }

  /// Muted (40% opacity) identity color for backgrounds.
  Color get mutedColor {
    switch (this) {
      case AgentRole.scout:
        return AppColors.scoutMuted;
      case AgentRole.rival:
        return AppColors.rivalMuted;
      case AgentRole.cfo:
        return AppColors.cfoMuted;
      case AgentRole.devilsAdvocate:
        return AppColors.devilsAdvocateMuted;
      case AgentRole.strategist:
        return AppColors.strategistMuted;
      case AgentRole.coordinator:
        return AppColors.coordinatorMuted;
    }
  }

  /// Glow (30% opacity) identity color for effects.
  Color get glowColor {
    switch (this) {
      case AgentRole.scout:
        return AppColors.scoutGlow;
      case AgentRole.rival:
        return AppColors.rivalGlow;
      case AgentRole.cfo:
        return AppColors.cfoGlow;
      case AgentRole.devilsAdvocate:
        return AppColors.devilsAdvocateGlow;
      case AgentRole.strategist:
        return AppColors.strategistGlow;
      case AgentRole.coordinator:
        return AppColors.coordinatorGlow;
    }
  }
}

/// Report lifecycle status.
enum ReportStatus {
  pending,
  plausibilityChecking,
  analyzing,
  crossReferencing,
  synthesizing,
  completed,
  failed,
}

/// Agent processing phase within the analysis pipeline.
enum AgentPhase {
  started,
  searching,
  analyzing,
  crossReferencing,
  complete,
  error;

  /// Human-readable display name for the phase.
  String get displayName {
    switch (this) {
      case AgentPhase.started:
        return 'Started';
      case AgentPhase.searching:
        return 'Searching';
      case AgentPhase.analyzing:
        return 'Analyzing';
      case AgentPhase.crossReferencing:
        return 'Cross-referencing';
      case AgentPhase.complete:
        return 'Complete';
      case AgentPhase.error:
        return 'Error';
    }
  }

  /// Emoji icon for the phase.
  String get icon {
    switch (this) {
      case AgentPhase.started:
        return '⏳';
      case AgentPhase.searching:
        return '🔍';
      case AgentPhase.analyzing:
        return '⚡';
      case AgentPhase.crossReferencing:
        return '📎';
      case AgentPhase.complete:
        return '✅';
      case AgentPhase.error:
        return '⚠️';
    }
  }

  /// Whether this phase represents an active (in-progress) state.
  bool get isActive {
    switch (this) {
      case AgentPhase.started:
      case AgentPhase.searching:
      case AgentPhase.analyzing:
      case AgentPhase.crossReferencing:
        return true;
      case AgentPhase.complete:
      case AgentPhase.error:
        return false;
    }
  }
}

/// Confidence level derived from a numeric score.
///
/// Thresholds:
/// - High: ≥80%
/// - Mid: 50–79%
/// - Low: <50%
enum ConfidenceLevel {
  high,
  mid,
  low;

  /// Derive the confidence level from a score in the range 0–100.
  factory ConfidenceLevel.fromScore(double score) {
    assert(!score.isNaN, 'Score must not be NaN');
    assert(score >= 0.0 && score <= 100.0, 'Score must be between 0.0 and 100.0');
    if (score >= 80) {
      return ConfidenceLevel.high;
    } else if (score >= 50) {
      return ConfidenceLevel.mid;
    } else {
      return ConfidenceLevel.low;
    }
  }

  /// Color associated with this confidence level.
  Color get color {
    switch (this) {
      case ConfidenceLevel.high:
        return AppColors.verifiedGreen;
      case ConfidenceLevel.mid:
        return AppColors.cautionAmber;
      case ConfidenceLevel.low:
        return AppColors.warningRed;
    }
  }

  /// Human-readable label for the confidence level.
  String get label {
    switch (this) {
      case ConfidenceLevel.high:
        return 'Verified';
      case ConfidenceLevel.mid:
        return 'Moderate';
      case ConfidenceLevel.low:
        return 'Low';
    }
  }
}

/// Feedback card type determining color and icon.
enum FeedbackType {
  success,
  error,
  warning,
  info;

  /// Color associated with this feedback type.
  Color get color {
    switch (this) {
      case FeedbackType.success:
        return AppColors.success;
      case FeedbackType.error:
        return AppColors.error;
      case FeedbackType.warning:
        return AppColors.warning;
      case FeedbackType.info:
        return AppColors.info;
    }
  }

  /// Icon associated with this feedback type.
  IconData get icon {
    switch (this) {
      case FeedbackType.success:
        return Icons.check_circle;
      case FeedbackType.error:
        return Icons.cancel;
      case FeedbackType.warning:
        return Icons.warning_rounded;
      case FeedbackType.info:
        return Icons.info;
    }
  }
}
