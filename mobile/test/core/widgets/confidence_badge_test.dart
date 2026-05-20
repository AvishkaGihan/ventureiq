import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ventureiq_app/core/widgets/confidence_badge.dart';

void main() {
  group('ConfidenceBadge', () {
    group('score → level mapping', () {
      testWidgets('score 92 renders green high confidence', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ConfidenceBadge(score: 92),
            ),
          ),
        );

        expect(find.text('92%'), findsOneWidget);
        expect(
          find.bySemanticsLabel(
            RegExp(r'92 percent confidence, Verified'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('score 67 renders amber mid confidence', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ConfidenceBadge(score: 67),
            ),
          ),
        );

        expect(find.text('67%'), findsOneWidget);
        expect(
          find.bySemanticsLabel(
            RegExp(r'67 percent confidence, Moderate'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('score 38 renders red low confidence', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ConfidenceBadge(score: 38),
            ),
          ),
        );

        expect(find.text('38%'), findsOneWidget);
        expect(
          find.bySemanticsLabel(
            RegExp(r'38 percent confidence, Low'),
          ),
          findsOneWidget,
        );
      });
    });

    group('boundary conditions', () {
      testWidgets('score 80 → High', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ConfidenceBadge(score: 80),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(
            RegExp(r'80 percent confidence, Verified'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('score 79 → Mid', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ConfidenceBadge(score: 79),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(
            RegExp(r'79 percent confidence, Moderate'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('score 50 → Mid', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ConfidenceBadge(score: 50),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(
            RegExp(r'50 percent confidence, Moderate'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('score 49 → Low', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ConfidenceBadge(score: 49),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(
            RegExp(r'49 percent confidence, Low'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('score 0 → Low', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ConfidenceBadge(score: 0),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(
            RegExp(r'0 percent confidence, Low'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('score 100 → High', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ConfidenceBadge(score: 100),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(
            RegExp(r'100 percent confidence, Verified'),
          ),
          findsOneWidget,
        );
      });
    });

    group('variants', () {
      testWidgets('pill variant renders without error', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ConfidenceBadge(
                score: 85,
                variant: ConfidenceBadgeVariant.pill,
              ),
            ),
          ),
        );

        expect(find.byType(ConfidenceBadge), findsOneWidget);
        // Pill shows percentage + label
        expect(find.text('85%'), findsOneWidget);
        expect(find.text('Verified'), findsOneWidget);
      });

      testWidgets('compact variant renders without error', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ConfidenceBadge(
                score: 65,
                variant: ConfidenceBadgeVariant.compact,
              ),
            ),
          ),
        );

        expect(find.byType(ConfidenceBadge), findsOneWidget);
        // Compact shows percentage only
        expect(find.text('65%'), findsOneWidget);
      });

      testWidgets('large variant renders without error', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ConfidenceBadge(
                score: 92,
                variant: ConfidenceBadgeVariant.large,
              ),
            ),
          ),
        );

        expect(find.byType(ConfidenceBadge), findsOneWidget);
        // Large shows "percentage — label"
        expect(find.textContaining('92%'), findsOneWidget);
      });
    });

    testWidgets('Semantics label includes score and level', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(score: 75),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel(
          RegExp(r'75 percent confidence, Moderate'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tappable badge wraps in 48dp touch target',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(
              score: 90,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ConfidenceBadge));
      await tester.pump();

      expect(tapped, isTrue);
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
                    ConfidenceBadge(
                      score: 92,
                      variant: ConfidenceBadgeVariant.pill,
                    ),
                    ConfidenceBadge(
                      score: 65,
                      variant: ConfidenceBadgeVariant.compact,
                    ),
                    ConfidenceBadge(
                      score: 38,
                      variant: ConfidenceBadgeVariant.large,
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
  });
}
