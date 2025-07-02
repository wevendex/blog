import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/game_room.dart';
import '../game/doudizhu_engine.dart';

class MultiplayerService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GameRoom? _room;
  StreamSubscription<DocumentSnapshot>? _roomSubscription;

  GameRoom? get room => _room;

  Future<void> createRoom(String playerId) async {
    final doc = await _firestore.collection('rooms').add({
      'players': [playerId],
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
    });
    _listenToRoom(doc.id);
  }

  Future<void> joinRoom(String roomId, String playerId) async {
    final doc = _firestore.collection('rooms').doc(roomId);
    await doc.update({
      'players': FieldValue.arrayUnion([playerId]),
    });
    _listenToRoom(roomId);
  }

  void _listenToRoom(String roomId) {
    _roomSubscription?.cancel();
    _roomSubscription = _firestore.collection('rooms').doc(roomId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        _room = GameRoom.fromDoc(snapshot);
        notifyListeners();
      }
    });
  }

  Future<void> updateEngine(DouDiZhuEngine engine) async {
    if (_room == null) return;
    await _firestore.collection('rooms').doc(_room!.id).update({'engine': engine.toMap(), 'status': 'playing'});
  }

  Future<void> sendAction(Map<String, dynamic> action) async {
    if (_room == null) return;
    await _firestore.collection('rooms').doc(_room!.id).collection('actions').add({
      ...action,
      'ts': FieldValue.serverTimestamp(),
    });
  }

  Future<void> disposeRoom() async {
    await _roomSubscription?.cancel();
    _room = null;
    notifyListeners();
  }
}