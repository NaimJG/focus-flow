import 'package:flutter/material.dart';

import '../../../pomodoro/presentation/screens/pomodoro_screen.dart';
import '../../../todo/presentation/screens/todo_screen.dart';
import '../widgets/statistics_tab_host.dart';

/// The root application shell that hosts the bottom [NavigationBar]
/// and renders the three feature tabs via an [IndexedStack].
///
/// Uses [IndexedStack] to preserve widget state across tab switches.
/// The Statistics tab is lazily loaded — its host widget is only
/// instantiated after the user navigates to it for the first time.
class HomeScreen extends StatefulWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _hasSelectedStatistics = false;

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.checklist_outlined),
      selectedIcon: Icon(Icons.checklist),
      label: 'Todo',
    ),
    NavigationDestination(
      icon: Icon(Icons.timer_outlined),
      selectedIcon: Icon(Icons.timer),
      label: 'Pomodoro',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart),
      label: 'Statistics',
    ),
  ];

  void _onDestinationSelected(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
      if (index == 2 && !_hasSelectedStatistics) {
        _hasSelectedStatistics = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const TodoScreen(),
          const PomodoroScreen(),
          _hasSelectedStatistics
              ? const StatisticsTabHost()
              : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: _destinations,
      ),
    );
  }
}
