import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';

import '../services/game_service.dart';
import '../services/analytics_service.dart';
import '../services/multiplayer_service.dart';
import '../utils/tone_generator.dart';
import '../widgets/playing_card_widget.dart';
import '../models/player.dart';
import '../models/card.dart';
import '../game/doudizhu_engine.dart';
import '../services/tutorial_service.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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

  final GlobalKey _playBtnKey = GlobalKey();
  final GlobalKey _passBtnKey = GlobalKey();
  final GlobalKey _handKey = GlobalKey();

  late ConfettiController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3));
    // Start dealing animation when screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _audioPlayer.play(BytesSource(ToneGenerator.generateTone(freq: 300, durationSeconds: 0.4)));
      setState(() => _dealt = true);

      // After cards are visible, show in-game tutorial.
      Future.delayed(const Duration(milliseconds: 900), _showTutorial);
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
            title: const Text('斗地主对局'),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  _aiHandView(topAi),
                  const SizedBox(height: 10),
                  Expanded(child: _centerPlayArea(game)),
                  const SizedBox(height: 10),
                  _playerHandView(player),
                  const SizedBox(height: 10),
                  _controlButtons(game, player, multiplayer),
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiCtrl,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _aiHandView(Player ai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text('${ai.name}: ${ai.hand.length} 张'),
    );
  }

  Widget _centerPlayArea(GameService game) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('上次出牌:'),
        const SizedBox(height: 8),
        if (game.engine.lastPlayed != null)
          Wrap(
            children: game.engine.lastPlayed!
                .map((c) => PlayingCardWidget(card: c))
                .toList(),
          )
        else
          const Text('暂未出牌'),
      ],
    );
  }

  Widget _playerHandView(Player player) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: _dealt ? 1 : 0,
      child: SingleChildScrollView(
        key: _handKey,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: player.hand
              .map(
                (card) => PlayingCardWidget(
                  card: card,
                  isSelected: _selected.contains(card),
                  onTap: () {
                    setState(() {
                      if (_selected.contains(card)) {
                        _selected.remove(card);
                      } else {
                        _selected.add(card);
                      }
                    });
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _controlButtons(GameService game, Player player, MultiplayerService multiplayer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          key: _playBtnKey,
          onPressed: _selected.isNotEmpty
              ? () async {
                  game.playCards(player, List.from(_selected));
                  await _audioPlayer.play(BytesSource(ToneGenerator.generateTone(freq: 600)));
                  AnalyticsService().logPlayCards(_selected.length);
                  setState(() {
                    _selected.clear();
                  });
                  if (multiplayer.room != null) {
                    multiplayer.updateEngine(game.engine);
                  }
                }
              : null,
          child: const Text('出牌'),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          key: _passBtnKey,
          onPressed: () async {
            game.pass(player);
            await _audioPlayer.play(BytesSource(ToneGenerator.generateTone(freq: 200)));
            if (multiplayer.room != null) {
              multiplayer.updateEngine(game.engine);
            }
          },
          child: const Text('不出'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}