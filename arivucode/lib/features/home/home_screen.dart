import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ArivuCode")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            title: const Text("⚔️ Challenges"),
            onTap: () {},
          ),
          ListTile(
            title: const Text("💻 Code Editor"),
            onTap: () {},
          ),
          ListTile(
            title: const Text("🔥 Streaks & Rewards"),
            onTap: () {},
          ),
          ListTile(
            title: const Text("👤 Profile"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
