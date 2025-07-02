import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';

class LeaderboardScreen extends StatelessWidget {
  static const routeName = '/leaderboard';
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ps = Provider.of<ProfileService>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('排行榜')),
      body: ListView.builder(
        itemCount: ps.leaderboard.length,
        itemBuilder: (context, index) {
          final p = ps.leaderboard[index];
          return ListTile(
            leading: CircleAvatar(child: Text(p.nickname.characters.first)),
            title: Text(p.nickname),
            trailing: Text('⭐️ ${p.stars}'),
          );
        },
      ),
    );
  }
}