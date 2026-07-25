/// Minimal read-only representation of a selectable task for the Pomodoro
/// feature.
///
/// This type is owned by the Pomodoro feature and decouples it from the Todo
/// domain. The mapping from Todo's `Task` entity to [PomodoroTaskOption]
/// happens exclusively in the app composition root.
class PomodoroTaskOption {
  const PomodoroTaskOption({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  final int id;
  final String title;
  final bool isCompleted;
}
