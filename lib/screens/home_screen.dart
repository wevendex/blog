import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../services/game_service.dart';
import '../services/auth_service.dart';
import '../services/tutorial_service.dart';
import '../services/ads_service.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _startKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Delay tutorial until after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorial();
    });
  }

  void _showTutorial() {
    TutorialService().showTutorial(context, [
      TargetFocus(
        identify: "start_button",
        keyTarget: _startKey,
        contents: [
          TargetContent(
            child: const Text('点击这里开始一局游戏', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final gameService = Provider.of<GameService>(context, listen: false);
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('欢乐斗地主'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              key: _startKey,
              onPressed: () {
                gameService.startNewGame();
                Navigator.pushNamed(context, GameScreen.routeName);
              },
              child: const Text('开始游戏'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to multiplayer lobby
              },
              child: const Text('联机对战'),
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
                if (auth.isLoggedIn) {
                  auth.signOut();
                } else {
                  auth.signInAnonymously();
                }
              },
              child: Text(auth.isLoggedIn ? '退出登录' : '匿名登录'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 50,
        child: FutureBuilder(
          future: AdsService().initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AdWidget(ad: AdsService().getBannerAd());
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}