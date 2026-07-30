import '../../../../l10n/app_localizations.dart';

/// Formats a duration given in [totalSeconds] into a localized
/// human-readable string.
///
/// - 0 seconds → `"0 min"`
/// - 1–3599 seconds → `"{minutes} min"` (e.g., `"45 min"`)
/// - 3600+ seconds → `"{hours} h {minutes} min"` (e.g., `"2 h 15 min"`)
String formatDuration(int totalSeconds, AppLocalizations l10n) {
  if (totalSeconds < 3600) {
    final minutes = totalSeconds ~/ 60;
    return l10n.durationMinutes(minutes);
  }

  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  return l10n.durationHoursMinutes(hours, minutes);
}
