import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show FocusNode, TextEditingController, TimeOfDay;
import 'package:uuid/uuid.dart';

import '../models/create_event_models.dart';
import '../models/stored_calendar_event.dart';
import '../../../../../module/event/repository/calendar_event_repository.dart';
import 'create_event_formatters.dart';

class CreateEventController extends ChangeNotifier {
  CreateEventController({
    CalendarEventRepository? repository,
    StoredCalendarEvent? initialEvent,
  }) : _repository = repository ?? CalendarEventRepository() {
    if (initialEvent != null) {
      _loadFromEvent(initialEvent);
    } else {
      _repeatUntilDate = _defaultRepeatUntil(_startDate, _repeatInterval);
      addNewTaskRow();
    }
  }

  final CalendarEventRepository _repository;
  String? _editingEventId;

  bool get isEditing => _editingEventId != null;

  final subjectController = TextEditingController();
  final bodyController = TextEditingController();
  final locationController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  bool _isRecurring = false;
  bool _isAllDayEvent = false;
  RepeatInterval _repeatInterval = RepeatInterval.week;
  final Set<int> _selectedDaysOfWeekIndices = {};
  late DateTime _repeatUntilDate;
  final List<TaskItem> todoList = [];

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  bool get isRecurring => _isRecurring;
  bool get isAllDayEvent => _isAllDayEvent;
  RepeatInterval get repeatInterval => _repeatInterval;
  Set<int> get selectedDaysOfWeekIndices => _selectedDaysOfWeekIndices;
  DateTime get repeatUntilDate => _repeatUntilDate;

  bool get isWeeklyRepeat => _isRecurring && _repeatInterval == RepeatInterval.week;

  bool get isDateRangeRepeat =>
      _isRecurring &&
      (_repeatInterval == RepeatInterval.month ||
          _repeatInterval == RepeatInterval.year);

  DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  DateTime _defaultRepeatUntil(DateTime from, RepeatInterval interval) {
    switch (interval) {
      case RepeatInterval.week:
        return from.add(const Duration(days: 7 * 12));
      case RepeatInterval.month:
        return DateTime(from.year, from.month + 6, from.day);
      case RepeatInterval.year:
        return DateTime(from.year + 2, from.month, from.day);
    }
  }

  String repeatSummary() => CreateEventFormatters.repeatSummary(
        interval: _repeatInterval,
        isAllDay: _isAllDayEvent,
        startDate: _startDate,
        endDate: _endDate,
        selectedDaysOfWeekIndices: _selectedDaysOfWeekIndices,
        dateOnly: dateOnly,
      );

  String repeatUntilSummary() => CreateEventFormatters.repeatUntilSummary(
        startDate: _startDate,
        repeatUntilDate: _repeatUntilDate,
        dateOnly: dateOnly,
      );

  void addNewTaskRow({String text = ''}) {
    final controller = TextEditingController(text: text);
    final focusNode = FocusNode();
    todoList.add(
      TaskItem(text: text, focusNode: focusNode, controller: controller),
    );
    notifyListeners();
  }

  void removeTaskRow(int index) {
    final item = todoList.removeAt(index);
    item.focusNode.dispose();
    item.controller.dispose();
    notifyListeners();
  }

  void toggleTaskDone(int index) {
    todoList[index].isDone = !todoList[index].isDone;
    notifyListeners();
  }

  void setAllDay(bool value) {
    _isAllDayEvent = value;
    notifyListeners();
  }

  void onEndDateChanged(DateTime date) {
    _endDate = isDateRangeRepeat ? dateOnly(date) : date;
    if (dateOnly(_endDate).isBefore(dateOnly(_startDate))) {
      _endDate = dateOnly(_startDate);
    }
    notifyListeners();
  }

