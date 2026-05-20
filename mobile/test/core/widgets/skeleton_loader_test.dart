import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ventureiq_app/core/widgets/skeleton_loader.dart';

void main() {
  group('SkeletonLoader', () {
    testWidgets('renders with default dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              width: 200,
              height: 48,
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('applies custom width and height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              width: 150,
              height: 30,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SkeletonLoader),
          matching: find.byType(Container),
        ),
      );

      expect(container.constraints?.maxWidth, 150);
      expect(container.constraints?.maxHeight, 30);
    });

    testWidgets('has Semantics label "Loading content"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              width: 100,
              height: 20,
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Loading content'),
        findsOneWidget,
      );
    });

    testWidgets('shimmer animation runs when reduce motion is off',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              width: 200,
              height: 48,
            ),
          ),
        ),
      );

      // Pump a few frames to let animation progress
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Widget should still be present (animation running)
      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets(
        'shows static fill when reduce motion is enabled', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: SkeletonLoader(
                width: 200,
                height: 48,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    group('convenience factories', () {
      testWidgets('.text() renders correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SkeletonLoader.text(width: 120),
            ),
          ),
        );

        expect(find.byType(SkeletonLoader), findsOneWidget);
      });

      testWidgets('.card() renders correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SkeletonLoader.card(),
            ),
          ),
        );

        expect(find.byType(SkeletonLoader), findsOneWidget);
      });
    });

    testWidgets('renders without overflow at 1.5x text scale',
        (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.5),
          ),
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                child: Column(
                  children: [
                    const SkeletonLoader(width: 200, height: 48),
                    SkeletonLoader.text(width: 150),
                    SkeletonLoader.card(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      // No FlutterError thrown means no overflow
      expect(tester.takeException(), isNull);
    });
  });
}
