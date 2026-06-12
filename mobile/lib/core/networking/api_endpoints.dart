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

  /// Run the plausibility pre-check for an idea.
  static String ideaPlausibility(String id) => '$ideas/$id/plausibility';

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

  /// Refresh expired access token
  static const String authRefresh = '$basePath/auth/refresh';

  /// Upgrade anonymous account to Google-authenticated
  static const String authUpgrade = '$basePath/auth/upgrade';

  /// Current user's report usage status
  static const String usageMe = '$basePath/usage/me';
}
