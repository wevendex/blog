import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class Achievement {
  final String id;
  final String title;
  final String desc;
  final int chips;
  Achievement({required this.id, required this.title, required this.desc, required this.chips});

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'],
        title: json['title'],
        desc: json['desc'],
        chips: json['chips'],
      );
}

class AchievementService extends ChangeNotifier {
  final Map<String, Achievement> _all = {};
  final Set<String> _earned = {};

  List<Achievement> get earned => _earned.map((e) => _all[e]!).toList();

  Future<void> load() async {
    final str = await rootBundle.loadString('assets/achievements.json');
    final list = jsonDecode(str) as List;
    for (var item in list) {
      final ach = Achievement.fromJson(item);
      _all[ach.id] = ach;
    }
  }

  bool isEarned(String id) => _earned.contains(id);

  void grant(String id) {
    if (!_all.containsKey(id)) return;
    if (_earned.add(id)) {
      notifyListeners();
    }
  }
}