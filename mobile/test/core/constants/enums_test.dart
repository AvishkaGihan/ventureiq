import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ventureiq_app/core/constants/enums.dart';
import 'package:ventureiq_app/core/theme/app_colors.dart';

void main() {
  group('AgentRole', () {
    test('has exactly 6 values', () {
      expect(AgentRole.values.length, 6);
    });

    test('displayName returns correct names', () {
      expect(AgentRole.scout.displayName, 'Scout');
      expect(AgentRole.rival.displayName, 'Rival');
      expect(AgentRole.cfo.displayName, 'CFO');
      expect(AgentRole.devilsAdvocate.displayName, "Devil's Advocate");
      expect(AgentRole.strategist.displayName, 'Strategist');
      expect(AgentRole.coordinator.displayName, 'Coordinator');
    });

    test('color returns correct AppColors for each agent', () {
      expect(AgentRole.scout.color, AppColors.scoutFull);
      expect(AgentRole.rival.color, AppColors.rivalFull);
      expect(AgentRole.cfo.color, AppColors.cfoFull);
      expect(AgentRole.devilsAdvocate.color, AppColors.devilsAdvocateFull);
      expect(AgentRole.strategist.color, AppColors.strategistFull);
      expect(AgentRole.coordinator.color, AppColors.coordinatorFull);
    });

    test('mutedColor returns correct AppColors for each agent', () {
      expect(AgentRole.scout.mutedColor, AppColors.scoutMuted);
      expect(AgentRole.rival.mutedColor, AppColors.rivalMuted);
      expect(AgentRole.cfo.mutedColor, AppColors.cfoMuted);
      expect(
        AgentRole.devilsAdvocate.mutedColor,
        AppColors.devilsAdvocateMuted,
      );
      expect(AgentRole.strategist.mutedColor, AppColors.strategistMuted);
      expect(AgentRole.coordinator.mutedColor, AppColors.coordinatorMuted);
    });

    test('glowColor returns correct AppColors for each agent', () {
      expect(AgentRole.scout.glowColor, AppColors.scoutGlow);
      expect(AgentRole.rival.glowColor, AppColors.rivalGlow);
      expect(AgentRole.cfo.glowColor, AppColors.cfoGlow);
      expect(
        AgentRole.devilsAdvocate.glowColor,
        AppColors.devilsAdvocateGlow,
      );
      expect(AgentRole.strategist.glowColor, AppColors.strategistGlow);
      expect(AgentRole.coordinator.glowColor, AppColors.coordinatorGlow);
    });

    test('icon returns non-empty string for each agent', () {
      for (final role in AgentRole.values) {
        expect(role.icon, isNotEmpty);
      }
    });
  });

  group('ReportStatus', () {
    test('has exactly 7 values', () {
      expect(ReportStatus.values.length, 7);
    });

    test('values match expected pipeline stages', () {
      expect(
        ReportStatus.values,
        containsAll([
          ReportStatus.pending,
          ReportStatus.plausibilityChecking,
          ReportStatus.analyzing,
          ReportStatus.crossReferencing,
          ReportStatus.synthesizing,
          ReportStatus.completed,
          ReportStatus.failed,
        ]),
      );
    });
  });

  group('AgentPhase', () {
    test('has exactly 6 values', () {
      expect(AgentPhase.values.length, 6);
    });

    test('displayName returns correct phase names', () {
      expect(AgentPhase.started.displayName, 'Started');
      expect(AgentPhase.searching.displayName, 'Searching');
      expect(AgentPhase.analyzing.displayName, 'Analyzing');
      expect(AgentPhase.crossReferencing.displayName, 'Cross-referencing');
      expect(AgentPhase.complete.displayName, 'Complete');
      expect(AgentPhase.error.displayName, 'Error');
    });

    test('icon returns non-empty string for each phase', () {
      for (final phase in AgentPhase.values) {
        expect(phase.icon, isNotEmpty);
      }
    });

    test('isActive is true for in-progress phases', () {
      expect(AgentPhase.started.isActive, isTrue);
      expect(AgentPhase.searching.isActive, isTrue);
      expect(AgentPhase.analyzing.isActive, isTrue);
      expect(AgentPhase.crossReferencing.isActive, isTrue);
    });

    test('isActive is false for terminal phases', () {
      expect(AgentPhase.complete.isActive, isFalse);
      expect(AgentPhase.error.isActive, isFalse);
    });
  });

  group('ConfidenceLevel', () {
    test('has exactly 3 values', () {
      expect(ConfidenceLevel.values.length, 3);
    });

    group('fromScore boundary conditions', () {
      test('score 0 returns low', () {
        expect(ConfidenceLevel.fromScore(0), ConfidenceLevel.low);
      });

      test('score 49 returns low', () {
        expect(ConfidenceLevel.fromScore(49), ConfidenceLevel.low);
      });

      test('score 49.9 returns low', () {
        expect(ConfidenceLevel.fromScore(49.9), ConfidenceLevel.low);
      });

      test('score 50 returns mid', () {
        expect(ConfidenceLevel.fromScore(50), ConfidenceLevel.mid);
      });

      test('score 79 returns mid', () {
        expect(ConfidenceLevel.fromScore(79), ConfidenceLevel.mid);
      });

      test('score 79.9 returns mid', () {
        expect(ConfidenceLevel.fromScore(79.9), ConfidenceLevel.mid);
      });

      test('score 80 returns high', () {
        expect(ConfidenceLevel.fromScore(80), ConfidenceLevel.high);
      });

      test('score 100 returns high', () {
        expect(ConfidenceLevel.fromScore(100), ConfidenceLevel.high);
      });
    });

    test('color returns correct confidence colors', () {
      expect(ConfidenceLevel.high.color, AppColors.verifiedGreen);
      expect(ConfidenceLevel.mid.color, AppColors.cautionAmber);
      expect(ConfidenceLevel.low.color, AppColors.warningRed);
    });

    test('label returns correct labels', () {
      expect(ConfidenceLevel.high.label, 'Verified');
      expect(ConfidenceLevel.mid.label, 'Moderate');
      expect(ConfidenceLevel.low.label, 'Low');
    });
  });

  group('FeedbackType', () {
    test('has exactly 4 values', () {
      expect(FeedbackType.values.length, 4);
    });

    test('color returns correct feedback colors', () {
      expect(FeedbackType.success.color, AppColors.success);
      expect(FeedbackType.error.color, AppColors.error);
      expect(FeedbackType.warning.color, AppColors.warning);
      expect(FeedbackType.info.color, AppColors.info);
    });

    test('icon returns valid IconData for each type', () {
      expect(FeedbackType.success.icon, Icons.check_circle);
      expect(FeedbackType.error.icon, Icons.cancel);
      expect(FeedbackType.warning.icon, Icons.warning_rounded);
      expect(FeedbackType.info.icon, Icons.info);
    });
  });
}
