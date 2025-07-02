import 'package:cloud_firestore/cloud_firestore.dart';

class GameRoom {
  final String id;
  final List<String> players;
  final Map<String, dynamic>? engineState;
  final String status; // waiting, playing, finished

  GameRoom({required this.id, required this.players, required this.status, this.engineState});

  factory GameRoom.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameRoom(
      id: doc.id,
      players: List<String>.from(data['players'] ?? []),
      status: data['status'] ?? 'waiting',
      engineState: data['engine'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() => {
        'players': players,
        'status': status,
        'engine': engineState,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}