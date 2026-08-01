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
  String get settingsTitle => 'Configuración';

  @override
  String get settingsSectionPomodoro => 'Pomodoro';

  @override
  String get settingsSectionAppearance => 'Apariencia';

  @override
  String get settingsSectionSound => 'Sonido';

  @override
  String get settingsThemeModeSystem => 'Sistema';

  @override
  String get settingsThemeModeLight => 'Claro';

  @override
  String get settingsThemeModeDark => 'Oscuro';

  @override
  String get settingsPaletteSalmon => 'Salmón';

  @override
  String get settingsPaletteLightBlue => 'Azul claro';

  @override
  String get settingsPaletteLightGreen => 'Verde claro';

  @override
  String get settingsColorPalette => 'Paleta de colores';

  @override
  String get settingsSoundEnabled => 'Activado';

  @override
  String get settingsSoundDisabled => 'Desactivado';

  @override
  String get settingsDurationUnit => 'min';

  @override
  String get settingsFocusDuration => 'Duración de enfoque';

  @override
  String get settingsShortBreak => 'Descanso corto';

  @override
  String get settingsLongBreak => 'Descanso largo';

  @override
  String get settingsCyclesBeforeLongBreak => 'Ciclos antes de descanso largo';

  @override
  String get settingsCyclesUnit => 'ciclos';

  @override
  String settingsSaveError(String settingName) {
    return 'No se pudo guardar $settingName. Intente de nuevo.';
  }

  @override
  String get settingsLoadError =>
      'No se pudo cargar la configuración. Intente de nuevo.';

  @override
  String settingsValidationRange(int min, int max) {
    return 'Debe ser entre $min y $max';
  }

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
  String get pomodoroNoTask => 'Sin tarea';

  @override
  String get pomodoroTaskLabel => 'Tarea';

  @override
  String get pomodoroNoTasksAvailable => 'No hay tareas disponibles';

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

  @override
  String get statisticsTitle => 'Estadísticas';

  @override
  String get statisticsPeriodToday => 'Hoy';

  @override
  String get statisticsPeriodWeek => 'Esta semana';

  @override
  String get statisticsPeriodMonth => 'Este mes';

  @override
  String get statisticsTotalTime => 'Tiempo total';

  @override
  String get statisticsSessions => 'Sesiones';

  @override
  String get statisticsAverage => 'Promedio';

  @override
  String get statisticsByTask => 'Por tarea';

  @override
  String get statisticsByCategory => 'Por categoría';

  @override
  String get statisticsUncategorized => 'Sin categoría';

  @override
  String get statisticsEmptyTitle => 'Aún no hay sesiones de enfoque';

  @override
  String get statisticsEmptyMessage =>
      'Completa una sesión de enfoque en el temporizador Pomodoro para ver tus estadísticas de productividad aquí.';

  @override
  String get statisticsRetry => 'Reintentar';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get categoryDeleteTitle => 'Eliminar categoría';

  @override
  String categoryDeleteMessage(String categoryName) {
    return '¿Estás seguro de que deseas eliminar \"$categoryName\"? Sus tareas no se eliminarán. Quedarán sin categoría.';
  }

  @override
  String get errorNotFoundTitle => 'No encontrado';

  @override
  String get errorNotFoundMessage => 'Página no encontrada';

  @override
  String pomodoroCycleSemantics(int completed, int total) {
    return '$completed de $total sesiones de enfoque completadas';
  }

  @override
  String pomodoroCycleSessionCompleted(int index) {
    return 'Sesión $index completada';
  }

  @override
  String pomodoroCycleSessionIncomplete(int index) {
    return 'Sesión $index incompleta';
  }

  @override
  String pomodoroCycleSessionInProgress(int current, int total, int percent) {
    return 'Sesión $current de $total, $percent% completada';
  }

  @override
  String pomodoroTimerSemantics(int minutes, int seconds) {
    return '$minutes minutos $seconds segundos restantes';
  }

  @override
  String get todoSortAscendingSemantics =>
      'Orden ascendente, toca para ordenar descendente';

  @override
  String get todoSortDescendingSemantics =>
      'Orden descendente, toca para ordenar ascendente';

  @override
  String get todoSortAscendingTooltip => 'Ordenar descendente';

  @override
  String get todoSortDescendingTooltip => 'Ordenar ascendente';

  @override
  String get todoDeleteTaskSemantics => 'Eliminar tarea';

  @override
  String get todoFormNewTitle => 'Nueva tarea';

  @override
  String get todoFormEditTitle => 'Editar tarea';

  @override
  String get todoFormTitleLabel => 'Título';

  @override
  String get todoFormTitleHint => 'Ingrese un título de tarea';

  @override
  String get todoFormTitleRequired => 'El título es obligatorio';

  @override
  String get todoFormDescriptionLabel => 'Descripción';

  @override
  String get todoFormDescriptionHint => 'Agregue una descripción opcional';

  @override
  String get todoFormPriorityLabel => 'Prioridad';

  @override
  String get todoFormCategoryLabel => 'Categoría';

  @override
  String get todoFormNoCategory => 'Sin categoría';

  @override
  String get todoFormSaveChanges => 'Guardar cambios';

  @override
  String get todoFormGenericError => 'Algo salió mal. Intente de nuevo.';

  @override
  String get todoPriorityHigh => 'Alta';

  @override
  String get todoPriorityMedium => 'Media';

  @override
  String get todoPriorityLow => 'Baja';

  @override
  String get todoCategorySaveSemantics => 'Guardar categoría';

  @override
  String get todoCategoryCancelSemantics => 'Cancelar creación de categoría';

  @override
  String todoCategoryRenameSemantics(String name) {
    return 'Renombrar $name';
  }

  @override
  String todoCategoryDeleteSemantics(String name) {
    return 'Eliminar $name';
  }

  @override
  String get todoCreateTaskFab => 'Crear tarea';

  @override
  String get todoCreateCategoryFab => 'Crear categoría';

  @override
  String get todoFabCloseMenu => 'Cerrar menú';

  @override
  String get todoFabCreate => 'Crear';

  @override
  String get todoCategoriesTitle => 'Categorías';

  @override
  String get todoCategoryNewName => 'Nombre de la nueva categoría';

  @override
  String get todoCategoryEmptyState => 'Aún no hay categorías';

  @override
  String get todoCategoryRenameTitle => 'Renombrar categoría';

  @override
  String get todoCategoryNameLabel => 'Nombre de la categoría';

  @override
  String get todoCategoryRename => 'Renombrar';

  @override
  String get todoCategoryAdd => 'Agregar categoría';

  @override
  String get todoCategoryNameRequired =>
      'El nombre de la categoría es obligatorio';
}
