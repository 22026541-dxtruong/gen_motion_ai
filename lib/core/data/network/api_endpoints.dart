import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  static String get baseUrl {
    final envBaseUrl = dotenv.env['BASE_URL']?.trim();
    if (envBaseUrl != null && envBaseUrl.isNotEmpty) {
      return _normalizeBaseUrl(envBaseUrl);
    }

    // Use 10.0.2.2 for Android Emulator to access host localhost
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  // Authentication
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleAuth = '/auth/google';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String logoutAll = '/auth/logout-all';
  static const String changePassword = '/auth/change-password';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // User
  static const String userMe = '/users/me';
  static const String userById = '/users/{userId}';
  static const String userTopUpCredits = '/users/me/credits/topup';

  // Credits
  static const String creditsBalance = '/credits/balance';
  static const String creditsTransactions = '/credits/transactions';

  // Jobs
  static const String jobs = '/jobs';
  static const String createVideoJob = '/jobs/video';
  static String jobById(String jobId) => '/jobs/$jobId';
  static String jobResult(String jobId) => '/jobs/$jobId/result';
  static String jobCancel(String jobId) => '/jobs/$jobId/cancel';
  static String jobEvents(String jobId) => '/jobs/$jobId/events';
  static String jobLogs(String jobId) => '/jobs/$jobId/logs';

  // Assets
  static const String assetUpload = '/assets/upload';
  static String assetById(String assetId) => '/assets/$assetId';
  static String assetDownload(String assetId) => '/assets/download/$assetId';
  static String assetVersions(String assetId) => '/assets/$assetId/versions';

  // Gallery
  static const String gallery = '/gallery';
  static String galleryItem(String itemId) => '/gallery/$itemId';

  // Posts (Social)
  static const String posts = '/posts';
  static const postById = '/posts/{id}';
  static const postLike = '/posts/{postId}/post-likes';
  static const postComments = '/posts/{postId}/comments';
  static const postCommentById = '/posts/{postId}/comments/{id}';

  // Explore
  static const String explore = '/explore';
  static const String exploreForYou = '/explore/for-you';
  static const String exploreEvents = '/explore/events';
  static const String exploreEventsBatch = '/explore/events/batch';

  // Follow
  static const String follows = '/follows';
  static const String followByUserId = '/follows/{userId}';
  static const String userFollowers = '/users/{userId}/followers';
  static const String userFollowings = '/users/{userId}/followings';

  // Canvas
  static const String canvasSessions = '/canvas/sessions';
  static String canvasSessionById(String sessionId) =>
      '/canvas/sessions/$sessionId';

  // Smart Icons
  static const String smartIcons = '/smart-icons';

  static String absoluteUrl(String path) => '$baseUrl$path';

  static String _normalizeBaseUrl(String url) {
    if (url.endsWith('/')) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }
}
