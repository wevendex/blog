import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/game_service.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameService = Provider.of<GameService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('欢乐斗地主'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                gameService.startNewGame();
                Navigator.pushNamed(context, GameScreen.routeName);
              },
              child: const Text('开始游戏'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to shop
              },
              child: const Text('商城'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to profile
              },
              child: const Text('个人信息'),
            ),
          ],
        ),
      ),
    );
  }
}