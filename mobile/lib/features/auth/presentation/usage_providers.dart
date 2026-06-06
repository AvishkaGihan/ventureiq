import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ventureiq_app/core/networking/dio_client.dart';
import 'package:ventureiq_app/features/auth/data/usage_repository.dart';
import 'package:ventureiq_app/features/auth/domain/usage_entity.dart';
import 'package:ventureiq_app/features/auth/presentation/usage_notifier.dart';

/// Provider for [UsageRepository].
final usageRepositoryProvider = Provider<UsageRepository>((ref) {
  return UsageRepository(dio: DioClient.instance.dio);
});

/// Provider for the current user's usage status.
final usageNotifierProvider =
    AsyncNotifierProvider<UsageNotifier, UsageStatus>(UsageNotifier.new);
