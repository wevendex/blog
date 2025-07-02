import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../services/game_service.dart';
import '../services/analytics_service.dart';
import '../services/multiplayer_service.dart';
import '../widgets/playing_card_widget.dart';
import '../models/player.dart';
import '../models/card.dart';

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

  @override
  void initState() {
    super.initState();
    // Start dealing animation when screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _audioPlayer.play(AssetSource('sounds/shuffle.wav'));
      setState(() => _dealt = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameService, MultiplayerService>(
      builder: (context, game, multiplayer, _) {
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
          body: Column(
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
          onPressed: _selected.isNotEmpty
              ? () async {
                  game.playCards(player, List.from(_selected));
                  await _audioPlayer.play(AssetSource('sounds/play.wav'));
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
          onPressed: () async {
            game.pass(player);
            await _audioPlayer.play(AssetSource('sounds/pass.wav'));
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
    _audioPlayer.dispose();
    super.dispose();
  }
}