import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ventureiq_app/core/constants/enums.dart';
import 'package:ventureiq_app/core/theme/app_theme.dart';
import 'package:ventureiq_app/core/widgets/error_card.dart';
import 'package:ventureiq_app/features/idea_input/data/idea_repository.dart';
import 'package:ventureiq_app/features/idea_input/domain/idea_entity.dart';
import 'package:ventureiq_app/features/idea_input/domain/plausibility_entity.dart';
import 'package:ventureiq_app/features/idea_input/presentation/idea_input_providers.dart';
import 'package:ventureiq_app/features/idea_input/presentation/idea_input_screen.dart';

class _FakeIdeaRepository implements IdeaRepository {
  _FakeIdeaRepository({
    required this.plausibility,
    this.delay = Duration.zero,
    this.shouldThrow = false,
  });

  final PlausibilityEntity plausibility;
  final Duration delay;
  final bool shouldThrow;
  int createCalls = 0;
  int plausibilityCalls = 0;

  @override
  Future<IdeaEntity> createIdea({
    required String ideaText,
    String? targetAudience,
    String? industry,
    String? monetizationModel,
    String? region,
  }) async {
    createCalls += 1;
    if (shouldThrow) {
      throw Exception('Network unavailable');
    }
    if (delay != Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return IdeaEntity(
      id: 'idea-123',
      userId: 'user-123',
      ideaText: ideaText,
      targetAudience: targetAudience,
      industry: industry,
      monetizationModel: monetizationModel,
      region: region,
      status: 'pending',
      createdAt: DateTime.utc(2026, 6, 8),
    );
  }

  @override
  Future<PlausibilityEntity> checkPlausibility(String ideaId) async {
    plausibilityCalls += 1;
    if (delay != Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return plausibility;
  }
}

PlausibilityEntity _plausibility({
  required String verdict,
  List<String>? guidance,
  String? reason,
}) {
  return PlausibilityEntity(
    verdict: verdict,
    guidance: guidance,
    reason: reason,
    confidence: 0.9,
  );
}

Widget _testApp({
  required _FakeIdeaRepository repository,
  String? Function(String)? onWarRoom,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const IdeaInputScreen()),
      GoRoute(
        path: '/home/war-room/:ideaId',
        builder: (context, state) {
          final ideaId = state.pathParameters['ideaId'] ?? '';
          onWarRoom?.call(ideaId);
          return Text('War Room $ideaId');
        },
      ),
    ],
  );