  void onStartTimeChanged(TimeOfDay time) {
    _startDate = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      time.hour,
      time.minute,
    );
    if (_endDate.isBefore(_startDate) || _endDate.isAtSameMomentAs(_startDate)) {
      _endDate = _startDate.add(const Duration(hours: 1));
    }
    notifyListeners();
  }

  void onEndTimeChanged(TimeOfDay time) {
    _endDate = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      time.hour,
      time.minute,
    );
    if (!_endDate.isAfter(_startDate)) {
      _endDate = _startDate.add(const Duration(hours: 1));
    }
    notifyListeners();
  }

  void onRepeatToggled(bool value) {
    _isRecurring = value;
    if (value) {
      _repeatUntilDate = _defaultRepeatUntil(_startDate, _repeatInterval);
      if (_repeatInterval == RepeatInterval.week) {
        _startDate = dateOnly(_startDate);
        if (_selectedDaysOfWeekIndices.isEmpty) {
          _selectedDaysOfWeekIndices.add(_startDate.weekday % 7);
        }
      } else {
        _startDate = dateOnly(_startDate);
        _endDate = dateOnly(_endDate);
      }
    }
    notifyListeners();
  }

  void onRepeatIntervalChanged(RepeatInterval interval) {
    _repeatInterval = interval;
    _repeatUntilDate = _defaultRepeatUntil(_startDate, interval);
    if (interval == RepeatInterval.week) {
      _startDate = dateOnly(_startDate);
      _endDate = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _endDate.hour,
        _endDate.minute,
      );
      if (_selectedDaysOfWeekIndices.isEmpty) {
        _selectedDaysOfWeekIndices.add(_startDate.weekday % 7);
      }
    } else {
      _selectedDaysOfWeekIndices.clear();
      _startDate = dateOnly(_startDate);
      _endDate = dateOnly(_endDate);
      if (_endDate.isBefore(_startDate)) {
        _endDate = _startDate;
      }
    }
    notifyListeners();
  }

  void onStartDateChanged(DateTime date) {
    if (isDateRangeRepeat) {
      _startDate = dateOnly(date);
      if (dateOnly(_endDate).isBefore(_startDate)) {
        _endDate = _startDate;
      }
    } else {
      _startDate = date;
    }
    if (_repeatUntilDate.isBefore(dateOnly(_startDate))) {
      _repeatUntilDate = _defaultRepeatUntil(_startDate, _repeatInterval);
    }
    notifyListeners();
  }

  void onRepeatUntilChanged(DateTime date) {
    final picked = dateOnly(date);
    final start = dateOnly(_startDate);
    _repeatUntilDate = picked.isBefore(start) ? start : picked;
    notifyListeners();
  }

  void toggleDayOfWeek(int index) {
    if (_selectedDaysOfWeekIndices.contains(index)) {
      _selectedDaysOfWeekIndices.remove(index);
    } else {
      _selectedDaysOfWeekIndices.add(index);
    }
    notifyListeners();
  }

  void _loadFromEvent(StoredCalendarEvent event) {
    _editingEventId = event.id;
    subjectController.text = event.subject;
    bodyController.text = event.body ?? '';
    locationController.text = event.location;
    _startDate = event.startDate;
    _endDate = event.endDate;
    _isAllDayEvent = event.isAllDayEvent;
    _isRecurring = event.isRecurring;

    if (event.isRecurring && event.recurrence != null) {
      final recurrence = event.recurrence!;
      _repeatUntilDate = recurrence.until;
      _repeatInterval = _repeatIntervalFromFrequency(recurrence.frequency);
      _selectedDaysOfWeekIndices
        ..clear()
        ..addAll(recurrence.daysOfWeek);

      if (_repeatInterval == RepeatInterval.week) {
        _startDate = DateTime(
          recurrence.startDate.year,
          recurrence.startDate.month,
          recurrence.startDate.day,
          event.startDate.hour,
          event.startDate.minute,
        );
        _endDate = DateTime(
          recurrence.startDate.year,
          recurrence.startDate.month,
          recurrence.startDate.day,
          event.endDate.hour,
          event.endDate.minute,
        );
      }
    } else {
      _repeatUntilDate = _defaultRepeatUntil(_startDate, _repeatInterval);
    }

    if (event.checklist.isEmpty) {
      addNewTaskRow();
    } else {
      for (final item in event.checklist) {
        addNewTaskRow(text: item.text);
        todoList.last.isDone = item.isDone;
      }
    }
    notifyListeners();
  }

  RepeatInterval _repeatIntervalFromFrequency(int frequency) {
    switch (frequency) {
      case EventRecurrenceFrequency.monthly:
        return RepeatInterval.month;
      case EventRecurrenceFrequency.yearly:
        return RepeatInterval.year;
      default:
        return RepeatInterval.week;
    }
  }

  String? validateSubject(String? value) =>
      value == null || value.trim().isEmpty ? 'Title is required' : null;

  bool canSubmit() {
    if (subjectController.text.trim().isEmpty) return false;
    if (isRecurring &&
        repeatInterval == RepeatInterval.week &&
        selectedDaysOfWeekIndices.isEmpty) {
      return false;
    }
    return true;
  }

  Future<StoredCalendarEvent?> save() async {
    if (!canSubmit()) return null;

    final id = _editingEventId ?? const Uuid().v4();
    final checklist = todoList
        .where((item) => item.controller.text.trim().isNotEmpty)
        .map(
          (item) => StoredChecklistItem(
            text: item.controller.text.trim(),
            isDone: item.isDone,
          ),
        )
        .toList();

    StoredEventRecurrence? recurrence;
    if (_isRecurring) {
      recurrence = StoredEventRecurrence(
        startDate: dateOnly(_startDate),
        frequency: switch (_repeatInterval) {
          RepeatInterval.week => EventRecurrenceFrequency.weekly,
          RepeatInterval.month => EventRecurrenceFrequency.monthly,
          RepeatInterval.year => EventRecurrenceFrequency.yearly,
        },
        until: dateOnly(_repeatUntilDate),
        daysOfWeek: _repeatInterval == RepeatInterval.week
            ? _selectedDaysOfWeekIndices.toList()
            : const [],
      );
    }

    final event = StoredCalendarEvent(
      id: id,
      subject: subjectController.text.trim(),
      body: bodyController.text.trim().isEmpty ? null : bodyController.text.trim(),
      location: locationController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      isRecurring: _isRecurring,
      recurrence: recurrence,
      isAllDayEvent: _isAllDayEvent,
      checklist: checklist,
    );

    await _repository.insert(event);
    return event;
  }

  Future<bool> delete() async {
    final id = _editingEventId;
    if (id == null) return false;
    await _repository.delete(id);
    return true;
  }

  @override
  void dispose() {
    subjectController.dispose();
    bodyController.dispose();
    locationController.dispose();
    for (final item in todoList) {
      item.focusNode.dispose();
      item.controller.dispose();
    }
    super.dispose();
  }
}
