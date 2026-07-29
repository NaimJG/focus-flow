import 'package:flutter_test/flutter_test.dart';

import 'package:focus_flow/features/settings/domain/entities/app_color_palette.dart';
import 'package:focus_flow/features/settings/domain/entities/app_settings.dart';
import 'package:focus_flow/features/settings/domain/entities/app_theme_mode.dart';

void main() {
  group('AppSettings', () {
    test('default constructor produces expected defaults', () {
      const settings = AppSettings();

      expect(settings.focusDuration, const Duration(minutes: 25));
      expect(
        settings.shortBreakDuration,
        const Duration(minutes: 5),
      );
      expect(
        settings.longBreakDuration,
        const Duration(minutes: 15),
      );
      expect(settings.cyclesBeforeLongBreak, 4);
      expect(settings.soundEnabled, isTrue);
      expect(settings.themeMode, AppThemeMode.system);
      expect(settings.colorPalette, AppColorPalette.salmon);
    });

    group('copyWith', () {
      test('returns identical instance when no arguments given', () {
        const original = AppSettings();
        final copy = original.copyWith();

        expect(copy, equals(original));
      });

      test('overrides only the specified fields', () {
        const original = AppSettings();
        final modified = original.copyWith(
          focusDuration: const Duration(minutes: 50),
          soundEnabled: false,
          themeMode: AppThemeMode.dark,
        );

        expect(modified.focusDuration, const Duration(minutes: 50));
        expect(modified.soundEnabled, isFalse);
        expect(modified.themeMode, AppThemeMode.dark);
        // Unchanged fields retain defaults.
        expect(
          modified.shortBreakDuration,
          const Duration(minutes: 5),
        );
        expect(
          modified.longBreakDuration,
          const Duration(minutes: 15),
        );
        expect(modified.cyclesBeforeLongBreak, 4);
        expect(modified.colorPalette, AppColorPalette.salmon);
      });
    });

    group('equality', () {
      test('two instances with same values are equal', () {
        const a = AppSettings();
        const b = AppSettings();

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('instances with different values are not equal', () {
        const a = AppSettings();
        final b = a.copyWith(
          colorPalette: AppColorPalette.lightBlue,
        );

        expect(a, isNot(equals(b)));
      });

      test('identical reference is equal', () {
        const a = AppSettings();
        expect(a == a, isTrue);
      });
    });
  });
}
