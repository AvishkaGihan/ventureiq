import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ventureiq_app/features/auth/data/usage_repository.dart';
import 'package:ventureiq_app/features/auth/domain/usage_entity.dart';
import 'package:ventureiq_app/features/auth/presentation/usage_providers.dart';

/// Loads and refreshes report usage status.
class UsageNotifier extends AsyncNotifier<UsageStatus>
    with WidgetsBindingObserver {
  late UsageRepository _repository;

  @override
  FutureOr<UsageStatus> build() async {
    _repository = ref.read(usageRepositoryProvider);
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));
    return _repository.getUsage();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refreshUsage());
    }
  }

  /// Refresh usage after foregrounding or report generation.
  Future<void> refreshUsage() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.getUsage);
  }
}
