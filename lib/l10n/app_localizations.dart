import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Navigation bar label for the Todo tab
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get navigationTodo;

  /// Navigation bar label for the Pomodoro tab
  ///
  /// In es, this message translates to:
  /// **'Pomodoro'**
  String get navigationPomodoro;

  /// Navigation bar label for the Statistics tab
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get navigationStatistics;

  /// Navigation bar label for the Settings tab
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get navigationSettings;

  /// Shared label for cancel actions in dialogs and buttons
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get sharedCancel;

  /// Shared label for delete actions in dialogs and buttons
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get sharedDelete;

  /// Shared label for retry actions after errors
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get sharedRetry;

  /// Section header for language settings in the Settings screen
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// AppBar title for the Settings screen
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTitle;

  /// Section header for Pomodoro settings
  ///
  /// In es, this message translates to:
  /// **'Pomodoro'**
  String get settingsSectionPomodoro;

  /// Section header for Appearance settings
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get settingsSectionAppearance;

  /// Section header for Sound settings
  ///
  /// In es, this message translates to:
  /// **'Sonido'**
  String get settingsSectionSound;

  /// Theme mode label for system default
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get settingsThemeModeSystem;

  /// Theme mode label for light mode
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get settingsThemeModeLight;

  /// Theme mode label for dark mode
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get settingsThemeModeDark;

  /// Color palette name for Salmon
  ///
  /// In es, this message translates to:
  /// **'Salmón'**
  String get settingsPaletteSalmon;

  /// Color palette name for Light Blue
  ///
  /// In es, this message translates to:
  /// **'Azul claro'**
  String get settingsPaletteLightBlue;

  /// Color palette name for Light Green
  ///
  /// In es, this message translates to:
  /// **'Verde claro'**
  String get settingsPaletteLightGreen;

  /// Sub-label for the color palette picker section
  ///
  /// In es, this message translates to:
  /// **'Paleta de colores'**
  String get settingsColorPalette;

  /// Sound state label when enabled
  ///
  /// In es, this message translates to:
  /// **'Activado'**
  String get settingsSoundEnabled;

  /// Sound state label when disabled
  ///
  /// In es, this message translates to:
  /// **'Desactivado'**
  String get settingsSoundDisabled;

  /// Duration unit abbreviation for minutes in settings inputs
  ///
  /// In es, this message translates to:
  /// **'min'**
  String get settingsDurationUnit;

  /// Label for the focus duration setting field
  ///
  /// In es, this message translates to:
  /// **'Duración de enfoque'**
  String get settingsFocusDuration;

  /// Label for the short break duration setting field
  ///
  /// In es, this message translates to:
  /// **'Descanso corto'**
  String get settingsShortBreak;

  /// Label for the long break duration setting field
  ///
  /// In es, this message translates to:
  /// **'Descanso largo'**
  String get settingsLongBreak;

  /// Label for cycles before long break setting field
  ///
  /// In es, this message translates to:
  /// **'Ciclos antes de descanso largo'**
  String get settingsCyclesBeforeLongBreak;

  /// Unit suffix for cycles setting input
  ///
  /// In es, this message translates to:
  /// **'ciclos'**
  String get settingsCyclesUnit;

  /// Error message template when a setting fails to save
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar {settingName}. Intente de nuevo.'**
  String settingsSaveError(String settingName);

  /// Fallback error message when settings fail to load
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la configuración. Intente de nuevo.'**
  String get settingsLoadError;

  /// Validation error message for out-of-range numeric input
  ///
  /// In es, this message translates to:
  /// **'Debe ser entre {min} y {max}'**
  String settingsValidationRange(int min, int max);

  /// AppBar title for the Todo screen
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get todoTitle;

  /// Label for the create task button in the empty state
  ///
  /// In es, this message translates to:
  /// **'Crear tarea'**
  String get todoCreateTask;

  /// Title of the delete task confirmation dialog
  ///
  /// In es, this message translates to:
  /// **'Eliminar tarea'**
  String get todoDeleteTitle;

  /// Body message of the delete task confirmation dialog
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar esta tarea? Esta acción no se puede deshacer.'**
  String get todoDeleteMessage;

  /// Hint text for the task search input field
  ///
  /// In es, this message translates to:
  /// **'Buscar tareas...'**
  String get todoSearchHint;

  /// Semantics label and tooltip for the clear search button
  ///
  /// In es, this message translates to:
  /// **'Limpiar búsqueda'**
  String get todoSearchClear;

  /// Tooltip for the categories icon button in the AppBar
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get todoCategoriesTooltip;

  /// Semantics label for the categories icon button
  ///
  /// In es, this message translates to:
  /// **'Gestionar categorías'**
  String get todoCategoriesSemantics;

  /// Filter chip label for pending tasks
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get todoFilterPending;

  /// Filter chip label for completed tasks
  ///
  /// In es, this message translates to:
  /// **'Completadas'**
  String get todoFilterCompleted;

  /// Filter chip label for high priority
  ///
  /// In es, this message translates to:
  /// **'Alta'**
  String get todoFilterHigh;

  /// Filter chip label for medium priority
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get todoFilterMedium;

  /// Filter chip label for low priority
  ///
  /// In es, this message translates to:
  /// **'Baja'**
  String get todoFilterLow;

  /// Filter chip label for tasks without a category
  ///
  /// In es, this message translates to:
  /// **'Sin categoría'**
  String get todoFilterUncategorized;

  /// Action chip label to clear all active filters
  ///
  /// In es, this message translates to:
  /// **'Limpiar todo'**
  String get todoFilterClearAll;

  /// Sort criterion label for creation date
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get todoSortDate;

  /// Sort criterion label for priority
  ///
  /// In es, this message translates to:
  /// **'Prioridad'**
  String get todoSortPriority;

  /// Sort criterion label for alphabetical order
  ///
  /// In es, this message translates to:
  /// **'A–Z'**
  String get todoSortAlphabetical;

  /// Headline for the empty state when no tasks exist
  ///
  /// In es, this message translates to:
  /// **'Aún no hay tareas'**
  String get todoEmptyNoTasksHeadline;

  /// Supporting message for the empty state when no tasks exist
  ///
  /// In es, this message translates to:
  /// **'Crea tu primera tarea para comenzar'**
  String get todoEmptyNoTasksMessage;

  /// Headline for the empty state when search yields no results
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get todoEmptyNoSearchResultsHeadline;

  /// Supporting message for the empty state when search yields no results
  ///
  /// In es, this message translates to:
  /// **'Prueba con un término de búsqueda diferente'**
  String get todoEmptyNoSearchResultsMessage;

  /// Headline for the empty state when filters yield no results
  ///
  /// In es, this message translates to:
  /// **'No hay tareas que coincidan'**
  String get todoEmptyNoFilterResultsHeadline;

  /// Supporting message for the empty state when filters yield no results
  ///
  /// In es, this message translates to:
  /// **'Ajusta tus filtros para ver más tareas'**
  String get todoEmptyNoFilterResultsMessage;

  /// Headline for the empty state when a category has no tasks
  ///
  /// In es, this message translates to:
  /// **'No hay tareas en esta categoría'**
  String get todoEmptyNoCategoryTasksHeadline;

  /// Supporting message for the empty state when a category has no tasks
  ///
  /// In es, this message translates to:
  /// **'Las tareas asignadas a esta categoría aparecerán aquí'**
  String get todoEmptyNoCategoryTasksMessage;

  /// AppBar title for the Pomodoro screen
  ///
  /// In es, this message translates to:
  /// **'Pomodoro'**
  String get pomodoroTitle;

  /// Label for focus timer mode
  ///
  /// In es, this message translates to:
  /// **'Enfoque'**
  String get pomodoroModeFocus;

  /// Label for short break timer mode
  ///
  /// In es, this message translates to:
  /// **'Descanso corto'**
  String get pomodoroModeShortBreak;

  /// Label for long break timer mode
  ///
  /// In es, this message translates to:
  /// **'Descanso largo'**
  String get pomodoroModeLongBreak;

  /// Status label when the timer is ready to start
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get pomodoroStatusReady;

  /// Status label when the timer is running
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get pomodoroStatusRunning;

  /// Status label when the timer is paused
  ///
  /// In es, this message translates to:
  /// **'Pausado'**
  String get pomodoroStatusPaused;

  /// Label for the start timer button
  ///
  /// In es, this message translates to:
  /// **'Iniciar'**
  String get pomodoroControlStart;

  /// Label for the pause timer button
  ///
  /// In es, this message translates to:
  /// **'Pausar'**
  String get pomodoroControlPause;

  /// Label for the resume timer button
  ///
  /// In es, this message translates to:
  /// **'Reanudar'**
  String get pomodoroControlResume;

  /// Label for the reset timer button
  ///
  /// In es, this message translates to:
  /// **'Reiniciar'**
  String get pomodoroControlReset;

  /// Label for the skip to next session button
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get pomodoroControlSkip;

  /// Message shown when a focus session completes
  ///
  /// In es, this message translates to:
  /// **'Sesión de enfoque terminada'**
  String get pomodoroCompletedFocus;

  /// Message shown when a short break completes
  ///
  /// In es, this message translates to:
  /// **'Descanso corto terminado'**
  String get pomodoroCompletedShortBreak;

  /// Message shown when a long break completes
  ///
  /// In es, this message translates to:
  /// **'Descanso largo terminado'**
  String get pomodoroCompletedLongBreak;

  /// Generic completion message with mode placeholder
  ///
  /// In es, this message translates to:
  /// **'{mode} terminado'**
  String pomodoroCompletedGeneric(String mode);

  /// Message indicating the next focus session is ready
  ///
  /// In es, this message translates to:
  /// **'Enfoque listo'**
  String get pomodoroNextFocus;

  /// Message indicating the next short break is ready
  ///
  /// In es, this message translates to:
  /// **'Descanso corto listo'**
  String get pomodoroNextShortBreak;

  /// Message indicating the next long break is ready
  ///
  /// In es, this message translates to:
  /// **'Descanso largo listo'**
  String get pomodoroNextLongBreak;

  /// Error message shown when a Pomodoro session fails to save
  ///
  /// In es, this message translates to:
  /// **'Sesión no guardada — toca para reintentar'**
  String get pomodoroSessionNotSaved;

  /// Label shown in the Pomodoro task selector when no task is associated with the session
  ///
  /// In es, this message translates to:
  /// **'Sin tarea'**
  String get pomodoroNoTask;

  /// Label for the task selector dropdown in the Pomodoro screen
  ///
  /// In es, this message translates to:
  /// **'Tarea'**
  String get pomodoroTaskLabel;

  /// Hint text shown in the Pomodoro task selector when no tasks exist
  ///
  /// In es, this message translates to:
  /// **'No hay tareas disponibles'**
  String get pomodoroNoTasksAvailable;

  /// Accessibility announcement when timer is ready
  ///
  /// In es, this message translates to:
  /// **'Temporizador listo'**
  String get pomodoroAnnounceReady;

  /// Accessibility announcement when timer starts running
  ///
  /// In es, this message translates to:
  /// **'Temporizador en curso'**
  String get pomodoroAnnounceRunning;

  /// Accessibility announcement when timer is paused
  ///
  /// In es, this message translates to:
  /// **'Temporizador pausado'**
  String get pomodoroAnnouncePaused;

  /// Accessibility announcement when a timer mode completes
  ///
  /// In es, this message translates to:
  /// **'{mode} terminado'**
  String pomodoroAnnounceCompleted(String mode);

  /// AppBar title for the Statistics screen
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get statisticsTitle;

  /// Period filter label for today
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get statisticsPeriodToday;

  /// Period filter label for this week
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get statisticsPeriodWeek;

  /// Period filter label for this month
  ///
  /// In es, this message translates to:
  /// **'Este mes'**
  String get statisticsPeriodMonth;

  /// Metric label for total focused time
  ///
  /// In es, this message translates to:
  /// **'Tiempo total'**
  String get statisticsTotalTime;

  /// Metric label for number of completed sessions
  ///
  /// In es, this message translates to:
  /// **'Sesiones'**
  String get statisticsSessions;

  /// Metric label for average session duration
  ///
  /// In es, this message translates to:
  /// **'Promedio'**
  String get statisticsAverage;

  /// Section header for statistics grouped by task
  ///
  /// In es, this message translates to:
  /// **'Por tarea'**
  String get statisticsByTask;

  /// Section header for statistics grouped by category
  ///
  /// In es, this message translates to:
  /// **'Por categoría'**
  String get statisticsByCategory;

  /// Fallback display name for sessions whose task has no category in the statistics breakdown
  ///
  /// In es, this message translates to:
  /// **'Sin categoría'**
  String get statisticsUncategorized;

  /// Empty state headline when no focus sessions exist
  ///
  /// In es, this message translates to:
  /// **'Aún no hay sesiones de enfoque'**
  String get statisticsEmptyTitle;

  /// Empty state supporting message when no focus sessions exist
  ///
  /// In es, this message translates to:
  /// **'Completa una sesión de enfoque en el temporizador Pomodoro para ver tus estadísticas de productividad aquí.'**
  String get statisticsEmptyMessage;

  /// Label for the retry button on statistics error state
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get statisticsRetry;

  /// Duration format showing only minutes
  ///
  /// In es, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// Duration format showing hours and minutes
  ///
  /// In es, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// Title of the delete category confirmation dialog
  ///
  /// In es, this message translates to:
  /// **'Eliminar categoría'**
  String get categoryDeleteTitle;

  /// Body message of the delete category confirmation dialog
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar \"{categoryName}\"? Sus tareas no se eliminarán. Quedarán sin categoría.'**
  String categoryDeleteMessage(String categoryName);

  /// AppBar title for the not-found screen
  ///
  /// In es, this message translates to:
  /// **'No encontrado'**
  String get errorNotFoundTitle;

  /// Body text for the not-found screen
  ///
  /// In es, this message translates to:
  /// **'Página no encontrada'**
  String get errorNotFoundMessage;

  /// Semantics label for the cycle progress indicator
  ///
  /// In es, this message translates to:
  /// **'{completed} de {total} sesiones de enfoque completadas'**
  String pomodoroCycleSemantics(int completed, int total);

  /// Semantics label for a completed cycle dot
  ///
  /// In es, this message translates to:
  /// **'Sesión {index} completada'**
  String pomodoroCycleSessionCompleted(int index);

  /// Semantics label for an incomplete cycle dot
  ///
  /// In es, this message translates to:
  /// **'Sesión {index} incompleta'**
  String pomodoroCycleSessionIncomplete(int index);

  /// Semantics label for a cycle dot that is currently in progress
  ///
  /// In es, this message translates to:
  /// **'Sesión {current} de {total}, {percent}% completada'**
  String pomodoroCycleSessionInProgress(int current, int total, int percent);

  /// Semantics label for the timer display showing remaining time
  ///
  /// In es, this message translates to:
  /// **'{minutes} minutos {seconds} segundos restantes'**
  String pomodoroTimerSemantics(int minutes, int seconds);

  /// Semantics label for sort direction button when ascending
  ///
  /// In es, this message translates to:
  /// **'Orden ascendente, toca para ordenar descendente'**
  String get todoSortAscendingSemantics;

  /// Semantics label for sort direction button when descending
  ///
  /// In es, this message translates to:
  /// **'Orden descendente, toca para ordenar ascendente'**
  String get todoSortDescendingSemantics;

  /// Tooltip for sort direction button when currently ascending
  ///
  /// In es, this message translates to:
  /// **'Ordenar descendente'**
  String get todoSortAscendingTooltip;

  /// Tooltip for sort direction button when currently descending
  ///
  /// In es, this message translates to:
  /// **'Ordenar ascendente'**
  String get todoSortDescendingTooltip;

  /// Semantics label for the delete task icon button on task cards
  ///
  /// In es, this message translates to:
  /// **'Eliminar tarea'**
  String get todoDeleteTaskSemantics;

  /// AppBar title when creating a new task
  ///
  /// In es, this message translates to:
  /// **'Nueva tarea'**
  String get todoFormNewTitle;

  /// AppBar title when editing an existing task
  ///
  /// In es, this message translates to:
  /// **'Editar tarea'**
  String get todoFormEditTitle;

  /// Label for the task title input field
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get todoFormTitleLabel;

  /// Hint text for the task title input field
  ///
  /// In es, this message translates to:
  /// **'Ingrese un título de tarea'**
  String get todoFormTitleHint;

  /// Validation error when the task title is empty
  ///
  /// In es, this message translates to:
  /// **'El título es obligatorio'**
  String get todoFormTitleRequired;

  /// Label for the task description input field
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get todoFormDescriptionLabel;

  /// Hint text for the task description input field
  ///
  /// In es, this message translates to:
  /// **'Agregue una descripción opcional'**
  String get todoFormDescriptionHint;

  /// Label for the priority dropdown
  ///
  /// In es, this message translates to:
  /// **'Prioridad'**
  String get todoFormPriorityLabel;

  /// Label for the category dropdown
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get todoFormCategoryLabel;

  /// Option text for no category in the category dropdown
  ///
  /// In es, this message translates to:
  /// **'Sin categoría'**
  String get todoFormNoCategory;

  /// Button label when saving edits to an existing task
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get todoFormSaveChanges;

  /// Generic error message when an unexpected error occurs
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Intente de nuevo.'**
  String get todoFormGenericError;

  /// Priority label for high
  ///
  /// In es, this message translates to:
  /// **'Alta'**
  String get todoPriorityHigh;

  /// Priority label for medium
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get todoPriorityMedium;

  /// Priority label for low
  ///
  /// In es, this message translates to:
  /// **'Baja'**
  String get todoPriorityLow;

  /// Semantics label and tooltip for the save category button
  ///
  /// In es, this message translates to:
  /// **'Guardar categoría'**
  String get todoCategorySaveSemantics;

  /// Semantics label for the cancel category creation button
  ///
  /// In es, this message translates to:
  /// **'Cancelar creación de categoría'**
  String get todoCategoryCancelSemantics;

  /// Semantics label for the rename category button
  ///
  /// In es, this message translates to:
  /// **'Renombrar {name}'**
  String todoCategoryRenameSemantics(String name);

  /// Semantics label for the delete category button
  ///
  /// In es, this message translates to:
  /// **'Eliminar {name}'**
  String todoCategoryDeleteSemantics(String name);

  /// Label for the create task FAB action
  ///
  /// In es, this message translates to:
  /// **'Crear tarea'**
  String get todoCreateTaskFab;

  /// Label for the create category FAB action
  ///
  /// In es, this message translates to:
  /// **'Crear categoría'**
  String get todoCreateCategoryFab;

  /// Tooltip for the main FAB when menu is open
  ///
  /// In es, this message translates to:
  /// **'Cerrar menú'**
  String get todoFabCloseMenu;

  /// Tooltip for the main FAB when menu is closed
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get todoFabCreate;

  /// AppBar title for the category manager screen
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get todoCategoriesTitle;

  /// Label text for the new category name input field
  ///
  /// In es, this message translates to:
  /// **'Nombre de la nueva categoría'**
  String get todoCategoryNewName;

  /// Empty state message when no categories exist
  ///
  /// In es, this message translates to:
  /// **'Aún no hay categorías'**
  String get todoCategoryEmptyState;

  /// Title of the rename category dialog
  ///
  /// In es, this message translates to:
  /// **'Renombrar categoría'**
  String get todoCategoryRenameTitle;

  /// Label text for category name input field in rename dialog
  ///
  /// In es, this message translates to:
  /// **'Nombre de la categoría'**
  String get todoCategoryNameLabel;

  /// Label for the rename action button in the rename dialog
  ///
  /// In es, this message translates to:
  /// **'Renombrar'**
  String get todoCategoryRename;

  /// Tooltip for the floating action button to add a new category
  ///
  /// In es, this message translates to:
  /// **'Agregar categoría'**
  String get todoCategoryAdd;

  /// Validation error when category name is empty
  ///
  /// In es, this message translates to:
  /// **'El nombre de la categoría es obligatorio'**
  String get todoCategoryNameRequired;

  /// Section header for Pomodoro activity summary on task edit screen
  ///
  /// In es, this message translates to:
  /// **'Actividad Pomodoro'**
  String get taskPomodoroActivity;

  /// Label for the completed Pomodoros metric in task Pomodoro stats
  ///
  /// In es, this message translates to:
  /// **'Pomodoros'**
  String get taskCompletedPomodoros;

  /// Label for the equivalent cycles metric in task Pomodoro stats
  ///
  /// In es, this message translates to:
  /// **'Ciclos equivalentes'**
  String get taskEquivalentCycles;

  /// Label for the focused time metric in task Pomodoro stats
  ///
  /// In es, this message translates to:
  /// **'Tiempo enfocado'**
  String get taskFocusedTime;

  /// Empty state message when no Pomodoro sessions exist for the task
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay actividad Pomodoro para esta tarea'**
  String get taskNoPomodoroActivity;

  /// Pluralized count of completed pomodoros for a task
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{1 pomodoro} other{{count} pomodoros}}'**
  String taskPomodoroCount(int count);

  /// Pluralized count of equivalent cycles for a task
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{1 ciclo} other{{count} ciclos}}'**
  String taskEquivalentCycleCount(int count);

  /// Label for the Start Pomodoro button on the task edit screen
  ///
  /// In es, this message translates to:
  /// **'Iniciar Pomodoro'**
  String get taskStartPomodoro;

  /// Accessibility label for the Start Pomodoro button including task name
  ///
  /// In es, this message translates to:
  /// **'Iniciar Pomodoro para {taskTitle}'**
  String taskStartPomodoroSemantic(String taskTitle);

  /// Warning shown when user tries to start a Pomodoro while another session is running or paused
  ///
  /// In es, this message translates to:
  /// **'Ya hay un Pomodoro en curso. Finalízalo o reinícialo antes de iniciar otro.'**
  String get pomodoroActiveSessionWarning;

  /// Section header for Privacy settings
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get settingsSectionPrivacy;

  /// Label for the privacy policy list tile
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get settingsPrivacyPolicy;

  /// Error message shown when url_launcher fails to open the privacy policy URL
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir la política de privacidad'**
  String get settingsPrivacyPolicyError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
