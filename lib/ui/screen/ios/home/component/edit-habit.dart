import 'package:flutter/cupertino.dart';
import 'package:orga1/ui/screen/ios/home/models/quick_log_habit.dart';

import 'create-habit.dart';

class EditHabitScreen extends StatelessWidget {
  const EditHabitScreen({
    super.key,
    required this.habit,
    this.onSaveHabit,
  });

  final QuickLogHabit habit;
  final ValueChanged<QuickLogHabit>? onSaveHabit;

  @override
  Widget build(BuildContext context) {
    return CreateHabitScreen(
      initialHabit: habit.toMap(),
      onSaveHabit: (updated) {
        onSaveHabit?.call(QuickLogHabit.fromMap(updated).copyWith(
          currentValue: habit.currentValue,
        ));
      },
      title: 'Edit Habit',
    );
  }
}
