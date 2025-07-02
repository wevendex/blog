import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/multiplayer_service.dart';
import '../services/error_service.dart';
import 'game_screen.dart';

class RoomScreen extends StatelessWidget {
  static const routeName = '/room';
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<MultiplayerService>(context);
    final room = mp.room;
    if (room == null) {
      return const Scaffold(body: Center(child: Text('房间已关闭')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('房间'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            await mp.leaveRoom();
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder(
        stream: mp.roomStream,
        builder: (context, snapshot) {
          final current = snapshot.data ?? room;
          if (current.players.length == 3 && current.status != 'playing') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, GameScreen.routeName);
            });
          }
          return Column(
            children: [
              const SizedBox(height: 10),
              Text('房间ID: ${current.id}'),
              const Divider(),
              ...current.players
                  .map((p) => ListTile(leading: const Icon(Icons.person), title: Text(p)))
                  .toList(),
              const Spacer(),
              const Text('聊天功能待实现'),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}