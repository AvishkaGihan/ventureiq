import 'package:dio/dio.dart';
import 'package:ventureiq_app/core/networking/api_endpoints.dart';
import 'package:ventureiq_app/core/networking/api_response.dart';
import 'package:ventureiq_app/features/idea_input/domain/idea_entity.dart';
import 'package:ventureiq_app/features/idea_input/domain/plausibility_entity.dart';

/// Remote data source for idea submission and plausibility checks.
class IdeaRemoteDataSource {
  IdeaRemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Map<String, dynamic> _getNonNullData(
    Response<Map<String, dynamic>> response,
  ) {
    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Response data is null',
      );
    }
    return data;
  }

  /// Create a new idea via `POST /api/v1/ideas`.
  Future<IdeaEntity> createIdea({
    required String ideaText,
    String? targetAudience,
    String? industry,
    String? monetizationModel,
    String? region,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.ideas,
      data: {
        'idea_text': ideaText,
        'target_audience': _nullIfBlank(targetAudience),
        'industry': _nullIfBlank(industry),
        'monetization_model': _nullIfBlank(monetizationModel),
        'region': _nullIfBlank(region),
      },
    );

    final parsed = ApiResponseParser.parse(
      _getNonNullData(response),
      (json) => IdeaEntity.fromJson(json as Map<String, dynamic>),
    );

    return parsed.data;
  }

  /// Run plausibility via `POST /api/v1/ideas/{id}/plausibility`.
  Future<PlausibilityEntity> checkPlausibility(String ideaId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.ideaPlausibility(ideaId),
    );

    final parsed = ApiResponseParser.parse(_getNonNullData(response), (json) {
      final data = json as Map<String, dynamic>;
      final p = data['plausibility'];
      if (p == null) throw const FormatException('Missing plausibility key');
      return PlausibilityEntity.fromJson(
        p as Map<String, dynamic>,
      );
    });

    return parsed.data;
  }

  String? _nullIfBlank(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
