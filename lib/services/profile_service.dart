import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'error_service.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Profile _profile = Profile(uid: 'local', nickname: '游客', avatarUrl: '');
  Profile get me => _profile;

  // Mock leaderboard
  List<Profile> _leaderboard = [];
  List<Profile> get leaderboard => _leaderboard;

  Future<void> load() async {
    try {
      final doc = await _firestore.collection('profiles').doc(_profile.uid).get();
      if (doc.exists) {
        final d = doc.data()!;
        _profile = Profile(
            uid: _profile.uid,
            nickname: d['nick'] ?? '游客',
            avatarUrl: '',
            wins: d['win'] ?? 0,
            losses: d['loss'] ?? 0,
            stars: d['stars'] ?? 0);
      } else {
        await _firestore.collection('profiles').doc(_profile.uid).set({'nick': '游客', 'win': 0, 'loss': 0, 'stars': 0});
      }

      final lbSnap = await _firestore.collection('profiles').orderBy('stars', descending: true).limit(50).get();
      _leaderboard = lbSnap.docs
          .map((e) => Profile(
                uid: e.id,
                nickname: e['nick'],
                avatarUrl: '',
                stars: e['stars'],
              ))
          .toList();
      notifyListeners();
    } catch (e) {
      ErrorService().showError('读取档案失败: $e');
    }
  }

  void updateStats({int winDelta = 0, int lossDelta = 0, int starDelta = 0}) {
    _profile.wins += winDelta;
    _profile.losses += lossDelta;
    _profile.stars += starDelta;
    _firestore.collection('profiles').doc(_profile.uid).update({
      'win': _profile.wins,
      'loss': _profile.losses,
      'stars': _profile.stars,
    });
    notifyListeners();
  }
}