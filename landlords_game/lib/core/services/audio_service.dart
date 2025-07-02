import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  late AudioPlayer _backgroundMusicPlayer;
  late AudioPlayer _effectPlayer;
  
  bool _isMusicEnabled = true;
  bool _isEffectEnabled = true;
  double _musicVolume = 0.7;
  double _effectVolume = 0.8;

  static Future<void> init() async {
    await AudioService()._initialize();
  }

  Future<void> _initialize() async {
    _backgroundMusicPlayer = AudioPlayer();
    _effectPlayer = AudioPlayer();
    
    // 设置背景音乐循环播放
    _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
    _effectPlayer.setReleaseMode(ReleaseMode.stop);
    
    // 设置音量
    _backgroundMusicPlayer.setVolume(_musicVolume);
    _effectPlayer.setVolume(_effectVolume);
  }

  // 播放背景音乐
  Future<void> playBackgroundMusic(String assetPath) async {
    if (!_isMusicEnabled) return;
    
    try {
      await _backgroundMusicPlayer.play(AssetSource(assetPath));
    } catch (e) {
      if (kDebugMode) {
        print('播放背景音乐失败: $e');
      }
    }
  }

  // 停止背景音乐
  Future<void> stopBackgroundMusic() async {
    await _backgroundMusicPlayer.stop();
  }

  // 暂停背景音乐
  Future<void> pauseBackgroundMusic() async {
    await _backgroundMusicPlayer.pause();
  }

  // 恢复背景音乐
  Future<void> resumeBackgroundMusic() async {
    await _backgroundMusicPlayer.resume();
  }

  // 播放音效
  Future<void> playEffect(String assetPath) async {
    if (!_isEffectEnabled) return;
    
    try {
      await _effectPlayer.play(AssetSource(assetPath));
    } catch (e) {
      if (kDebugMode) {
        print('播放音效失败: $e');
      }
    }
  }

  // 游戏音效枚举
  static const String cardFlipSound = 'audio/effects/card_flip.mp3';
  static const String cardPlaySound = 'audio/effects/card_play.mp3';
  static const String buttonClickSound = 'audio/effects/button_click.mp3';
  static const String coinSound = 'audio/effects/coin.mp3';
  static const String winSound = 'audio/effects/win.mp3';
  static const String loseSound = 'audio/effects/lose.mp3';
  static const String bombSound = 'audio/effects/bomb.mp3';
  static const String dealCardsSound = 'audio/effects/deal_cards.mp3';
  static const String passSound = 'audio/effects/pass.mp3';
  static const String callLandlordSound = 'audio/effects/call_landlord.mp3';
  
  // 背景音乐
  static const String mainMenuMusic = 'audio/music/main_menu.mp3';
  static const String gamePlayMusic = 'audio/music/game_play.mp3';

  // 快捷音效播放方法
  Future<void> playCardFlip() => playEffect(cardFlipSound);
  Future<void> playCardPlay() => playEffect(cardPlaySound);
  Future<void> playButtonClick() => playEffect(buttonClickSound);
  Future<void> playCoin() => playEffect(coinSound);
  Future<void> playWin() => playEffect(winSound);
  Future<void> playLose() => playEffect(loseSound);
  Future<void> playBomb() => playEffect(bombSound);
  Future<void> playDealCards() => playEffect(dealCardsSound);
  Future<void> playPass() => playEffect(passSound);
  Future<void> playCallLandlord() => playEffect(callLandlordSound);

  // 设置音乐开关
  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled) {
      stopBackgroundMusic();
    }
  }

  // 设置音效开关
  void setEffectEnabled(bool enabled) {
    _isEffectEnabled = enabled;
  }

  // 设置音乐音量
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _backgroundMusicPlayer.setVolume(_musicVolume);
  }

  // 设置音效音量
  void setEffectVolume(double volume) {
    _effectVolume = volume.clamp(0.0, 1.0);
    _effectPlayer.setVolume(_effectVolume);
  }

  // 获取设置
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isEffectEnabled => _isEffectEnabled;
  double get musicVolume => _musicVolume;
  double get effectVolume => _effectVolume;

  // 释放资源
  Future<void> dispose() async {
    await _backgroundMusicPlayer.dispose();
    await _effectPlayer.dispose();
  }
}