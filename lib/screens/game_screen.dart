import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'dart:math' as math;

import '../services/game_service.dart';
import '../services/analytics_service.dart';
import '../services/multiplayer_service.dart';
import '../utils/tone_generator.dart';
import '../widgets/playing_card_widget.dart';
import '../widgets/card_tracker.dart';
import '../models/player.dart';
import '../models/card.dart';
import '../game/doudizhu_engine.dart';
import '../services/tutorial_service.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../services/achievement_service.dart';

class GameScreen extends StatefulWidget {
  static const String routeName = '/game';
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<CardModel> _selected = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _dealt = false;
  bool _showCardTracker = true;

  final GlobalKey _playBtnKey = GlobalKey();
  final GlobalKey _passBtnKey = GlobalKey();
  final GlobalKey _handKey = GlobalKey();
  final GlobalKey _trackerKey = GlobalKey();

  late ConfettiController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3));
    
    // 重置记牌器（新游戏开始）
    CardTrackerManager.reset();
    
    // Start dealing animation when screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _audioPlayer.play(BytesSource(ToneGenerator.generateTone(freq: 300, durationSeconds: 0.4)));
      setState(() => _dealt = true);

      // After cards are visible, show in-game tutorial.
      Future.delayed(const Duration(milliseconds: 900), _showTutorial);
    });

    AchievementService().newAchievementStream.listen((ach) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('成就解锁: ${ach.title} +${ach.chips}金币')));
      }
    });
  }

  void _showTutorial() {
    TutorialService().showTutorial(context, [
      TargetFocus(
        identify: 'hand',
        keyTarget: _handKey,
        contents: [
          TargetContent(child: const Text('点击手牌进行选择')),
        ],
      ),
      TargetFocus(
        identify: 'tracker',
        keyTarget: _trackerKey,
        contents: [
          TargetContent(child: const Text('记牌器帮助您追踪已出的牌')),
        ],
      ),
      TargetFocus(
        identify: 'playBtn',
        keyTarget: _playBtnKey,
        contents: [
          TargetContent(child: const Text('选好牌后点击这里出牌')),
        ],
      ),
      TargetFocus(
        identify: 'passBtn',
        keyTarget: _passBtnKey,
        contents: [
          TargetContent(child: const Text('若无法或不想出牌，点击"不出"')),
        ],
      ),
    ]);
  }

  void _checkWin(GameService game) {
    if (game.engine.winner != null) {
      _confettiCtrl.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameService, MultiplayerService>(
      builder: (context, game, multiplayer, _) {
        _checkWin(game);
        // Synchronize from multiplayer state if available.
        if (multiplayer.room?.engineState != null) {
          final eng = DouDiZhuEngine.fromMap(multiplayer.room!.engineState!);
          game.replaceEngine(eng);
        }

        if (!game.isInGame) {
          return const Scaffold(
            body: Center(child: Text('游戏未开始')),
          );
        }
        final player = game.engine.players.first; // human
        final topAi = game.engine.players[1];

        return Scaffold(
          appBar: AppBar(
            title: const Text('欢乐斗地主'),
            centerTitle: true,
            backgroundColor: Colors.black87,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(_showCardTracker ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _showCardTracker = !_showCardTracker;
                  });
                },
                tooltip: '切换记牌器显示',
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1a4c40), Color(0xFF2d5a27), Color(0xFF1a3d1a)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                // 左侧：记牌器区域
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // 记牌器
                      if (_showCardTracker)
                        Container(
                          key: _trackerKey,
                          child: CardTracker(
                            playedCards: CardTrackerManager.allPlayedCards,
                            isVisible: _showCardTracker,
                          ),
                        ),
                      const Spacer(),
                      // 游戏状态信息
                      _buildGameInfo(game),
                    ],
                  ),
                ),
                
                // 右侧：主游戏区域
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          // 上方AI玩家
                          SizedBox(
                            height: 120,
                            child: _aiHandView(topAi),
                          ),
                          
                          // 中央出牌区域
                          Expanded(
                            child: _centerPlayArea(game),
                          ),
                          
                          // 玩家手牌区域
                          SizedBox(
                            height: 140,
                            child: _playerHandView(player),
                          ),
                          
                          // 控制按钮
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _controlButtons(game, player, multiplayer),
                          ),
                        ],
                      ),
                      
                      // 回合指示器
                      _turnIndicator(),
                      
                      // 获胜庆祝动画
                      Align(
                        alignment: Alignment.center,
                        child: ConfettiWidget(
                          confettiController: _confettiCtrl,
                          blastDirectionality: BlastDirectionality.explosive,
                          shouldLoop: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _aiHandView(Player ai) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // AI头像
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.android,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          
          // AI信息
          Column(
            children: [
              Text(
                ai.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '剩余: ${ai.hand.length} 张',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          // 手牌背面显示
          const SizedBox(width: 16),
          ...List.generate(
            math.min(ai.hand.length, 8), // 最多显示8张牌背面
            (index) => Container(
              margin: EdgeInsets.only(left: index * -25.0),
              child: Transform.rotate(
                angle: (index - 4) * 0.1, // 轻微的扇形排列
                child: Container(
                  width: 50,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Center(
                    child: Text(
                      '🂠',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _centerPlayArea(GameService game) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 出牌区域标题
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '出牌区域',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // 出牌显示区域
          Container(
            width: double.infinity,
            height: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: game.engine.lastPlayed != null && game.engine.lastPlayed!.isNotEmpty
                ? Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: game.engine.lastPlayed!
                          .map((card) => PlayingCardWidget(
                                card: card,
                                isPlayAnimation: false,
                              ))
                          .toList(),
                    ),
                  )
                : const Center(
                    child: Text(
                      '等待出牌...',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 18,
                      ),
                    ),
                  ),
          ),
          
          // 当前回合信息
          const SizedBox(height: 16),
          Text(
            '当前回合: ${game.engine.currentPlayer?.name ?? "无"}',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerHandView(Player player) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 玩家信息
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '我的手牌 (${player.hand.length}张)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selected.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '已选择: ${_selected.length}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // 手牌区域
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _dealt ? 1 : 0,
              child: SingleChildScrollView(
                key: _handKey,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: player.hand.asMap().entries
                      .map(
                        (entry) {
                          final index = entry.key;
                          final card = entry.value;
                          return PlayingCardWidget(
                            card: card,
                            isSelected: _selected.contains(card),
                            isDealAnimation: !_dealt,
                            animationDelay: Duration(milliseconds: index * 100),
                            onTap: () {
                              setState(() {
                                if (_selected.contains(card)) {
                                  _selected.remove(card);
                                } else {
                                  _selected.add(card);
                                }
                              });
                            },
                          );
                        },
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButtons(GameService game, Player player, MultiplayerService multiplayer) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 提示按钮
          Expanded(
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  _showHint();
                },
                icon: const Icon(Icons.lightbulb, size: 20),
                label: const Text('提示'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ),
          
          // 不出按钮
          Expanded(
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton.icon(
                key: _passBtnKey,
                onPressed: () async {
                  game.pass(player);
                  await _audioPlayer.play(BytesSource(ToneGenerator.generateTone(freq: 200)));
                  if (multiplayer.room != null) {
                    multiplayer.updateEngine(game.engine);
                  }
                  // 清除选择
                  setState(() {
                    _selected.clear();
                  });
                },
                icon: const Icon(Icons.close, size: 20),
                label: const Text('不出'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ),
          
          // 出牌按钮
          Expanded(
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton.icon(
                key: _playBtnKey,
                onPressed: _selected.isNotEmpty
                    ? () async {
                        // 添加到记牌器
                        CardTrackerManager.addPlayedCards(List.from(_selected));
                        
                        // 播放出牌动画和音效
                        await _audioPlayer.play(BytesSource(ToneGenerator.generateTone(freq: 600)));
                        
                        // 执行出牌逻辑
                        game.playCards(player, List.from(_selected));
                        
                        // 记录分析数据
                        AnalyticsService().logPlayCards(_selected.length);
                        
                        // 清除选择
                        setState(() {
                          _selected.clear();
                        });
                        
                        // 同步多人游戏状态
                        if (multiplayer.room != null) {
                          multiplayer.updateEngine(game.engine);
                        }
                      }
                    : null,
                icon: const Icon(Icons.play_arrow, size: 20),
                label: Text('出牌${_selected.isNotEmpty ? ' (${_selected.length})' : ''}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selected.isNotEmpty ? Colors.green : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHint() {
    String hintText;
    if (_selected.isEmpty) {
      hintText = '💡 选择要出的牌，可以是单张、对子、顺子等牌型';
    } else if (_selected.length == 1) {
      hintText = '💡 当前选择了单张牌';
    } else if (_selected.length == 2) {
      hintText = '💡 当前选择了对子或火箭';
    } else {
      hintText = '💡 当前选择了${_selected.length}张牌，检查是否为有效牌型';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(hintText),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildGameInfo(GameService game) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '游戏信息',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildInfoRow('游戏状态', game.engine.winner != null ? '游戏结束' : '进行中'),
          _buildInfoRow('当前回合', game.engine.currentPlayer?.name ?? '无'),
          _buildInfoRow('底分', '1'),
          _buildInfoRow('倍数', 'x2'),
          
          if (game.engine.winner != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '🎉 ${game.engine.winner!.name} 获胜！',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _turnIndicator() {
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedRotation(
          turns: _dealt ? 1 : 0,
          duration: const Duration(seconds: 1),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rotate_right,
              size: 32,
              color: Colors.amber,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}