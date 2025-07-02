import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _localNotifications;
  late FirebaseMessaging _firebaseMessaging;

  static Future<void> init() async {
    await NotificationService()._initialize();
  }

  Future<void> _initialize() async {
    _localNotifications = FlutterLocalNotificationsPlugin();
    _firebaseMessaging = FirebaseMessaging.instance;

    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
  }

  // 初始化本地通知
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // 初始化Firebase消息
  Future<void> _initializeFirebaseMessaging() async {
    // 请求通知权限
    await requestNotificationPermission();

    // 获取FCM令牌
    String? token = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('FCM Token: $token');
    }

    // 监听令牌刷新
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      if (kDebugMode) {
        print('FCM Token refreshed: $token');
      }
      // 可以在这里将新令牌发送到服务器
    });

    // 处理前台消息
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 处理应用从后台恢复时的消息
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // 处理应用终止时的消息
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  // 请求通知权限
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    
    if (status.isGranted) {
      // 对于Firebase消息，还需要额外的权限设置
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }

    return false;
  }

  // 发送本地通知
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'game_channel',
      '游戏通知',
      channelDescription: '斗地主游戏相关通知',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  // 预定义的游戏通知
  Future<void> showGameInviteNotification(String playerName) async {
    await showLocalNotification(
      id: 1,
      title: '游戏邀请',
      body: '$playerName 邀请你一起斗地主！',
      payload: 'game_invite',
    );
  }

  Future<void> showDailyRewardNotification() async {
    await showLocalNotification(
      id: 2,
      title: '每日奖励',
      body: '你的每日奖励已准备好！快来领取吧～',
      payload: 'daily_reward',
    );
  }

  Future<void> showTournamentNotification() async {
    await showLocalNotification(
      id: 3,
      title: '锦标赛开始',
      body: '新的锦标赛即将开始，赶快参加吧！',
      payload: 'tournament',
    );
  }

  Future<void> showLowCoinsNotification() async {
    await showLocalNotification(
      id: 4,
      title: '金币不足',
      body: '你的金币快用完了，去商城购买更多金币吧！',
      payload: 'low_coins',
    );
  }

  // 安排定时通知
  Future<void> scheduleDailyReward() async {
    await _localNotifications.zonedSchedule(
      5,
      '每日奖励',
      '记得来领取今天的每日奖励哦！',
      tz.TZDateTime.from(_getNextDailyRewardTime(), tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          '每日提醒',
          channelDescription: '每日奖励提醒',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'daily_reward_scheduled',
    );
  }

  // 获取下一次每日奖励时间（每天上午10点）
  DateTime _getNextDailyRewardTime() {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 10);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // 处理前台消息
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message: ${message.notification?.title}');
    }

    // 在前台显示本地通知
    if (message.notification != null) {
      showLocalNotification(
        id: message.hashCode,
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  // 处理后台消息
  void _handleBackgroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Background message: ${message.notification?.title}');
    }

    // 根据消息类型进行不同的处理
    final messageType = message.data['type'];
    switch (messageType) {
      case 'game_invite':
        // 处理游戏邀请
        break;
      case 'tournament':
        // 处理锦标赛通知
        break;
      case 'reward':
        // 处理奖励通知
        break;
      default:
        break;
    }
  }

  // 处理通知点击
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (kDebugMode) {
      print('Notification tapped with payload: $payload');
    }

    // 根据payload处理不同的跳转逻辑
    switch (payload) {
      case 'game_invite':
        // 跳转到游戏邀请页面
        break;
      case 'daily_reward':
        // 跳转到每日奖励页面
        break;
      case 'tournament':
        // 跳转到锦标赛页面
        break;
      case 'low_coins':
        // 跳转到商城页面
        break;
      default:
        break;
    }
  }

  // 获取FCM令牌
  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  // 订阅主题
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // 取消订阅主题
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  // 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // 取消特定通知
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}