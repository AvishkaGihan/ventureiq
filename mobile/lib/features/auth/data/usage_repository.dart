import 'package:dio/dio.dart';
import 'package:ventureiq_app/core/networking/api_endpoints.dart';
import 'package:ventureiq_app/core/networking/api_response.dart';
import 'package:ventureiq_app/features/auth/domain/usage_entity.dart';

/// Repository for usage status API calls.
class UsageRepository {
  UsageRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Load current report usage for the active user.
  Future<UsageStatus> getUsage() async {
    final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.usageMe);
    final parsed = ApiResponseParser.parse(
      response.data!,
      (json) => UsageStatus.fromJson(json as Map<String, dynamic>),
    );
    return parsed.data;
  }
}
