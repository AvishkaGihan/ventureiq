import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ventureiq_app/core/networking/dio_client.dart';
import 'package:ventureiq_app/features/idea_input/data/idea_remote_data_source.dart';
import 'package:ventureiq_app/features/idea_input/data/idea_repository.dart';
import 'package:ventureiq_app/features/idea_input/presentation/idea_input_notifier.dart';

/// Provider for the idea remote data source.
final ideaRemoteDataSourceProvider = Provider<IdeaRemoteDataSource>((ref) {
  return IdeaRemoteDataSource(dio: DioClient.instance.dio);
});

/// Provider for the idea repository.
final ideaRepositoryProvider = Provider<IdeaRepository>((ref) {
  return RemoteIdeaRepository(
    remoteDataSource: ref.read(ideaRemoteDataSourceProvider),
  );
});

/// Provider for the idea input form and submission workflow.
final ideaInputNotifierProvider =
    AsyncNotifierProvider<IdeaInputNotifier, IdeaInputState>(
      IdeaInputNotifier.new,
    );
