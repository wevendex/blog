import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/multiplayer_service.dart';
import '../services/error_service.dart';

class LobbyScreen extends StatefulWidget {
  static const routeName = '/lobby';
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  @override
  void initState() {
    super.initState();
    // Optionally load initial rooms list here.
  }

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<MultiplayerService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('游戏大厅'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          try {
            await mp.createRoom('local');
          } catch (e) {
            ErrorService().showError('快速匹配失败');
          }
        },
        icon: const Icon(Icons.flash_on),
        label: const Text('快速开始'),
      ),
      body: StreamBuilder(
        stream: mp.roomsStream ?? const Stream.empty(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final rooms = snapshot.data ?? [];
          if (rooms.isEmpty) {
            return const Center(child: Text('暂无房间，点击右下角快速开始'));
          }
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return ListTile(
                leading: const Icon(Icons.meeting_room),
                title: Text('房间 ${room.id}'),
                subtitle: Text('${room.players.length}/3'),
                onTap: () async {
                  await mp.joinRoom(room.id, 'local');
                },
              );
            },
          );
        },
      ),
    );
  }
}