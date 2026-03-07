import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  static String get baseUrl {
    if (dotenv.env['BASE_URL'] != null && dotenv.env['BASE_URL']!.isNotEmpty) {
      return dotenv.env['BASE_URL']!;
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
  static const String changePassword = '/auth/change-password';

  // User
  static const String userMe = '/users/me';
  static const String userById = '/users/{userId}';

  // Credits
  static const String creditsBalance = '/credits/balance';
  static const String creditsTransactions = '/credits/transactions';

  // Jobs
  static const String jobs = '/jobs';
  static String jobById(String jobId) => '/jobs/$jobId';
  static String jobLogs(String jobId) => '/jobs/$jobId/logs';

  // Assets
  static String assetById(String assetId) => '/assets/$assetId';
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

  // Follow
  static const String userFollow = '/users/{userId}/follows';
  static const String userFollowers = '/users/{userId}/followers';
  static const String userFollowing = '/users/{userId}/following';

  // Canvas
  static const String canvasSessions = '/canvas/sessions';
  static String canvasSessionById(String sessionId) =>
      '/canvas/sessions/$sessionId';

  // Smart Icons
  static const String smartIcons = '/smart-icons';
}
