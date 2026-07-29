import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../statistics/presentation/controllers/statistics_controller.dart';
import '../../../statistics/presentation/screens/statistics_screen.dart';
import '../../../statistics/presentation/statistics_controller_factory.dart';
import '../../../todo/presentation/controllers/todo_controller.dart';

/// Hosts the Statistics tab content with lazy [StatisticsController]
/// lifecycle management.
///
/// Defers controller creation until [TodoController] has finished its
/// initial load, ensuring the task-to-category mapping reflects the
/// actual todo state rather than a stale empty snapshot.
class StatisticsTabHost extends StatefulWidget {
  /// Creates a [StatisticsTabHost].
  const StatisticsTabHost({super.key});

  @override
  State<StatisticsTabHost> createState() => _StatisticsTabHostState();
}

class _StatisticsTabHostState extends State<StatisticsTabHost> {
  StatisticsController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  StatisticsController _createController() {
    return createStatisticsController(context);
  }

  @override
  Widget build(BuildContext context) {
    final todoController = context.watch<TodoController>();

    if (_controller == null && todoController.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statistics')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    _controller ??= _createController();

    return ChangeNotifierProvider<StatisticsController>.value(
      value: _controller!,
      child: const StatisticsScreen(),
    );
  }
}
