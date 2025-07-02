import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'services/game_service.dart';
import 'services/auth_service.dart';
import 'services/multiplayer_service.dart';
import 'services/ads_service.dart';
import 'services/iap_service.dart';
import 'firebase_options.dart';

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
        },
      ),
    );
  }
}