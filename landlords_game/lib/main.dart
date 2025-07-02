import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/services/audio_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置屏幕方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 初始化Firebase
  await Firebase.initializeApp();
  
  // 初始化Hive数据库
  await Hive.initFlutter();
  await StorageService.init();
  
  // 初始化服务
  await AudioService.init();
  await NotificationService.init();

  runApp(
    const ProviderScope(
      child: LandlordsGameApp(),
    ),
  );
}

class LandlordsGameApp extends ConsumerWidget {
  const LandlordsGameApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: '斗地主游戏',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'CN'),
            Locale('en', 'US'),
          ],
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
