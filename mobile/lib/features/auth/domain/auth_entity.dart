import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_entity.freezed.dart';
part 'auth_entity.g.dart';

/// Represents an authenticated user in the VentureIQ system.
///
/// Used across the auth feature to represent user identity and attributes.
/// The [isAnonymous] flag distinguishes anonymous from Google-authenticated users.
/// The [tier] field is exposed for Story 2.4 (rate limiting by tier).
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    String? email,
    String? displayName,
    @Default('free') String tier,
    @Default('anonymous') String authMethod,
    @Default(true) bool isAnonymous,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);
}
