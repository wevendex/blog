import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/storage_service.dart';
import '../models/player_model.dart';

// 用户状态
class UserState {
  final bool isLoading;
  final String? error;
  final PlayerModel? user;

  const UserState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  UserState copyWith({
    bool? isLoading,
    String? error,
    PlayerModel? user,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

// 用户控制器
class UserController extends StateNotifier<UserState> {
  UserController() : super(const UserState());

  // 加载用户数据
  Future<void> loadUserData() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final userData = StorageService.getUserData();
      if (userData != null) {
        final user = PlayerModel.fromJson(userData);
        state = state.copyWith(
          isLoading: false,
          user: user,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: '用户数据不存在',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载用户数据失败: $e',
      );
    }
  }

  // 更新用户统计数据
  Future<void> updateGameStats({
    bool? isWin,
    int? coinsEarned,
    int? experienceGained,
  }) async {
    if (state.user == null) return;

    try {
      // 更新本地存储的统计数据
      await StorageService.updateGameStats(
        isWin: isWin,
        coinsEarned: coinsEarned,
        experienceGained: experienceGained,
      );

      // 重新加载用户数据以反映更新
      await loadUserData();
    } catch (e) {
      state = state.copyWith(error: '更新统计数据失败: $e');
    }
  }

  // 更新用户信息
  Future<void> updateUserInfo({
    String? nickname,
    String? avatar,
  }) async {
    if (state.user == null) return;

    try {
      final updatedUser = state.user!.copyWith(
        nickname: nickname,
        avatar: avatar,
        lastActiveTime: DateTime.now(),
      );

      await StorageService.saveUserData(updatedUser.toJson());
      
      state = state.copyWith(user: updatedUser);
    } catch (e) {
      state = state.copyWith(error: '更新用户信息失败: $e');
    }
  }

  // 获取金币
  Future<void> addCoins(int amount) async {
    if (state.user == null) return;

    try {
      await updateGameStats(coinsEarned: amount);
    } catch (e) {
      state = state.copyWith(error: '添加金币失败: $e');
    }
  }

  // 消费金币
  Future<bool> spendCoins(int amount) async {
    if (state.user == null) return false;

    final currentCoins = state.user!.stats.totalCoins;
    if (currentCoins < amount) {
      state = state.copyWith(error: '金币不足');
      return false;
    }

    try {
      await updateGameStats(coinsEarned: -amount);
      return true;
    } catch (e) {
      state = state.copyWith(error: '消费金币失败: $e');
      return false;
    }
  }

  // 获取经验值
  Future<void> addExperience(int amount) async {
    try {
      await updateGameStats(experienceGained: amount);
    } catch (e) {
      state = state.copyWith(error: '添加经验失败: $e');
    }
  }

  // 升级检查
  bool checkLevelUp(int oldLevel, int newLevel) {
    return newLevel > oldLevel;
  }

  // 获取下一级所需经验
  int getExpToNextLevel(int currentLevel, int currentExp) {
    final expRequired = (100 * (currentLevel * 1.2)).round();
    return expRequired - (currentExp % expRequired);
  }

  // 计算当前等级进度百分比
  double getLevelProgress(int currentLevel, int currentExp) {
    final expRequired = (100 * (currentLevel * 1.2)).round();
    final expInCurrentLevel = currentExp % expRequired;
    return expInCurrentLevel / expRequired;
  }

  // 获取玩家称号
  String getPlayerTitle(int level) {
    if (level < 10) return '新手';
    if (level < 20) return '初级玩家';
    if (level < 30) return '中级玩家';
    if (level < 50) return '高级玩家';
    if (level < 80) return '专家';
    if (level < 100) return '大师';
    return '传奇';
  }

  // 获取等级颜色
  String getLevelColor(int level) {
    if (level < 10) return '#4CAF50';    // 绿色
    if (level < 20) return '#2196F3';    // 蓝色
    if (level < 30) return '#9C27B0';    // 紫色
    if (level < 50) return '#FF9800';    // 橙色
    if (level < 80) return '#F44336';    // 红色
    if (level < 100) return '#FFD700';   // 金色
    return '#E91E63';                    // 传奇粉
  }

  // 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final userControllerProvider = StateNotifierProvider<UserController, UserState>(
  (ref) => UserController(),
);

// 每日任务状态和控制器
class DailyTasksState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> tasks;
  final bool hasClaimedDaily;

  const DailyTasksState({
    this.isLoading = false,
    this.error,
    this.tasks = const {},
    this.hasClaimedDaily = false,
  });

  DailyTasksState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? tasks,
    bool? hasClaimedDaily,
  }) {
    return DailyTasksState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      tasks: tasks ?? this.tasks,
      hasClaimedDaily: hasClaimedDaily ?? this.hasClaimedDaily,
    );
  }
}

