import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../logic/create_event_controller.dart';
import '../logic/create_event_formatters.dart';
import '../models/create_event_models.dart';

class CreateEventBottomSheet extends StatefulWidget {
  const CreateEventBottomSheet({super.key, this.onSaved});

  final Future<void> Function()? onSaved;

  static void show(
    BuildContext context, {
    Future<void> Function()? onSaved,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateEventBottomSheet(onSaved: onSaved),
    );
  }

  @override
  State<CreateEventBottomSheet> createState() => _CreateEventBottomSheetState();
}

class _CreateEventBottomSheetState extends State<CreateEventBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  late final CreateEventController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CreateEventController();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addNewTaskRow({String text = ''}) {
    _controller.addNewTaskRow(text: text);
    final focusNode = _controller.todoList.last.focusNode;
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

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    final saved = await _controller.save();
    if (!mounted) return;
    if (saved != null) {
      await widget.onSaved?.call();
      if (!mounted) return;
      Navigator.pop(context);
    }
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
                    controller: _controller.subjectController,
                    style: const TextStyle(fontSize: 17),
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    validator: _controller.validateSubject,
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
                    controller: _controller.locationController,
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
                    _controller.isAllDayEvent,
                    (val) => _controller.setAllDay(val),
                  ),
                  ..._buildWhenFields(),
                ]),

                const SizedBox(height: 22),

                _buildSectionLabel('REPEAT'),
                _buildIOSGroup([
                  _buildSwitchRow('Repeat', _controller.isRecurring, _controller.onRepeatToggled),
                  if (_controller.isRecurring) ...[
                    const _InsetDivider(),
                    _buildRepeatIntervalControl(),
                    if (_controller.repeatInterval == RepeatInterval.week) ...[
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
                        _controller.repeatSummary(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: Text(
                        _controller.repeatUntilSummary(),
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
                    controller: _controller.bodyController,
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
                      for (int index = 0; index < _controller.todoList.length; index++) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => _controller.toggleTaskDone(index),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _controller.todoList[index].isDone
                                          ? CupertinoColors.activeBlue
                                          : CupertinoColors.systemGrey3,
                                      width: 2,
                                    ),
                                    color: _controller.todoList[index].isDone
                                        ? CupertinoColors.activeBlue
                                        : Colors.transparent,
                                  ),
                                  child: _controller.todoList[index].isDone
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
                                  controller: _controller.todoList[index].controller,
                                  focusNode: _controller.todoList[index].focusNode,
                                  textInputAction: TextInputAction.next,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _controller.todoList[index].isDone
                                        ? CupertinoColors.secondaryLabel
                                        : Colors.black,
                                    decoration: _controller.todoList[index].isDone
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
                                    if (_controller.todoList[index]
                                        .controller
                                        .text
                                        .trim()
                                        .isNotEmpty) {
                                      _addNewTaskRow();
                                    }
                                  },
                                ),
                              ),
                              if (_controller.todoList.length > 1)
                                IconButton(
                                  icon: const Icon(
                                    CupertinoIcons.minus_circle_fill,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  onPressed: () => _controller.removeTaskRow(index),
                                ),
                            ],
                          ),
                        ),
                        if (index < _controller.todoList.length - 1)
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
    if (_controller.isWeeklyRepeat) {
      if (_controller.isAllDayEvent) return [];
      return [
        const _InsetDivider(),
        _buildTimeRangeRow(),
      ];
    }

    if (_controller.isDateRangeRepeat) {
      return [
        const _InsetDivider(),
        _buildDatePickerRow(
          'Starts',
          _controller.startDate,
          _controller.onStartDateChanged,
          dateOnly: true,
        ),
        _buildDatePickerRow(
          'Ends',
          _controller.endDate,
          _controller.onEndDateChanged,
          dateOnly: true,
        ),
        if (!_controller.isAllDayEvent) ...[
          const _InsetDivider(),
          _buildTimeRangeRow(),
        ],
      ];
    }

    return [
      const _InsetDivider(),
      _buildDatePickerRow(
        'Starts',
        _controller.startDate,
        _controller.onStartDateChanged,
        dateOnly: _controller.isAllDayEvent,
      ),
      _buildDatePickerRow(
        'Ends',
        _controller.endDate,
        _controller.onEndDateChanged,
        dateOnly: _controller.isAllDayEvent,
      ),
    ];
  }

  Widget _buildSeriesStartRow() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: const Text('Series starts', style: TextStyle(fontSize: 17)),
      trailing: Text(
        CreateEventFormatters.formatDateOnly(_controller.startDate),
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
                initialDateTime: _controller.startDate,
                onDateTimeChanged: _controller.onStartDateChanged,
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
              TimeOfDay(hour: _controller.startDate.hour, minute: _controller.startDate.minute),
              _controller.onStartTimeChanged,
            ),
            child: Text(
              CreateEventFormatters.formatTime(_controller.startDate),
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
              TimeOfDay(hour: _controller.endDate.hour, minute: _controller.endDate.minute),
              _controller.onEndTimeChanged,
            ),
            child: Text(
              CreateEventFormatters.formatTime(_controller.endDate),
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
        CreateEventFormatters.formatDateOnly(_controller.repeatUntilDate),
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
                minimumDate: _controller.dateOnly(_controller.startDate),
                initialDateTime: _controller.repeatUntilDate,
                onDateTimeChanged: _controller.onRepeatUntilChanged,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRepeatRangeVisual() {
    final start = _controller.dateOnly(_controller.startDate);
    final until = _controller.dateOnly(_controller.repeatUntilDate);

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
                CreateEventFormatters.formatShortDate(date),
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
              groupValue: _controller.repeatInterval,
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
              onValueChanged: _controller.onRepeatIntervalChanged,
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
    final showDateOnly = dateOnly || _controller.isAllDayEvent;
    final trailingText = showDateOnly
        ? (_controller.isDateRangeRepeat
            ? CreateEventFormatters.formatWhenFieldDate(
                currentTime,
                _controller.repeatInterval,
              )
            : CreateEventFormatters.formatDateOnly(currentTime))
        : CreateEventFormatters.formatDateTime(
            currentTime,
            isAllDay: _controller.isAllDayEvent,
          );
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
              final isSelected =
                  _controller.selectedDaysOfWeekIndices.contains(index);
              return GestureDetector(
                onTap: () => _controller.toggleDayOfWeek(index),
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
