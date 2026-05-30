import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

enum RepeatInterval { week, month, year }

class CreateEventBottomSheet extends StatefulWidget {
  const CreateEventBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateEventBottomSheet(),
    );
  }

  @override
  State<CreateEventBottomSheet> createState() => _CreateEventBottomSheetState();
}

class _CreateEventBottomSheetState extends State<CreateEventBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  bool _isRecurring = false;
  bool _isAllDayEvent = false;

  RepeatInterval _repeatInterval = RepeatInterval.week;
  final List<int> _selectedDaysOfWeekIndices = [];
  late DateTime _repeatUntilDate;

  final List<TaskItem> _todoList = [];

  bool get _isWeeklyRepeat =>
      _isRecurring && _repeatInterval == RepeatInterval.week;

  bool get _isDateRangeRepeat =>
      _isRecurring &&
      (_repeatInterval == RepeatInterval.month ||
          _repeatInterval == RepeatInterval.year);

  @override
  void initState() {
    super.initState();
    _repeatUntilDate = _defaultRepeatUntil(_startDate, _repeatInterval);
    _addNewTaskRow();
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

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

  static const _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDateOnly(DateTime time) =>
      '${_monthsShort[time.month - 1]} ${time.day}, ${time.year}';

  String _formatShortDate(DateTime time) {
    return '${_monthsShort[time.month - 1]} ${time.day}';
  }

  String _formatWhenFieldDate(DateTime time) {
    if (_repeatInterval == RepeatInterval.month) {
      return '${time.day}';
    }
    if (_repeatInterval == RepeatInterval.year) {
      return _formatShortDate(time);
    }
    return _formatDateOnly(time);
  }

  String _formatMonthDayRange(DateTime start, DateTime end) {
    if (start.day == end.day) return '${start.day}';
    return '${start.day}–${end.day}';
  }

  String _formatYearDateRange(DateTime start, DateTime end) {
    if (start.month == end.month) {
      return '${_monthsShort[start.month - 1]} ${start.day}–${end.day}';
    }
    return '${_formatShortDate(start)} – ${_formatShortDate(end)}';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    _locationController.dispose();
    for (var item in _todoList) {
      item.focusNode.dispose();
      item.controller.dispose();
    }
    super.dispose();
  }

  void _addNewTaskRow({String text = ""}) {
    final controller = TextEditingController(text: text);
    final focusNode = FocusNode();

    setState(() {
      _todoList.add(
        TaskItem(text: text, focusNode: focusNode, controller: controller),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _pad(int value) => value.toString().padLeft(2, '0');

  String _formatDateTime(DateTime time) {
    if (_isAllDayEvent) return _formatDateOnly(time);
    return '${_formatDateOnly(time)} · ${_formatTime(time)}';
  }

  String _formatTime(DateTime time) =>
      '${_pad(time.hour)}:${_pad(time.minute)}';

  String _repeatSummary() {
    switch (_repeatInterval) {
      case RepeatInterval.week:
        if (_selectedDaysOfWeekIndices.isEmpty) {
          return 'Select at least one day below';
        }
        const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        final days = _selectedDaysOfWeekIndices.toList()..sort();
        final names = days.map((i) => labels[i]).join(', ');
        if (_isAllDayEvent) {
          return 'Every week on $names, all day';
        }
        return 'Every week on $names, ${_formatTime(_startDate)}–${_formatTime(_endDate)}';
      case RepeatInterval.month:
        final range = _dateOnly(_endDate).isAfter(_dateOnly(_startDate))
            ? ' (${_formatMonthDayRange(_startDate, _endDate)})'
            : ' on day ${_startDate.day}';
        return 'Every month$range';
      case RepeatInterval.year:
        final range = _dateOnly(_endDate).isAfter(_dateOnly(_startDate))
            ? ' (${_formatYearDateRange(_startDate, _endDate)})'
            : ' on ${_formatShortDate(_startDate)}';
        return 'Every year$range';
    }
  }

  String _repeatUntilSummary() {
    final start = _dateOnly(_startDate);
    final until = _dateOnly(_repeatUntilDate);
    final days = until.difference(start).inDays;
    if (days <= 0) return 'Last repetition is the same day as start';
    return 'Repeats until ${_formatDateOnly(until)} ($days days)';
  }

  void _onEndDateChanged(DateTime date) {
    setState(() {
      _endDate = _isDateRangeRepeat ? _dateOnly(date) : date;
      if (_dateOnly(_endDate).isBefore(_dateOnly(_startDate))) {
        _endDate = _dateOnly(_startDate);
      }
    });
  }

  void _onStartTimeChanged(TimeOfDay time) {
    setState(() {
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
    });
  }

  void _onEndTimeChanged(TimeOfDay time) {
    setState(() {
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
    });
  }

  void _onRepeatToggled(bool value) {
    setState(() {
      _isRecurring = value;
      if (value) {
        _repeatUntilDate = _defaultRepeatUntil(_startDate, _repeatInterval);
        if (_repeatInterval == RepeatInterval.week) {
          _startDate = _dateOnly(_startDate);
          if (_selectedDaysOfWeekIndices.isEmpty) {
            _selectedDaysOfWeekIndices.add(_startDate.weekday % 7);
          }
        } else {
          _startDate = _dateOnly(_startDate);
          _endDate = _dateOnly(_endDate);
        }
      }
    });
  }

  void _onRepeatIntervalChanged(RepeatInterval interval) {
    setState(() {
      _repeatInterval = interval;
      _repeatUntilDate = _defaultRepeatUntil(_startDate, interval);
      if (interval == RepeatInterval.week) {
        _startDate = _dateOnly(_startDate);
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
        _startDate = _dateOnly(_startDate);
        _endDate = _dateOnly(_endDate);
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      }
    });
  }

  void _onStartDateChanged(DateTime date) {
    setState(() {
      if (_isDateRangeRepeat) {
        _startDate = _dateOnly(date);
        if (_dateOnly(_endDate).isBefore(_startDate)) {
          _endDate = _startDate;
        }
      } else {
        _startDate = date;
      }
      if (_repeatUntilDate.isBefore(_dateOnly(_startDate))) {
        _repeatUntilDate = _defaultRepeatUntil(_startDate, _repeatInterval);
      }
    });
  }

  void _onRepeatUntilChanged(DateTime date) {
    final picked = _dateOnly(date);
    final start = _dateOnly(_startDate);
    setState(() {
      _repeatUntilDate = picked.isBefore(start) ? start : picked;
    });
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;
    if (_isRecurring &&
        _repeatInterval == RepeatInterval.week &&
        _selectedDaysOfWeekIndices.isEmpty) {
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF2F2F7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.redAccent, fontSize: 17),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'New Event',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 17,
              ),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: _submitData,
                child: const Text(
                  'Add',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: bottomInset + 32,
              ),
              children: [
                _buildIOSGroup([
                  TextFormField(
                    controller: _subjectController,
                    style: const TextStyle(fontSize: 17),
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Title is required' : null,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Divider(
                      height: 1,
                      color: Color(0xFFE5E5EA),
                      thickness: 1,
                    ),
                  ),
                  TextFormField(
                    controller: _locationController,
                    style: const TextStyle(fontSize: 17),
                    decoration: const InputDecoration(
                      hintText: 'Location',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 22),

                _buildSectionLabel('WHEN'),
                _buildIOSGroup([
                  _buildSwitchRow(
                    'All-day',
                    _isAllDayEvent,
                    (val) => setState(() => _isAllDayEvent = val),
                  ),
                  ..._buildWhenFields(),
                ]),

                const SizedBox(height: 22),

                _buildSectionLabel('REPEAT'),
                _buildIOSGroup([
                  _buildSwitchRow('Repeat', _isRecurring, _onRepeatToggled),
                  if (_isRecurring) ...[
                    const _InsetDivider(),
                    _buildRepeatIntervalControl(),
                    if (_repeatInterval == RepeatInterval.week) ...[
                      const _InsetDivider(),
                      _buildSeriesStartRow(),
                      const _InsetDivider(),
                      _buildDayOfWeekSelector(),
                    ],
                    const _InsetDivider(),
                    _buildRepeatUntilRow(),
                    _buildRepeatRangeVisual(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                      child: Text(
                        _repeatSummary(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: Text(
                        _repeatUntilSummary(),
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.activeBlue.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ]),

                const SizedBox(height: 22),

                _buildIOSGroup([
                  TextFormField(
                    controller: _bodyController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Notes',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 22),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('CHECKLIST'),
                    _buildIOSGroup([
                      for (int index = 0; index < _todoList.length; index++) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _todoList[index].isDone =
                                        !_todoList[index].isDone;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _todoList[index].isDone
                                          ? CupertinoColors.activeBlue
                                          : CupertinoColors.systemGrey3,
                                      width: 2,
                                    ),
                                    color: _todoList[index].isDone
                                        ? CupertinoColors.activeBlue
                                        : Colors.transparent,
                                  ),
                                  child: _todoList[index].isDone
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _todoList[index].controller,
                                  focusNode: _todoList[index].focusNode,
                                  textInputAction: TextInputAction.next,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _todoList[index].isDone
                                        ? CupertinoColors.secondaryLabel
                                        : Colors.black,
                                    decoration: _todoList[index].isDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Add item...',
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  onSubmitted: (_) {
                                    if (_todoList[index]
                                        .controller
                                        .text
                                        .trim()
                                        .isNotEmpty) {
                                      _addNewTaskRow();
                                    }
                                  },
                                ),
                              ),
                              if (_todoList.length > 1)
                                IconButton(
                                  icon: const Icon(
                                    CupertinoIcons.minus_circle_fill,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _todoList.removeAt(index);
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                        if (index < _todoList.length - 1)
                          const Padding(
                            padding: EdgeInsets.only(left: 50.0),
                            child: Divider(
                              height: 1,
                              color: Color(0xFFE5E5EA),
                              thickness: 1,
                            ),
                          ),
                      ],
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildWhenFields() {
    if (_isWeeklyRepeat) {
      if (_isAllDayEvent) return [];
      return [
        const _InsetDivider(),
        _buildTimeRangeRow(),
      ];
    }

    if (_isDateRangeRepeat) {
      return [
        const _InsetDivider(),
        _buildDatePickerRow(
          'Starts',
          _startDate,
          _onStartDateChanged,
          dateOnly: true,
        ),
        _buildDatePickerRow(
          'Ends',
          _endDate,
          _onEndDateChanged,
          dateOnly: true,
        ),
        if (!_isAllDayEvent) ...[
          const _InsetDivider(),
          _buildTimeRangeRow(),
        ],
      ];
    }

    return [
      const _InsetDivider(),
      _buildDatePickerRow(
        'Starts',
        _startDate,
        _onStartDateChanged,
        dateOnly: _isAllDayEvent,
      ),
      _buildDatePickerRow(
        'Ends',
        _endDate,
        _onEndDateChanged,
        dateOnly: _isAllDayEvent,
      ),
    ];
  }

  Widget _buildSeriesStartRow() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: const Text('Series starts', style: TextStyle(fontSize: 17)),
      trailing: Text(
        _formatDateOnly(_startDate),
        style: const TextStyle(
          color: CupertinoColors.activeBlue,
          fontSize: 17,
        ),
      ),
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => Container(
            height: 240,
            color: Colors.white,
            padding: const EdgeInsets.only(top: 6),
            child: SafeArea(
              top: false,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _startDate,
                onDateTimeChanged: _onStartDateChanged,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeRangeRow() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: const Text('Hours', style: TextStyle(fontSize: 17)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _showTimePicker(
              TimeOfDay(hour: _startDate.hour, minute: _startDate.minute),
              _onStartTimeChanged,
            ),
            child: Text(
              _formatTime(_startDate),
              style: const TextStyle(
                color: CupertinoColors.activeBlue,
                fontSize: 17,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('–'),
          ),
          GestureDetector(
            onTap: () => _showTimePicker(
              TimeOfDay(hour: _endDate.hour, minute: _endDate.minute),
              _onEndTimeChanged,
            ),
            child: Text(
              _formatTime(_endDate),
              style: const TextStyle(
                color: CupertinoColors.activeBlue,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTimePicker(TimeOfDay initial, ValueChanged<TimeOfDay> onChanged) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
          initialDateTime: DateTime(
            2025,
            1,
            1,
            initial.hour,
            initial.minute,
          ),
          onDateTimeChanged: (date) {
            onChanged(TimeOfDay(hour: date.hour, minute: date.minute));
          },
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: CupertinoColors.secondaryLabel,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildRepeatUntilRow() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: const Text('Repeat until', style: TextStyle(fontSize: 17)),
      trailing: Text(
        _formatDateOnly(_repeatUntilDate),
        style: const TextStyle(
          color: CupertinoColors.activeBlue,
          fontSize: 17,
        ),
      ),
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => Container(
            height: 240,
            color: Colors.white,
            padding: const EdgeInsets.only(top: 6),
            child: SafeArea(
              top: false,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                minimumDate: _dateOnly(_startDate),
                initialDateTime: _repeatUntilDate,
                onDateTimeChanged: _onRepeatUntilChanged,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRepeatRangeVisual() {
    final start = _dateOnly(_startDate);
    final until = _dateOnly(_repeatUntilDate);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'REPETITION RANGE',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildRangeDateChip(
                label: 'First',
                date: start,
                filled: true,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              CupertinoColors.activeBlue.withValues(alpha: 0.25),
                              CupertinoColors.activeBlue,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.arrow_right,
                        size: 14,
                        color: CupertinoColors.activeBlue,
                      ),
                    ],
                  ),
                ),
              ),
              _buildRangeDateChip(
                label: 'Last',
                date: until,
                filled: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRangeDateChip({
    required String label,
    required DateTime date,
    required bool filled,
  }) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.secondaryLabel,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: filled
                ? CupertinoColors.activeBlue.withValues(alpha: 0.12)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: CupertinoColors.activeBlue.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Text(
                _formatShortDate(date),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.activeBlue,
                ),
              ),
              Text(
                '${date.year}',
                style: const TextStyle(
                  fontSize: 11,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatIntervalControl() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      child: Row(
        children: [
          const Text('Every', style: TextStyle(fontSize: 17)),
          const Spacer(),
          SizedBox(
            width: 220,
            child: CupertinoSegmentedControl<RepeatInterval>(
              selectedColor: CupertinoColors.activeBlue,
              borderColor: CupertinoColors.activeBlue,
              pressedColor:
                  CupertinoColors.activeBlue.withValues(alpha: 0.1),
              groupValue: _repeatInterval,
              children: const {
                RepeatInterval.week: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('Week', style: TextStyle(fontSize: 13)),
                ),
                RepeatInterval.month: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('Month', style: TextStyle(fontSize: 13)),
                ),
                RepeatInterval.year: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('Year', style: TextStyle(fontSize: 13)),
                ),
              },
              onValueChanged: _onRepeatIntervalChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIOSGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchRow(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildDatePickerRow(
    String title,
    DateTime currentTime,
    ValueChanged<DateTime> onDateTimeChanged, {
    bool dateOnly = false,
  }) {
    final showDateOnly = dateOnly || _isAllDayEvent;
    final trailingText = showDateOnly
        ? (_isDateRangeRepeat
            ? _formatWhenFieldDate(currentTime)
            : _formatDateOnly(currentTime))
        : _formatDateTime(currentTime);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(title, style: const TextStyle(fontSize: 17)),
      trailing: Text(
        trailingText,
        style: const TextStyle(
          color: CupertinoColors.activeBlue,
          fontSize: 17,
        ),
      ),
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => Container(
            height: 240,
            color: Colors.white,
            padding: const EdgeInsets.only(top: 6),
            child: SafeArea(
              top: false,
              child: CupertinoDatePicker(
                mode: showDateOnly
                    ? CupertinoDatePickerMode.date
                    : CupertinoDatePickerMode.dateAndTime,
                initialDateTime: currentTime,
                onDateTimeChanged: onDateTimeChanged,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayOfWeekSelector() {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'ON THESE DAYS',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final isSelected = _selectedDaysOfWeekIndices.contains(index);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedDaysOfWeekIndices.remove(index);
                    } else {
                      _selectedDaysOfWeekIndices.add(index);
                    }
                  });
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? CupertinoColors.activeBlue
                        : const Color(0xFFE5E5EA),
                  ),
                  child: Center(
                    child: Text(
                      weekdays[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _InsetDivider extends StatelessWidget {
  const _InsetDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 16.0),
      child: Divider(height: 1, color: Color(0xFFE5E5EA), thickness: 1),
    );
  }
}
