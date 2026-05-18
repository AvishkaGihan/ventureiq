/// VentureIQ API Endpoint Constants
///
/// Centralized endpoint definitions for all backend API routes.
/// All paths are relative to the base URL configured in [DioClient].
class ApiEndpoints {
  ApiEndpoints._();

  /// API version prefix
  static const String basePath = '/api/v1';

  // ──────────────────────────────────────────────────────────────
  // Health
  // ──────────────────────────────────────────────────────────────

  /// Health check endpoint
  static const String health = '$basePath/health';

  // ──────────────────────────────────────────────────────────────
  // Ideas
  // ──────────────────────────────────────────────────────────────

  /// Submit a new idea for validation
  static const String ideas = '$basePath/ideas';

  /// Get idea by ID — append /{id}
  static const String ideaById = '$basePath/ideas';

  // ──────────────────────────────────────────────────────────────
  // Reports
  // ──────────────────────────────────────────────────────────────

  /// List reports / get report
  static const String reports = '$basePath/reports';

  // ──────────────────────────────────────────────────────────────
  // Auth
  // ──────────────────────────────────────────────────────────────

  /// Firebase token → JWT exchange
  static const String authExchange = '$basePath/auth/exchange';
}