class DailyTasksController extends StateNotifier<DailyTasksState> {
  DailyTasksController() : super(const DailyTasksState()) {
    loadDailyTasks();
  }

  // 加载每日任务
  Future<void> loadDailyTasks() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final tasks = StorageService.getDailyTasks();
      final today = DateTime.now().toString().split(' ')[0];
      final hasClaimedDaily = tasks['dailyClaimed_$today'] == true;
      
      // 初始化默认任务
      final defaultTasks = _getDefaultTasks();
      final mergedTasks = {...defaultTasks, ...tasks};
      
      state = state.copyWith(
        isLoading: false,
        tasks: mergedTasks,
        hasClaimedDaily: hasClaimedDaily,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载每日任务失败: $e',
      );
    }
  }

  // 完成任务
  Future<void> completeTask(String taskId) async {
    try {
      final updatedTasks = Map<String, dynamic>.from(state.tasks);
      updatedTasks[taskId] = true;
      
      await StorageService.saveDailyTasks(updatedTasks);
      
      state = state.copyWith(tasks: updatedTasks);
    } catch (e) {
      state = state.copyWith(error: '完成任务失败: $e');
    }
  }

  // 领取每日奖励
  Future<void> claimDailyReward() async {
    if (state.hasClaimedDaily) return;
    
    try {
      final today = DateTime.now().toString().split(' ')[0];
      final updatedTasks = Map<String, dynamic>.from(state.tasks);
      updatedTasks['dailyClaimed_$today'] = true;
      
      await StorageService.saveDailyTasks(updatedTasks);
      
      // 给用户添加奖励
      await StorageService.updateGameStats(coinsEarned: 100);
      
      state = state.copyWith(
        tasks: updatedTasks,
        hasClaimedDaily: true,
      );
    } catch (e) {
      state = state.copyWith(error: '领取奖励失败: $e');
    }
  }

  // 获取默认任务配置
  Map<String, dynamic> _getDefaultTasks() {
    return {
      'playGame': false,        // 完成一局游戏
      'winGame': false,         // 获得一次胜利
      'playThreeGames': false,  // 完成三局游戏
      'winThreeGames': false,   // 获得三次胜利
      'spendCoins': false,      // 消费金币
    };
  }

  // 获取任务进度
  int getTaskProgress() {
    const totalTasks = 5;
    final completedTasks = state.tasks.values
        .where((value) => value == true && !value.toString().contains('dailyClaimed'))
        .length;
    return completedTasks;
  }

  // 获取任务完成百分比
  double getTaskProgressPercentage() {
    // const totalTasks = 5; // 使用固定数字5替代
    final completedTasks = getTaskProgress();
    return completedTasks / 5;
  }

  // 检查所有任务是否完成
  bool get allTasksCompleted => getTaskProgress() >= 5;

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final dailyTasksControllerProvider = StateNotifierProvider<DailyTasksController, DailyTasksState>(
  (ref) => DailyTasksController(),
);