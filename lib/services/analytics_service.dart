import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logGameStart() async {
    await _analytics.logEvent(name: 'game_start');
  }

  Future<void> logPlayCards(int count) async {
    await _analytics.logEvent(name: 'play_cards', parameters: {'count': count});
  }

  // Add more logging helpers as needed.
}