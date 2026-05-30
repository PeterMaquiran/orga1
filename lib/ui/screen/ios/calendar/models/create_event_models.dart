import 'package:flutter/material.dart';

enum RepeatInterval { week, month, year }

class TaskItem {
  String text;
  bool isDone;
  FocusNode focusNode;
  TextEditingController controller;

  TaskItem({
    required this.text,
    this.isDone = false,
    required this.focusNode,
    required this.controller,
  });
}

abstract final class EventRecurrenceFrequency {
  static const int weekly = 1;
  static const int monthly = 2;
  static const int yearly = 3;
}