  return ProviderScope(
    overrides: [ideaRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(routerConfig: router, theme: AppTheme.darkTheme),
  );
}

Future<void> _enterIdea(WidgetTester tester, String text) async {
  await tester.enterText(
    find.bySemanticsLabel(
      'Business idea input field. Type your idea and tap Validate.',
    ),
    text,
  );
  await tester.pump();
}

void main() {
  group('IdeaInputScreen', () {
    testWidgets('empty idea disables Validate button', (tester) async {
      final repository = _FakeIdeaRepository(
        plausibility: _plausibility(verdict: 'pass'),
      );

      await tester.pumpWidget(_testApp(repository: repository));
      await tester.pump();

      final button = find.widgetWithText(FilledButton, 'Validate');
      expect(button, findsOneWidget);
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
    });

    testWidgets('short idea shows blur validation error', (tester) async {
      final repository = _FakeIdeaRepository(
        plausibility: _plausibility(verdict: 'pass'),
      );

      await tester.pumpWidget(_testApp(repository: repository));
      await tester.pump();

      await _enterIdea(tester, 'tiny');
      expect(find.text('Tell us a bit more about your idea'), findsNothing);

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();

      expect(find.text('Tell us a bit more about your idea'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Validate'))
            .onPressed,
        isNull,
      );
    });

    testWidgets('valid idea enables Validate button and character count', (
      tester,
    ) async {
      final repository = _FakeIdeaRepository(
        plausibility: _plausibility(verdict: 'pass'),
      );

      await tester.pumpWidget(_testApp(repository: repository));
      await tester.pump();

      await _enterIdea(tester, 'A marketplace for local test chefs');

      expect(find.text('34 characters'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Validate'))
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('context expander toggles fields open and closed', (
      tester,
    ) async {
      final repository = _FakeIdeaRepository(
        plausibility: _plausibility(verdict: 'pass'),
      );

      await tester.pumpWidget(_testApp(repository: repository));
      await tester.pump();

      expect(find.text('Target Audience'), findsNothing);

      await tester.tap(find.text('Add context (optional)'));
      await tester.pumpAndSettle();

      expect(find.text('Target Audience'), findsOneWidget);
      expect(find.text('Industry'), findsOneWidget);
      expect(find.text('Monetization Model'), findsOneWidget);
      expect(find.text('Region'), findsOneWidget);

      await tester.tap(find.text('Add context (optional)'));
      await tester.pumpAndSettle();

      expect(find.text('Target Audience'), findsNothing);
    });

    testWidgets('plausibility pass navigates to War Room with idea id', (
      tester,
    ) async {
      var navigatedIdeaId = '';
      final repository = _FakeIdeaRepository(
        plausibility: _plausibility(verdict: 'pass'),
      );

      await tester.pumpWidget(
        _testApp(
          repository: repository,
          onWarRoom: (ideaId) => navigatedIdeaId = ideaId,
        ),
      );
      await tester.pump();

      await _enterIdea(tester, 'A validation platform for founders');
      await tester.tap(find.widgetWithText(FilledButton, 'Validate'));
      await tester.pumpAndSettle();

      expect(repository.createCalls, 1);
      expect(repository.plausibilityCalls, 1);
      expect(navigatedIdeaId, 'idea-123');
      expect(find.text('War Room idea-123'), findsOneWidget);
    });

    testWidgets('plausibility refine displays info feedback card', (
      tester,
    ) async {
      final repository = _FakeIdeaRepository(
        plausibility: _plausibility(
          verdict: 'refine',
          guidance: [
            'Name the customer segment.',
            'Clarify how customers pay.',
          ],
        ),
      );

      await tester.pumpWidget(_testApp(repository: repository));
      await tester.pump();

      await _enterIdea(tester, 'A validation platform for founders');
      await tester.tap(find.widgetWithText(FilledButton, 'Validate'));
      await tester.pumpAndSettle();

      final card = tester.widget<ErrorCard>(find.byType(ErrorCard));
      expect(card.type, FeedbackType.info);
      expect(find.textContaining('Name the customer segment.'), findsOneWidget);
      expect(find.textContaining('Clarify how customers pay.'), findsOneWidget);
    });

    testWidgets('plausibility reject displays error feedback card', (
      tester,
    ) async {
      final repository = _FakeIdeaRepository(
        plausibility: _plausibility(
          verdict: 'reject',
          reason: 'This is not a business idea yet.',
        ),
      );

      await tester.pumpWidget(_testApp(repository: repository));
      await tester.pump();

      await _enterIdea(tester, 'A validation platform for founders');
      await tester.tap(find.widgetWithText(FilledButton, 'Validate'));
      await tester.pumpAndSettle();

      final card = tester.widget<ErrorCard>(find.byType(ErrorCard));
      expect(card.type, FeedbackType.error);
      expect(find.text('This is not a business idea yet.'), findsOneWidget);
    });

    testWidgets('loading state replaces Validate label with progress', (
      tester,
    ) async {
      final repository = _FakeIdeaRepository(
        plausibility: _plausibility(verdict: 'pass'),
        delay: const Duration(milliseconds: 200),
      );

      await tester.pumpWidget(_testApp(repository: repository));
      await tester.pump();

      await _enterIdea(tester, 'A validation platform for founders');
      await tester.tap(find.widgetWithText(FilledButton, 'Validate'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Validate'), findsNothing);

      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
    });

    testWidgets('API error displays retryable error card', (tester) async {
      final repository = _FakeIdeaRepository(
        plausibility: _plausibility(verdict: 'pass'),
        shouldThrow: true,
      );

      await tester.pumpWidget(_testApp(repository: repository));
      await tester.pump();

      await _enterIdea(tester, 'A validation platform for founders');
      await tester.tap(find.widgetWithText(FilledButton, 'Validate'));
      await tester.pumpAndSettle();

      final card = tester.widget<ErrorCard>(find.byType(ErrorCard));
      expect(card.type, FeedbackType.error);
      expect(
        find.text('Something went wrong while validating your idea.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
