import 'package:flutter/cupertino.dart';
import 'package:orga1/ui/screen/ios/home/models/habit_form_input.dart';
import 'package:orga1/ui/screen/ios/home/models/quick_log_habit.dart';

import 'create-habit.dart';

class EditHabitScreen extends StatelessWidget {
  const EditHabitScreen({
    super.key,
    required this.habit,
    this.onSaveHabit,
  });

  final QuickLogHabit habit;
  final Future<void> Function(QuickLogHabit updatedHabit)? onSaveHabit;

  @override
  Widget build(BuildContext context) {
    return CreateHabitScreen(
      initialInput: habit.toFormInput(),
      title: 'Edit Habit',
      onSaveHabit: (input) async {
        final next = habit.applyFormInput(input);
        await onSaveHabit?.call(next);
      },
    );
  }
}
