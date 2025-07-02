import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late Box _userBox;
  static late Box _gameBox;
  static late Box _settingsBox;
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    // 初始化Hive
    await Hive.initFlutter();
    
    // 打开数据盒子
    _userBox = await Hive.openBox('user_data');
    _gameBox = await Hive.openBox('game_data');
    _settingsBox = await Hive.openBox('settings');
    
    // 初始化SharedPreferences
    _prefs = await SharedPreferences.getInstance();
  }

  // ===== 用户数据相关 =====
  
  // 保存用户信息
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _userBox.put('user_info', userData);
  }

  // 获取用户信息
  static Map<String, dynamic>? getUserData() {
    final data = _userBox.get('user_info');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  // 保存用户令牌
  static Future<void> saveUserToken(String token) async {
    await _prefs.setString('user_token', token);
  }

  // 获取用户令牌
  static String? getUserToken() {
    return _prefs.getString('user_token');
  }

  // 清除用户数据
  static Future<void> clearUserData() async {
    await _userBox.clear();
    await _prefs.remove('user_token');
  }

  // ===== 游戏数据相关 =====
  
  // 保存游戏统计数据
  static Future<void> saveGameStats(Map<String, dynamic> stats) async {
    await _gameBox.put('game_stats', stats);
  }

  // 获取游戏统计数据
  static Map<String, dynamic> getGameStats() {
    final stats = _gameBox.get('game_stats');
    return stats != null ? Map<String, dynamic>.from(stats) : {
      'totalGames': 0,
      'winGames': 0,
      'loseGames': 0,
      'winRate': 0.0,
      'totalCoins': 1000,
      'bestStreak': 0,
      'currentStreak': 0,
      'level': 1,
      'experience': 0,
    };
  }

  // 更新游戏统计
  static Future<void> updateGameStats({
    bool? isWin,
    int? coinsEarned,
    int? experienceGained,
  }) async {
    final stats = getGameStats();
    
    if (isWin != null) {
      stats['totalGames'] = (stats['totalGames'] ?? 0) + 1;
      if (isWin) {
        stats['winGames'] = (stats['winGames'] ?? 0) + 1;
        stats['currentStreak'] = (stats['currentStreak'] ?? 0) + 1;
        stats['bestStreak'] = stats['currentStreak'] > (stats['bestStreak'] ?? 0) 
            ? stats['currentStreak'] 
            : stats['bestStreak'];
      } else {
        stats['loseGames'] = (stats['loseGames'] ?? 0) + 1;
        stats['currentStreak'] = 0;
      }
      stats['winRate'] = stats['winGames'] / stats['totalGames'];
    }
    
    if (coinsEarned != null) {
      stats['totalCoins'] = (stats['totalCoins'] ?? 0) + coinsEarned;
    }
    
    if (experienceGained != null) {
      stats['experience'] = (stats['experience'] ?? 0) + experienceGained;
      // 检查是否升级
      final currentLevel = stats['level'] ?? 1;
      final newLevel = _calculateLevel(stats['experience']);
      if (newLevel > currentLevel) {
        stats['level'] = newLevel;
      }
    }
    
    await saveGameStats(stats);
  }

  // 计算等级
  static int _calculateLevel(int experience) {
    // 每级需要的经验值递增
    int level = 1;
    int expRequired = 100;
    
    while (experience >= expRequired) {
      experience -= expRequired;
      level++;
      expRequired = (expRequired * 1.2).round();
    }
    
    return level;
  }

  // 保存每日任务进度
  static Future<void> saveDailyTasks(Map<String, dynamic> tasks) async {
    await _gameBox.put('daily_tasks', tasks);
  }

  // 获取每日任务进度
  static Map<String, dynamic> getDailyTasks() {
    final tasks = _gameBox.get('daily_tasks');
    return tasks != null ? Map<String, dynamic>.from(tasks) : {};
  }

  // ===== 设置相关 =====
  
  // 保存游戏设置
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _settingsBox.put('game_settings', settings);
  }

  // 获取游戏设置
  static Map<String, dynamic> getSettings() {
    final settings = _settingsBox.get('game_settings');
    return settings != null ? Map<String, dynamic>.from(settings) : {
      'musicEnabled': true,
      'effectEnabled': true,
      'musicVolume': 0.7,
      'effectVolume': 0.8,
      'language': 'zh_CN',
      'autoPlay': false,
      'showHints': true,
      'vibrationEnabled': true,
    };
  }

  // 更新单个设置
  static Future<void> updateSetting(String key, dynamic value) async {
    final settings = getSettings();
    settings[key] = value;
    await saveSettings(settings);
  }

  // ===== 缓存相关 =====
  
  // 保存缓存数据
  static Future<void> saveCache(String key, dynamic data) async {
    await _gameBox.put('cache_$key', data);
  }

  // 获取缓存数据
  static T? getCache<T>(String key) {
    return _gameBox.get('cache_$key') as T?;
  }

  // 清除缓存
  static Future<void> clearCache() async {
    final keys = _gameBox.keys.where((key) => key.toString().startsWith('cache_'));
    for (String key in keys) {
      await _gameBox.delete(key);
    }
  }

  // ===== 首次启动检查 =====
  
  static bool isFirstLaunch() {
    return _prefs.getBool('first_launch') ?? true;
  }

  static Future<void> setFirstLaunchCompleted() async {
    await _prefs.setBool('first_launch', false);
  }

  // ===== 清理所有数据 =====
  
  static Future<void> clearAll() async {
    await _userBox.clear();
    await _gameBox.clear();
    await _settingsBox.clear();
    await _prefs.clear();
  }
}