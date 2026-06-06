import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ventureiq_app/core/theme/app_theme.dart';
import 'package:ventureiq_app/features/auth/domain/usage_entity.dart';
import 'package:ventureiq_app/features/auth/presentation/usage_notifier.dart';
import 'package:ventureiq_app/features/auth/presentation/usage_providers.dart';
import 'package:ventureiq_app/features/auth/presentation/widgets/usage_indicator.dart';

class _FakeUsageNotifier extends UsageNotifier {
  _FakeUsageNotifier(this.status);

  final UsageStatus status;

  @override
  FutureOr<UsageStatus> build() => status;

  @override
  Future<void> refreshUsage() async {}
}

void main() {
  testWidgets('renders free tier usage count', (tester) async {
    await _pumpUsage(
      tester,
      UsageStatus(
        reportsUsed: 2,
        reportsLimit: 3,
        tier: 'free',
        resetAt: DateTime.utc(2026, 7),
        limitReached: false,
      ),
    );

    expect(find.text('Reports used this month'), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('FREE'), findsOneWidget);
  });

  testWidgets('renders anonymous tier warning count', (tester) async {
    await _pumpUsage(
      tester,
      UsageStatus(
        reportsUsed: 3,
        reportsLimit: 3,
        tier: 'anonymous',
        resetAt: DateTime.utc(2026, 7),
        limitReached: true,
      ),
    );

    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('ANONYMOUS'), findsOneWidget);
  });

  testWidgets('renders pro tier as unlimited', (tester) async {
    await _pumpUsage(
      tester,
      UsageStatus(
        reportsUsed: 0,
        reportsLimit: 0,
        tier: 'pro',
        resetAt: DateTime.utc(2026, 7),
        limitReached: false,
      ),
    );

    expect(find.text('Unlimited'), findsNWidgets(2));
  });
}

Future<void> _pumpUsage(WidgetTester tester, UsageStatus status) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        usageNotifierProvider.overrideWith(
          () => _FakeUsageNotifier(status),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: UsageIndicator(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
