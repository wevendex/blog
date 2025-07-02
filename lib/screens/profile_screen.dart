import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ps = Provider.of<ProfileService>(context);
    final p = ps.me;
    return Scaffold(
      appBar: AppBar(title: const Text('个人档案')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(radius: 40, child: Text(p.nickname.characters.first)),
          const SizedBox(height: 10),
          Text(p.nickname, style: const TextStyle(fontSize: 18)),
          const Divider(),
          ListTile(title: const Text('胜场'), trailing: Text(p.wins.toString())),
          ListTile(title: const Text('败场'), trailing: Text(p.losses.toString())),
          ListTile(title: const Text('星级'), trailing: Text(p.stars.toString())),
        ],
      ),
    );
  }
}