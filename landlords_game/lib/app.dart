import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';


import 'views/auth/login_page.dart';
import 'views/auth/register_page.dart';
import 'views/home/home_page.dart';
import 'views/game/game_lobby_page.dart';
import 'views/game/game_room_page.dart';
import 'views/game/game_play_page.dart';
import 'views/shop/shop_page.dart';
import 'views/profile/profile_page.dart';
import 'views/leaderboard/leaderboard_page.dart';
import 'views/auth/splash_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // 启动页
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      
      // 认证页面
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      
      // 主页
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      
      // 游戏相关页面
      GoRoute(
        path: '/game-lobby',
        name: 'game-lobby',
        builder: (context, state) => const GameLobbyPage(),
      ),
      GoRoute(
        path: '/game-room/:roomId',
        name: 'game-room',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId']!;
          return GameRoomPage(roomId: roomId);
        },
      ),
      GoRoute(
        path: '/game-play/:gameId',
        name: 'game-play',
        builder: (context, state) {
          final gameId = state.pathParameters['gameId']!;
          return GamePlayPage(gameId: gameId);
        },
      ),
      
      // 商城
      GoRoute(
        path: '/shop',
        name: 'shop',
        builder: (context, state) => const ShopPage(),
      ),
      
      // 个人中心
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      
      // 排行榜
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardPage(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '抱歉，页面未找到',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}