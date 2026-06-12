import 'package:freezed_annotation/freezed_annotation.dart';

part 'plausibility_entity.freezed.dart';
part 'plausibility_entity.g.dart';

/// Plausibility verdict returned before an idea enters the War Room.
@freezed
abstract class PlausibilityEntity with _$PlausibilityEntity {
  const factory PlausibilityEntity({
    @JsonKey(name: 'verdict') required String verdict,
    @JsonKey(name: 'guidance') List<String>? guidance,
    @JsonKey(name: 'reason') String? reason,
    @JsonKey(name: 'confidence') required double confidence,
  }) = _PlausibilityEntity;

  factory PlausibilityEntity.fromJson(Map<String, dynamic> json) =>
      _$PlausibilityEntityFromJson(json);
}
