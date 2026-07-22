import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

/// The root widget of the Focus Flow application.
class FocusFlowApp extends StatelessWidget {
  /// Creates a [FocusFlowApp] with the given [Isar] instance.
  const FocusFlowApp({super.key, required this.isar});

  /// The Isar database instance used throughout the application.
  final Isar isar;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Focus Flow',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
