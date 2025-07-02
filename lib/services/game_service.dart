import 'package:flutter/foundation.dart';

import '../models/player.dart';
import '../models/deck.dart';
import '../models/card.dart';
import '../game/doudizhu_engine.dart';
import 'analytics_service.dart';
import 'error_service.dart';

class GameService extends ChangeNotifier {
  DouDiZhuEngine? _engine;

  DouDiZhuEngine get engine => _engine!;

  bool get isInGame => _engine != null;

  void startNewGame() {
    try {
      _engine = DouDiZhuEngine();
      _engine!.start();
      AnalyticsService().logGameStart();
    } catch (e) {
      ErrorService().showError('无法开始新游戏: $e');
    }
    notifyListeners();
  }

  void playCards(Player player, List<CardModel> cards) {
    try {
      if (_engine == null) return;
      _engine!.playCards(player, cards);
      if (_engine!.winner != null) {
        // Game finished
      }
    } catch (e) {
      ErrorService().showError('出牌失败: $e');
    }
    notifyListeners();
  }

  void pass(Player player) {
    try {
      if (_engine == null) return;
      _engine!.pass(player);
    } catch (e) {
      ErrorService().showError('跳过出牌失败: $e');
    }
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