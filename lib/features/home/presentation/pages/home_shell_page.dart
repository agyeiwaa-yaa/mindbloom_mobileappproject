import 'package:flutter/material.dart';

import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../habits/presentation/pages/habits_page.dart';
import '../../../journal/presentation/pages/journal_page.dart';
import '../../../mood/presentation/pages/mood_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _index = 0;

  final _pages = const [
    DashboardPage(),
    MoodPage(),
    JournalPage(),
    HabitsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF5FA),
            Color(0xFFFCE4EE),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: IndexedStack(
            index: _index,
            children: _pages,
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.favorite_outline), label: 'Mood'),
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Journal'),
            NavigationDestination(icon: Icon(Icons.task_alt_outlined), label: 'Habits'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
          ],
          onDestinationSelected: (index) => setState(() => _index = index),
        ),
      ),
    );
  }
}
