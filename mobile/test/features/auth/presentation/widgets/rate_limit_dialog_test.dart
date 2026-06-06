import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ventureiq_app/core/theme/app_theme.dart';
import 'package:ventureiq_app/features/auth/presentation/widgets/rate_limit_dialog.dart';

void main() {
  testWidgets('shows monthly limit and upgrade copy', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: RateLimitDialog(
            reportsUsed: 3,
            reportsLimit: 3,
          ),
        ),
      ),
    );

    expect(find.text('3/3 reports used this month'), findsOneWidget);
    expect(find.text('Upgrade to Pro for unlimited reports.'), findsOneWidget);
    expect(find.text('Upgrade to Pro'), findsOneWidget);
  });
}
