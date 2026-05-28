enum HomeViewMode {
  day,
  week,
}

extension HomeViewModeLabel on HomeViewMode {
  String get menuLabel {
    switch (this) {
      case HomeViewMode.day:
        return 'Today';
      case HomeViewMode.week:
        return 'Week';
    }
  }
}
