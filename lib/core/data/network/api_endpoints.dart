import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Gets from .env or uses default
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
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String logoutAll = '/auth/logout-all';
  static const String changePassword = '/auth/change-password';

  // User
  static const String userMe = '/users/me';
  static const String userById = '/users/{userId}';
  static const String userTopUpCredits = '/users/me/credits/topup';

  // Credits
  static const String creditsBalance = '/users/me/credits';
  static const String creditsTopup = '/users/me/credits/topup';
  static const String creditsTransactions = '/users/me/credits/transactions';

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
  static const String postById = '/posts/{id}';
  static String postLike(String postId) => '/posts/$postId/likes';
  static const String postComments = '/posts/{postId}/comments';
  static const String postCommentById = '/posts/{postId}/comments/{commentId}';

  // Explore
  static const String explore = '/explore';

  // Follow
  static const String userFollows = '/users/{userId}/follows';
  static const String userFollowers = '/users/{userId}/followers';
  static const String userFollowing = '/users/{userId}/following';
  static const String follows = '/follows';

  // Comments
  static const String comments = '/comments';
  static const String commentById = '/comments/{id}';

  // Post Likes
  static const String postLikes = '/post-likes';
  static String postLikeById(String id) => '/post-likes/$id';

  // Modal
  static const String modalGenerateVideo = '/modal/generate-video';

  static String _normalizeBaseUrl(String url) {
    if (url.endsWith('/')) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }
}
