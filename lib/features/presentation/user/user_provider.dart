import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserProvider =
    NotifierProvider<CurrentUserNotifier, CurrentUser?>(CurrentUserNotifier.new);

class CurrentUserNotifier extends Notifier<CurrentUser?> {
  @override
  CurrentUser? build() {
    return null;
  }

  void setUser(CurrentUser user) {
    state = user;
  }

  void logout() {
    state = null;
  }
}

class CurrentUser {
  final String username;
  final String email;
  final String? avatarUrl;
  final String? bio;

  CurrentUser({
    required this.username,
    required this.email,
    this.avatarUrl,
    this.bio,
  });
}