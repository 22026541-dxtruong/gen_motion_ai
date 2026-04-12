import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Gets from .env or uses default
  static String get baseUrl {
    String url = dotenv.env['BASE_URL'] ?? '';
    
    if (url.isEmpty) {
      // Fallback to proper defaults
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        url = 'http://10.0.2.2:3000/';
      } else {
        url = 'http://localhost:3000/';
      }
    }
    
    // Ensure no trailing slash and has /api/v1
    // url = url.replaceAll(RegExp(r'/+$'), '');
    // if (!url.contains('/api/v1')) {
    //   url = '${url.replaceAll('/api/v1', '')}/api/v1';
    // }
    
    return url;
  }

  // Authentication
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String changePassword = '/auth/change-password';

  // User
  static const String userMe = '/users/me';
  static String userById(String userId) => '/users/$userId';

  // Credits
  static const String creditsBalance = '/users/me/credits';
  static const String creditsTopup = '/users/me/credits/topup';
  static const String creditsTransactions = '/users/me/credits/transactions';

  // Jobs
  static const String jobs = '/jobs';
  static String jobById(String jobId) => '/jobs/$jobId';
  static String jobResult(String jobId) => '/jobs/$jobId/result';
  static String jobCancel(String jobId) => '/jobs/$jobId/cancel';
  static String jobLogs(String jobId) => '/jobs/$jobId/logs';

  // Assets
  static const String assets = '/assets';
  static String assetById(String assetId) => '/assets/$assetId';
  static String assetDownload(String assetId) => '/assets/$assetId/download';
  static String assetVersions(String assetId) => '/assets/$assetId/versions';
  static const String assetUpload = '/assets/upload';

  // Gallery
  static const String gallery = '/gallery';
  static String galleryItem(String itemId) => '/gallery/$itemId';

  // Posts (Social)
  static const String posts = '/posts';
  static String postById(String id) => '/posts/$id';
  static String postLike(String postId) => '/posts/$postId/likes';
  static String postComments(String postId) => '/posts/$postId/comments';
  static String postCommentById(String postId, String commentId) => '/posts/$postId/comments/$commentId';

  // Explore
  static const String explore = '/explore';

  // Follow
  static String userFollows(String userId) => '/users/$userId/follows';
  static String userFollowers(String userId) => '/users/$userId/followers';
  static String userFollowing(String userId) => '/users/$userId/following';
  static const String follows = '/follows';

  // Comments
  static const String comments = '/comments';
  static String commentById(String id) => '/comments/$id';

  // Post Likes
  static const String postLikes = '/post-likes';
  static String postLikeById(String id) => '/post-likes/$id';

  // Modal
  static const String modalGenerateVideo = '/modal/generate-video';
}
