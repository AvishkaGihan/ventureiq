import 'package:freezed_annotation/freezed_annotation.dart';

part 'idea_entity.freezed.dart';
part 'idea_entity.g.dart';

/// Business idea returned by the VentureIQ ideas API.
@freezed
abstract class IdeaEntity with _$IdeaEntity {
  const factory IdeaEntity({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'idea_text') required String ideaText,
    @JsonKey(name: 'target_audience') String? targetAudience,
    @JsonKey(name: 'industry') String? industry,
    @JsonKey(name: 'monetization_model') String? monetizationModel,
    @JsonKey(name: 'region') String? region,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _IdeaEntity;

  factory IdeaEntity.fromJson(Map<String, dynamic> json) =>
      _$IdeaEntityFromJson(json);
}
