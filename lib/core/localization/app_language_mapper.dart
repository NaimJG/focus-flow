import 'dart:ui';

import '../../features/settings/domain/entities/app_language.dart';

/// Maps [AppLanguage] domain enum to Flutter [Locale].
abstract final class AppLanguageMapper {
  static Locale toLocale(AppLanguage language) => switch (language) {
    AppLanguage.spanish => const Locale('es'),
    AppLanguage.english => const Locale('en'),
  };
}
