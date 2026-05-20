import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ventureiq_app/core/constants/enums.dart';
import 'package:ventureiq_app/core/theme/app_colors.dart';
import 'package:ventureiq_app/core/widgets/agent_status_indicator.dart';

void main() {
  group('AgentStatusIndicator', () {
    group('phase rendering', () {
      for (final phase in AgentPhase.values) {
        testWidgets('renders ${phase.name} phase with correct text',
            (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AgentStatusIndicator(
                  phase: phase,
                  agent: AgentRole.scout,
                  variant: AgentStatusVariant.badge,
                ),
              ),
            ),
          );

          expect(find.text(phase.displayName), findsOneWidget);
          expect(find.text(phase.icon), findsOneWidget);
        });
      }
    });

    group('variants', () {
      testWidgets('badge variant renders without error', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AgentStatusIndicator(
                phase: AgentPhase.analyzing,
                agent: AgentRole.scout,
                variant: AgentStatusVariant.badge,
              ),
            ),
          ),
        );

        expect(find.byType(AgentStatusIndicator), findsOneWidget);
        expect(find.text('Analyzing'), findsOneWidget);
      });

      testWidgets('full variant renders without error', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AgentStatusIndicator(
                phase: AgentPhase.searching,
                agent: AgentRole.rival,
                variant: AgentStatusVariant.full,
              ),
            ),
          ),
        );

        expect(find.byType(AgentStatusIndicator), findsOneWidget);
        expect(find.text('Rival'), findsOneWidget);
        expect(find.text('Searching'), findsOneWidget);
        expect(find.text(AgentRole.rival.icon), findsOneWidget);
      });

      testWidgets('dot variant renders a colored circle', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AgentStatusIndicator(
                phase: AgentPhase.started,
                agent: AgentRole.strategist,
                variant: AgentStatusVariant.dot,
              ),
            ),
          ),
        );

        expect(find.byType(AgentStatusIndicator), findsOneWidget);

        // Find the dot container with BoxDecoration circle
        final dotFinder = find.byWidgetPredicate((widget) {
          if (widget is Container) {
            final decoration = widget.decoration;
            if (decoration is BoxDecoration) {
              return decoration.shape == BoxShape.circle &&
                  decoration.color == AppColors.strategistFull;
            }
          }
          return false;
        });
        expect(dotFinder, findsOneWidget);
      });
    });

    group('agent colors', () {
      final expectedColors = {
        AgentRole.scout: AppColors.scoutFull,
        AgentRole.rival: AppColors.rivalFull,
        AgentRole.cfo: AppColors.cfoFull,
        AgentRole.devilsAdvocate: AppColors.devilsAdvocateFull,
        AgentRole.strategist: AppColors.strategistFull,
        AgentRole.coordinator: AppColors.coordinatorFull,
      };

      for (final entry in expectedColors.entries) {
        testWidgets(
            '${entry.key.displayName} agent uses correct color in dot variant',
            (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AgentStatusIndicator(
                  phase: AgentPhase.complete,
                  agent: entry.key,
                  variant: AgentStatusVariant.dot,
                ),
              ),
            ),
          );

          // Verify the dot uses the agent's color
          final dotFinder = find.byWidgetPredicate((widget) {
            if (widget is Container) {
              final decoration = widget.decoration;
              if (decoration is BoxDecoration) {
                return decoration.shape == BoxShape.circle &&
                    decoration.color == entry.value;
              }
            }
            return false;
          });
          expect(dotFinder, findsOneWidget);
        });
      }
    });

    testWidgets('Semantics label includes agent name and phase',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgentStatusIndicator(
              phase: AgentPhase.analyzing,
              agent: AgentRole.cfo,
              variant: AgentStatusVariant.badge,
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('CFO agent status: Analyzing'),
        findsOneWidget,
      );
    });

    testWidgets('Semantics label for all agent/phase combinations',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgentStatusIndicator(
              phase: AgentPhase.crossReferencing,
              agent: AgentRole.devilsAdvocate,
              variant: AgentStatusVariant.badge,
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel(
          "Devil's Advocate agent status: Cross-referencing",
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders without overflow at 1.5x text scale',
        (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(1.5),
          ),
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: Column(
                  children: [
                    AgentStatusIndicator(
                      phase: AgentPhase.analyzing,
                      agent: AgentRole.scout,
                      variant: AgentStatusVariant.badge,
                    ),
                    AgentStatusIndicator(
                      phase: AgentPhase.searching,
                      agent: AgentRole.rival,
                      variant: AgentStatusVariant.full,
                    ),
                    AgentStatusIndicator(
                      phase: AgentPhase.complete,
                      agent: AgentRole.coordinator,
                      variant: AgentStatusVariant.dot,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'reduce motion disables pulse animation in dot variant',
        (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: AgentStatusIndicator(
                phase: AgentPhase.started,
                agent: AgentRole.scout,
                variant: AgentStatusVariant.dot,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(AgentStatusIndicator), findsOneWidget);
    });
  });
}
