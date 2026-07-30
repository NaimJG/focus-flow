// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navigationTodo => 'Tareas';

  @override
  String get navigationPomodoro => 'Pomodoro';

  @override
  String get navigationStatistics => 'Estadísticas';

  @override
  String get navigationSettings => 'Configuración';

  @override
  String get sharedCancel => 'Cancelar';

  @override
  String get sharedDelete => 'Eliminar';

  @override
  String get sharedRetry => 'Reintentar';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get todoTitle => 'Tareas';

  @override
  String get todoCreateTask => 'Crear tarea';

  @override
  String get todoDeleteTitle => 'Eliminar tarea';

  @override
  String get todoDeleteMessage =>
      '¿Estás seguro de que deseas eliminar esta tarea? Esta acción no se puede deshacer.';

  @override
  String get todoSearchHint => 'Buscar tareas...';

  @override
  String get todoSearchClear => 'Limpiar búsqueda';

  @override
  String get todoCategoriesTooltip => 'Categorías';

  @override
  String get todoCategoriesSemantics => 'Gestionar categorías';

  @override
  String get todoFilterPending => 'Pendientes';

  @override
  String get todoFilterCompleted => 'Completadas';

  @override
  String get todoFilterHigh => 'Alta';

  @override
  String get todoFilterMedium => 'Media';

  @override
  String get todoFilterLow => 'Baja';

  @override
  String get todoFilterUncategorized => 'Sin categoría';

  @override
  String get todoFilterClearAll => 'Limpiar todo';

  @override
  String get todoSortDate => 'Fecha';

  @override
  String get todoSortPriority => 'Prioridad';

  @override
  String get todoSortAlphabetical => 'A–Z';

  @override
  String get todoEmptyNoTasksHeadline => 'Aún no hay tareas';

  @override
  String get todoEmptyNoTasksMessage => 'Crea tu primera tarea para comenzar';

  @override
  String get todoEmptyNoSearchResultsHeadline => 'Sin resultados';

  @override
  String get todoEmptyNoSearchResultsMessage =>
      'Prueba con un término de búsqueda diferente';

  @override
  String get todoEmptyNoFilterResultsHeadline => 'No hay tareas que coincidan';

  @override
  String get todoEmptyNoFilterResultsMessage =>
      'Ajusta tus filtros para ver más tareas';

  @override
  String get todoEmptyNoCategoryTasksHeadline =>
      'No hay tareas en esta categoría';

  @override
  String get todoEmptyNoCategoryTasksMessage =>
      'Las tareas asignadas a esta categoría aparecerán aquí';

  @override
  String get pomodoroTitle => 'Pomodoro';

  @override
  String get pomodoroModeFocus => 'Enfoque';

  @override
  String get pomodoroModeShortBreak => 'Descanso corto';

  @override
  String get pomodoroModeLongBreak => 'Descanso largo';

  @override
  String get pomodoroStatusReady => 'Listo';

  @override
  String get pomodoroStatusRunning => 'En curso';

  @override
  String get pomodoroStatusPaused => 'Pausado';

  @override
  String get pomodoroControlStart => 'Iniciar';

  @override
  String get pomodoroControlPause => 'Pausar';

  @override
  String get pomodoroControlResume => 'Reanudar';

  @override
  String get pomodoroControlReset => 'Reiniciar';

  @override
  String get pomodoroControlSkip => 'Saltar';

  @override
  String get pomodoroCompletedFocus => 'Sesión de enfoque terminada';

  @override
  String get pomodoroCompletedShortBreak => 'Descanso corto terminado';

  @override
  String get pomodoroCompletedLongBreak => 'Descanso largo terminado';

  @override
  String pomodoroCompletedGeneric(String mode) {
    return '$mode terminado';
  }

  @override
  String get pomodoroNextFocus => 'Enfoque listo';

  @override
  String get pomodoroNextShortBreak => 'Descanso corto listo';

  @override
  String get pomodoroNextLongBreak => 'Descanso largo listo';

  @override
  String get pomodoroSessionNotSaved =>
      'Sesión no guardada — toca para reintentar';

  @override
  String get pomodoroAnnounceReady => 'Temporizador listo';

  @override
  String get pomodoroAnnounceRunning => 'Temporizador en curso';

  @override
  String get pomodoroAnnouncePaused => 'Temporizador pausado';

  @override
  String pomodoroAnnounceCompleted(String mode) {
    return '$mode terminado';
  }
}
