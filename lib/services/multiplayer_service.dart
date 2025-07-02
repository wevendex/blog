import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MultiplayerService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _roomId;
  StreamSubscription<QuerySnapshot>? _roomSubscription;

  String? get roomId => _roomId;

  Future<void> createRoom() async {
    final doc = await _firestore.collection('rooms').add({
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'waiting',
    });
    _roomId = doc.id;
    notifyListeners();
  }

  Future<void> joinRoom(String id) async {
    _roomId = id;
    _listenToRoom();
    notifyListeners();
  }

  void _listenToRoom() {
    if (_roomId == null) return;
    _roomSubscription = _firestore.collection('rooms').doc(_roomId).snapshots().listen((snapshot) {
      // TODO: parse game state
      notifyListeners();
    });
  }

  Future<void> disposeRoom() async {
    await _roomSubscription?.cancel();
    _roomId = null;
    notifyListeners();
  }
}