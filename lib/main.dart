import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/room_screen.dart';
import 'services/game_service.dart';
import 'services/auth_service.dart';
import 'services/multiplayer_service.dart';
import 'services/ads_service.dart';
import 'services/iap_service.dart';
import 'services/error_service.dart';
import 'services/achievement_service.dart';
import 'services/shop_service.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (DefaultFirebaseOptions.currentPlatform != null) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } else {
    await Firebase.initializeApp();
  }

  // Initialize Ads & IAP (non-blocking)
  AdsService().initialize();
  IAPService().init();

  runApp(const DouDiZhuApp());
}

class DouDiZhuApp extends StatelessWidget {
  const DouDiZhuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameService>(create: (_) => GameService()),
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<MultiplayerService>(create: (_) => MultiplayerService()),
        ChangeNotifierProvider<AchievementService>(
            create: (_) => AchievementService()..load()),
        ChangeNotifierProvider<ShopService>(create: (_) => ShopService()..load()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '斗地主',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        initialRoute: HomeScreen.routeName,
        routes: {
          HomeScreen.routeName: (_) => const HomeScreen(),
          GameScreen.routeName: (_) => const GameScreen(),
          ShopScreen.routeName: (_) => const ShopScreen(),
          LobbyScreen.routeName: (_) => const LobbyScreen(),
          ProfileScreen.routeName: (_) => const ProfileScreen(),
          LeaderboardScreen.routeName: (_) => const LeaderboardScreen(),
          RoomScreen.routeName: (_) => const RoomScreen(),
        },
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: ErrorService().messengerKey,
      ),
    );
  }
}