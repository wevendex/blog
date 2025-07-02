import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'services/game_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const DouDiZhuApp());
}

class DouDiZhuApp extends StatelessWidget {
  const DouDiZhuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameService>(create: (_) => GameService()),
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