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
  static String userById(String userId) => '/users/$userId';

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
  static String postById(String postId) => '/posts/$postId';
  static String postLike(String postId) => '/posts/$postId/post-like';
  static String postComments(String postId) => '/posts/$postId/comments';
  static String postCommentById(String postId, String commentId) => '/posts/$postId/comments/$commentId';

  // Explore
  static const String explore = '/explore';

  // Follow
  static String userFollow(String userId) => '/users/$userId/follow';
  static String userFollowers(String userId) => '/users/$userId/followers';
  static String userFollowing(String userId) => '/users/$userId/following';

  // Canvas
  static const String canvasSessions = '/canvas/sessions';
  static String canvasSessionById(String sessionId) =>
      '/canvas/sessions/$sessionId';

  // Smart Icons
  static const String smartIcons = '/smart-icons';
}
