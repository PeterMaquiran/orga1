enum HabitGoalType {
  checkmark,
  time,
  liters,
  count;

  String get storageKey {
    switch (this) {
      case HabitGoalType.checkmark:
        return 'checkmark';
      case HabitGoalType.time:
        return 'time';
      case HabitGoalType.liters:
        return 'liters';
      case HabitGoalType.count:
        return 'count';
    }
  }

  String get defaultUnit {
    switch (this) {
      case HabitGoalType.time:
        return 'min';
      case HabitGoalType.liters:
        return 'L';
      case HabitGoalType.checkmark:
      case HabitGoalType.count:
        return '';
    }
  }

  static HabitGoalType fromStorage(String? raw) {
    switch (raw) {
      case 'time':
        return HabitGoalType.time;
      case 'liters':
        return HabitGoalType.liters;
      case 'count':
      case 'quantity':
      case 'pages':
      case 'distance':
        return HabitGoalType.count;
      case 'checkmark':
      default:
        return HabitGoalType.checkmark;
    }
  }
}
