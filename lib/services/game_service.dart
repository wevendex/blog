import 'package:flutter/foundation.dart';

import '../models/player.dart';
import '../models/deck.dart';
import '../models/card.dart';
import '../game/doudizhu_engine.dart';
import 'analytics_service.dart';

class GameService extends ChangeNotifier {
  DouDiZhuEngine? _engine;

  DouDiZhuEngine get engine => _engine!;

  bool get isInGame => _engine != null;

  void startNewGame() {
    _engine = DouDiZhuEngine();
    _engine!.start();
    AnalyticsService().logGameStart();
    notifyListeners();
  }

  void playCards(Player player, List<CardModel> cards) {
    if (_engine == null) return;
    _engine!.playCards(player, cards);
    if (_engine!.winner != null) {
      // Game finished
    }
    notifyListeners();
  }

  void pass(Player player) {
    if (_engine == null) return;
    _engine!.pass(player);
    notifyListeners();
  }

  void endGame() {
    _engine = null;
    notifyListeners();
  }

  void replaceEngine(DouDiZhuEngine eng) {
    _engine = eng;
    notifyListeners();
  }
}