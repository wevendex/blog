import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/services/storage_service.dart';
import '../models/player_model.dart';

// 认证状态
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final PlayerModel? user;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    PlayerModel? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
      user: user ?? this.user,
    );
  }
}

// 认证控制器
class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState()) {
    _checkAuthStatus();
  }

  // 检查认证状态
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final token = StorageService.getUserToken();
      final userData = StorageService.getUserData();
      
      if (token != null && token.isNotEmpty && userData != null) {
        final user = PlayerModel.fromJson(userData);
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: '认证状态检查失败: $e',
      );
    }
  }

  // 登录
  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // 模拟网络请求延迟
      await Future.delayed(const Duration(seconds: 1));
      
      // 这里应该调用真实的API
      // 目前使用模拟数据
      if (_validateCredentials(username, password)) {
        final user = await _createUserFromLogin(username);
        final token = _generateToken();
        
        // 保存用户数据和令牌
        await StorageService.saveUserData(user.toJson());
        await StorageService.saveUserToken(token);
        
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
        
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: '用户名或密码错误',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '登录失败: $e',
      );
      return false;
    }
  }

  // 游客登录
  Future<bool> loginAsGuest() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final guestUser = _createGuestUser();
      final token = _generateToken();
      
      await StorageService.saveUserData(guestUser.toJson());
      await StorageService.saveUserToken(token);
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: guestUser,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '游客登录失败: $e',
      );
      return false;
    }
  }

  // 注册
  Future<bool> register(String username, String password, String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // 检查用户名是否存在
      if (_isUsernameTaken(username)) {
        state = state.copyWith(
          isLoading: false,
          error: '用户名已存在',
        );
        return false;
      }
      
      // 创建新用户
      final user = _createNewUser(username, email);
      final token = _generateToken();
      
      await StorageService.saveUserData(user.toJson());
      await StorageService.saveUserToken(token);
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '注册失败: $e',
      );
      return false;
    }
  }

  // 登出
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await StorageService.clearUserData();
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '登出失败: $e',
      );
    }
  }

  // 更新用户信息
  Future<void> updateUserInfo(PlayerModel updatedUser) async {
    if (state.user != null) {
      await StorageService.saveUserData(updatedUser.toJson());
      state = state.copyWith(user: updatedUser);
    }
  }

  // 刷新用户数据
  Future<void> refreshUserData() async {
    if (state.isAuthenticated && state.user != null) {
      // 从服务器获取最新用户数据
      // 这里使用本地数据模拟
      final userData = StorageService.getUserData();
      if (userData != null) {
        final user = PlayerModel.fromJson(userData);
        state = state.copyWith(user: user);
      }
    }
  }

  // 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  // 私有方法：验证登录凭据
  bool _validateCredentials(String username, String password) {
    // 这里应该调用真实的API验证
    // 目前使用简单的模拟验证
    if (username.isEmpty || password.isEmpty) return false;
    if (password.length < 6) return false;
    
    // 模拟一些测试账户
    const testAccounts = {
      'admin': 'admin123',
      'player1': 'password123',
      'test': 'test123',
    };
    
    return testAccounts[username] == password;
  }

  // 私有方法：检查用户名是否被占用
  bool _isUsernameTaken(String username) {
    // 这里应该调用API检查
    // 模拟一些已存在的用户名
    const existingUsers = ['admin', 'player1', 'test', 'user'];
    return existingUsers.contains(username.toLowerCase());
  }

  // 私有方法：从登录创建用户
  Future<PlayerModel> _createUserFromLogin(String username) async {
    // 获取已保存的游戏统计数据
    final gameStats = StorageService.getGameStats();
    
    return PlayerModel.initial(
      id: const Uuid().v4(),
      nickname: username,
    ).copyWith(
      stats: PlayerStats(
        totalGames: gameStats['totalGames'] ?? 0,
        winGames: gameStats['winGames'] ?? 0,
        loseGames: gameStats['loseGames'] ?? 0,
        winRate: gameStats['winRate']?.toDouble() ?? 0.0,
        bestStreak: gameStats['bestStreak'] ?? 0,
        currentStreak: gameStats['currentStreak'] ?? 0,
        totalCoins: gameStats['totalCoins'] ?? 1000,
      ),
      level: PlayerLevel(
        level: gameStats['level'] ?? 1,
        experience: gameStats['experience'] ?? 0,
        expToNext: _calculateExpToNext(gameStats['level'] ?? 1),
        title: _getTitleForLevel(gameStats['level'] ?? 1),
      ),
    );
  }

  // 私有方法：创建游客用户
  PlayerModel _createGuestUser() {
    final randomId = DateTime.now().millisecondsSinceEpoch.toString();
    return PlayerModel.initial(
      id: 'guest_$randomId',
      nickname: '游客$randomId',
    );
  }

  // 私有方法：创建新注册用户
  PlayerModel _createNewUser(String username, String email) {
    return PlayerModel.initial(
      id: const Uuid().v4(),
      nickname: username,
    );
  }

  // 私有方法：生成认证令牌
  String _generateToken() {
    return 'token_${const Uuid().v4()}';
  }

  // 私有方法：计算到下一级所需经验
  int _calculateExpToNext(int level) {
    return (100 * (level * 1.2)).round();
  }

  // 私有方法：根据等级获取称号
  String _getTitleForLevel(int level) {
    if (level < 10) return '新手';
    if (level < 20) return '初级玩家';
    if (level < 30) return '中级玩家';
    if (level < 50) return '高级玩家';
    if (level < 80) return '专家';
    if (level < 100) return '大师';
    return '传奇';
  }
}

// Provider
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);

// 便捷的Provider用于检查认证状态
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).isAuthenticated;
});

final currentUserProvider = Provider<PlayerModel?>((ref) {
  return ref.watch(authControllerProvider).user;
});