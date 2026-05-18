/// VentureIQ API Response Envelope Parser
///
/// Matches the backend response format:
/// - Success: `{ "data": { ... }, "meta": { "request_id": "uuid" } }`
/// - Error: `{ "error": { "code": "...", "message": "...", "details": { ... } }, "meta": { "request_id": "uuid" } }`
library;

/// Metadata attached to every API response.
class ApiMeta {
  const ApiMeta({this.requestId});

  /// Parse from JSON map
  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      requestId: json['request_id'] as String?,
    );
  }

  /// Unique request identifier for tracing
  final String? requestId;
}

/// Successful API response envelope.
///
/// [T] is the type of the parsed `data` payload.
class ApiResponse<T> {
  const ApiResponse({
    required this.data,
    this.meta,
  });

  /// The parsed response payload
  final T data;

  /// Response metadata (request_id, etc.)
  final ApiMeta? meta;

  /// Parse a raw JSON map into an [ApiResponse].
  ///
  /// [fromJson] converts the `data` field into type [T].
  static ApiResponse<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJson,
  ) {
    return ApiResponse<T>(
      data: fromJson(json['data']),
      meta: json['meta'] != null
          ? ApiMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Structured API error from the backend error envelope.
class ApiError {
  const ApiError({
    required this.code,
    required this.message,
    this.details,
    this.meta,
  });

  /// Parse from the full error response JSON
  factory ApiError.fromJson(Map<String, dynamic> json) {
    final errorObj = json['error'];
    final errorMap = errorObj is Map<String, dynamic> ? errorObj : null;

    return ApiError(
      code: errorMap?['code'] as String? ?? 'UNKNOWN_ERROR',
      message: errorMap?['message'] as String? ?? 'An unknown error occurred',
      details: errorMap?['details'] as Map<String, dynamic>?,
      meta: json['meta'] != null
          ? ApiMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Machine-readable error code
  final String code;

  /// Human-readable error message
  final String message;

  /// Additional error context
  final Map<String, dynamic>? details;

  /// Response metadata
  final ApiMeta? meta;

  @override
  String toString() => 'ApiError(code: $code, message: $message)';
}

/// Utility to parse API responses into success or error types.
class ApiResponseParser {
  ApiResponseParser._();

  /// Parse a response map, returning either [ApiResponse] or throwing [ApiError].
  ///
  /// If the response contains an `error` key, throws [ApiError].
  /// Otherwise, parses as [ApiResponse<T>].
  static ApiResponse<T> parse<T>(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJson,
  ) {
    if (json.containsKey('error')) {
      throw ApiError.fromJson(json);
    }
    if (!json.containsKey('data')) {
      throw const ApiError(
        code: 'MISSING_DATA',
        message: 'The API response is missing the required data field.',
      );
    }
    return ApiResponse.fromJson<T>(json, fromJson);
  }
}
