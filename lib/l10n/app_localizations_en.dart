// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navigationTodo => 'Todo';

  @override
  String get navigationPomodoro => 'Pomodoro';

  @override
  String get navigationStatistics => 'Statistics';

  @override
  String get navigationSettings => 'Settings';

  @override
  String get sharedCancel => 'Cancel';

  @override
  String get sharedDelete => 'Delete';

  @override
  String get sharedRetry => 'Retry';
}
