THIS SHOULD BE A LINTER ERRORimport 'package:flutter/foundation.dart';

class Profile {
  String uid;
  String nickname;
  String avatarUrl;
  int wins;
  int losses;
  int stars;
  Profile({
    required this.uid,
    required this.nickname,
    required this.avatarUrl,
    this.wins = 0,
    this.losses = 0,
    this.stars = 0,
  });
}

class ProfileService extends ChangeNotifier {
  Profile _profile = Profile(uid: 'local', nickname: '游客', avatarUrl: '');
  Profile get me => _profile;

  // Mock leaderboard
  List<Profile> _leaderboard = [];
  List<Profile> get leaderboard => _leaderboard;

  Future<void> load() async {
    // TODO: Load from Firestore. Here use mock data.
    _leaderboard = [
      Profile(uid: '1', nickname: '高手A', avatarUrl: '', stars: 150),
      Profile(uid: '2', nickname: '高手B', avatarUrl: '', stars: 120),
      _profile,
    ];
    notifyListeners();
  }

  void updateStats({int winDelta = 0, int lossDelta = 0, int starDelta = 0}) {
    _profile.wins += winDelta;
    _profile.losses += lossDelta;
    _profile.stars += starDelta;
    notifyListeners();
  }
}