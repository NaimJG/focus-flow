import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

import '../../../pomodoro/presentation/screens/pomodoro_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../todo/presentation/screens/todo_screen.dart';
import '../widgets/statistics_tab_host.dart';

/// The root application shell that hosts the bottom [NavigationBar]
/// and renders the four feature tabs via an [IndexedStack].
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
    final l10n = AppLocalizations.of(context)!;

    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.checklist_outlined),
        selectedIcon: const Icon(Icons.checklist),
        label: l10n.navigationTodo,
      ),
      NavigationDestination(
        icon: const Icon(Icons.timer_outlined),
        selectedIcon: const Icon(Icons.timer),
        label: l10n.navigationPomodoro,
      ),
      NavigationDestination(
        icon: const Icon(Icons.bar_chart_outlined),
        selectedIcon: const Icon(Icons.bar_chart),
        label: l10n.navigationStatistics,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: l10n.navigationSettings,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const TodoScreen(),
          const PomodoroScreen(),
          _hasSelectedStatistics
              ? const StatisticsTabHost()
              : const SizedBox.shrink(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: destinations,
      ),
    );
  }
}
