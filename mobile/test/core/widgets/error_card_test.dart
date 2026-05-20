import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ventureiq_app/core/constants/enums.dart';
import 'package:ventureiq_app/core/widgets/error_card.dart';

void main() {
  group('ErrorCard', () {
    for (final type in FeedbackType.values) {
      testWidgets('renders ${type.name} variant with correct icon',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorCard(
                type: type,
                message: 'Test ${type.name} message',
              ),
            ),
          ),
        );

        expect(find.byIcon(type.icon), findsOneWidget);
        expect(find.text('Test ${type.name} message'), findsOneWidget);
      });
    }

    testWidgets('displays message text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorCard(
              type: FeedbackType.error,
              message: 'Something went wrong',
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('renders retry button when onRetry is provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorCard(
              type: FeedbackType.error,
              message: 'Failed to load',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('retry button fires callback on tap', (tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorCard(
              type: FeedbackType.error,
              message: 'Failed to load',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retried, isTrue);
    });

    testWidgets('retry button is NOT rendered when onRetry is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorCard(
              type: FeedbackType.info,
              message: 'Information message',
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsNothing);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('uses custom retryLabel when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorCard(
              type: FeedbackType.error,
              message: 'Error occurred',
              onRetry: () {},
              retryLabel: 'Try Again',
            ),
          ),
        ),
      );

      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('has Semantics label including feedback type',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorCard(
              type: FeedbackType.warning,
              message: 'Low disk space',
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('warning feedback: Low disk space'),
        findsOneWidget,
      );
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
                child: ErrorCard(
                  type: FeedbackType.error,
                  message:
                      'This is a longer error message to test text scaling',
                  onRetry: () {},
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
