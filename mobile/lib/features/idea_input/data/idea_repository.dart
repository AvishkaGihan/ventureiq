import 'package:ventureiq_app/features/idea_input/data/idea_remote_data_source.dart';
import 'package:ventureiq_app/features/idea_input/domain/idea_entity.dart';
import 'package:ventureiq_app/features/idea_input/domain/plausibility_entity.dart';

/// Repository contract for idea submission workflows.
abstract class IdeaRepository {
  Future<IdeaEntity> createIdea({
    required String ideaText,
    String? targetAudience,
    String? industry,
    String? monetizationModel,
    String? region,
  });

  Future<PlausibilityEntity> checkPlausibility(String ideaId);
}

/// API-backed implementation of [IdeaRepository].
class RemoteIdeaRepository implements IdeaRepository {
  RemoteIdeaRepository({required IdeaRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final IdeaRemoteDataSource _remoteDataSource;

  @override
  Future<IdeaEntity> createIdea({
    required String ideaText,
    String? targetAudience,
    String? industry,
    String? monetizationModel,
    String? region,
  }) {
    return _remoteDataSource.createIdea(
      ideaText: ideaText,
      targetAudience: targetAudience,
      industry: industry,
      monetizationModel: monetizationModel,
      region: region,
    );
  }

  @override
  Future<PlausibilityEntity> checkPlausibility(String ideaId) {
    return _remoteDataSource.checkPlausibility(ideaId);
  }
}
