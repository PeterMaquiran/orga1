import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orga1/core/event/entity/entity_day_of_week.dart';
import 'package:orga1/core/event/entity/entity_event.dart';
import 'package:orga1/core/event/entity/entity_event_recurrence.dart';

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

class CreateEventBottomSheet extends StatefulWidget {
  const CreateEventBottomSheet({Key? super.key});

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

  // Text Editing Controllers
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  final _locationController = TextEditingController();

  // Screen State Properties
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  bool _isRecurring = false;
  bool _isPrivate = false;
  bool _isAllDayEvent = false;

  // Recurrence Configuration State
  int _recurrenceFrequency = 1; 
  int _recurrenceUnitIndex = 1; // 0: Days, 1: Weeks, 2: Months, 3: Years
  List<int> _selectedDaysOfWeekIndices = []; 

  final List<String> _recurrenceUnits = ['Day(s)', 'Week(s)', 'Month(s)', 'Year(s)'];

  // --- Dynamic Todo Checklist State ---
  final List<TaskItem> _todoList = [];

  @override
  void initState() {
    super.initState();
    // Initialize with one empty task row by default to invite entry
    _addNewTaskRow();
  }

  @override
  void dispose() {
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

    // Request focus on the newly created item on the next frame execution
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
    });
  }

  // --- Manual Custom Date Formatting Engine ---
  String _pad(int value) => value.toString().padLeft(2, '0');

  String _formatDateTimeManually(DateTime time, bool dateOnly) {
    String baseDate = "${time.year}-${_pad(time.month)}-${_pad(time.day)}";
    if (dateOnly) return baseDate;
    return "$baseDate ${_pad(time.hour)}:${_pad(time.minute)}";
  }

  // --- Form submission and Hive Object compilation ---
  void _submitData() {
    if (!_formKey.currentState!.validate()) return;

    EventRecurrence? compiledRecurrence;
    if (_isRecurring) {
      List<DayOfWeek>? daysList;
      if (_recurrenceUnitIndex == 1 && _selectedDaysOfWeekIndices.isNotEmpty) {
        daysList = _selectedDaysOfWeekIndices
            .map((dayIndex) => DayOfWeek(day: dayIndex))
            .toList();
      }

      compiledRecurrence = EventRecurrence(
        startDate: _startDate,
        frequency: _recurrenceFrequency,
        occurrences: 10, 
        until: _startDate.add(const Duration(days: 90)), 
        daysOfWeek: daysList,
      );
    }

    // Extracting non-empty tasks to clean storage strings/lists
    final finalTasks = _todoList
        .where((item) => item.controller.text.trim().isNotEmpty)
        .map((item) => {"title": item.controller.text.trim(), "done": item.isDone})
        .toList();

    final newEvent = Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: _subjectController.text,
      body: _bodyController.text.isEmpty ? null : _bodyController.text,
      location: _locationController.text.isEmpty ? "--" : _locationController.text,
      startDate: _startDate,
      endDate: _endDate,
      isRecurring: _isRecurring,
      eventRecurrence: compiledRecurrence,
      hasAttachments: false,
      isPrivate: _isPrivate,
      isAllDayEvent: _isAllDayEvent,
      status: 1, 
      isOffline: true,
    );

    // TODO: Map `finalTasks` variable to your custom database field extension 
    // Hive.box<Event>('events').add(newEvent);

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
              child: const Text('Cancel', style: TextStyle(color: Colors.redAccent, fontSize: 17)),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('New Event', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 17)),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: _submitData,
                child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: CupertinoColors.activeBlue)),
              )
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomInset + 32),
              children: [
                // Section 1: Core Details
                _buildIOSGroup([
                  TextFormField(
                    controller: _subjectController,
                    style: const TextStyle(fontSize: 17),
                    decoration: const InputDecoration(hintText: 'Title', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
                  ),
                  const Divider(height: 1, indent: 16),
                  TextFormField(
                    controller: _locationController,
                    style: const TextStyle(fontSize: 17),
                    decoration: const InputDecoration(hintText: 'Location', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                  ),
                ]),

                const SizedBox(height: 22),

                // Section 2: Time configurations
                _buildIOSGroup([
                  _buildSwitchRow('All-day', _isAllDayEvent, (val) => setState(() => _isAllDayEvent = val)),
                  const Divider(height: 1, indent: 16),
                  _buildDatePickerRow('Starts', _startDate, (date) => setState(() => _startDate = date)),
                  const Divider(height: 1, indent: 16),
                  _buildDatePickerRow('Ends', _endDate, (date) => setState(() => _endDate = date)),
                ]),

                const SizedBox(height: 22),

                // Section 3: Recurrence Picker Hooks
                _buildIOSGroup([
                  _buildSwitchRow('Repeat', _isRecurring, (val) => setState(() => _isRecurring = val)),
                  if (_isRecurring) ...[
                    const Divider(height: 1, indent: 16),
                    ListTile(
                      title: const Text('Interval Settings', style: TextStyle(fontSize: 17)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Every $_recurrenceFrequency ${_recurrenceUnits[_recurrenceUnitIndex].toLowerCase()}",
                            style: const TextStyle(color: CupertinoColors.inactiveGray, fontSize: 16),
                          ),
                          const Icon(Icons.chevron_right, color: CupertinoColors.inactiveGray, size: 22),
                        ],
                      ),
                      onTap: () => _openIOSRecurrencePicker(),
                    ),
                    if (_recurrenceUnitIndex == 1) ...[
                      const Divider(height: 1, indent: 16),
                      _buildDayOfWeekSelector(),
                    ]
                  ],
                  const Divider(height: 1, indent: 16),
                  _buildSwitchRow('Private Event', _isPrivate, (val) => setState(() => _isPrivate = val)),
                ]),

                const SizedBox(height: 22),

                // Section 4: Secondary Descriptions
                _buildIOSGroup([
                  TextFormField(
                    controller: _bodyController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Notes',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ]),

                const SizedBox(height: 22),

                // Section 5: Premium iOS Style Todo Checklist Group
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 12.0, bottom: 8.0),
                      child: Text("CHECKLIST", style: TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                    ),
                    _buildIOSGroup([
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _todoList.length,
                        itemBuilder: (context, index) {
                          final item = _todoList[index];
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                child: Row(
                                  children: [
                                    // iOS Clean Circular Checkbox Ring
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          item.isDone = !item.isDone;
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 12),
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: item.isDone ? CupertinoColors.activeBlue : CupertinoColors.systemGrey3,
                                            width: 2,
                                          ),
                                          color: item.isDone ? CupertinoColors.activeBlue : Colors.transparent,
                                        ),
                                        child: item.isDone
                                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                                            : null,
                                      ),
                                    ),
                                    // Expandable Input Area
                                    Expanded(
                                      child: TextField(
                                        controller: item.controller,
                                        focusNode: item.focusNode,
                                        textInputAction: TextInputAction.next,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: item.isDone ? CupertinoColors.secondaryLabel : Colors.black,
                                          decoration: item.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'Add item...',
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        onSubmitted: (_) {
                                          // Auto-generate a new row when tapping "Next/Return" on keyboard
                                          if (index == _todoList.length - 1 && item.controller.text.isNotEmpty) {
                                            _addNewTaskRow();
                                          }
                                        },
                                      ),
                                    ),
                                    // Delete Task Row Button
                                    if (_todoList.length > 1)
                                      IconButton(
                                        icon: const Icon(CupertinoIcons.minus_circle_fill, color: Colors.redAccent, size: 20),
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
                                const Divider(height: 1, indent: 46),
                            ],
                          );
                        },
                      ),
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

  // --- Core iOS/Google Calendar Wheel Modal Implementation ---
  void _openIOSRecurrencePicker() {
    int tempFrequency = _recurrenceFrequency;
    int tempUnitIndex = _recurrenceUnitIndex;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                        ),
                        const Text('Custom Repeat', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _recurrenceFrequency = tempFrequency;
                              _recurrenceUnitIndex = tempUnitIndex;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: CupertinoColors.activeBlue)),
                        )
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      "Repeats every $tempFrequency ${_recurrenceUnits[tempUnitIndex].toLowerCase()}",
                      style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(initialItem: tempFrequency - 1),
                              itemExtent: 38,
                              onSelectedItemChanged: (index) => setModalState(() => tempFrequency = index + 1),
                              children: List.generate(30, (index) => Center(
                                child: Text('${index + 1}', style: const TextStyle(fontSize: 21)),
                              )),
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(initialItem: tempUnitIndex),
                              itemExtent: 38,
                              onSelectedItemChanged: (index) => setModalState(() => tempUnitIndex = index),
                              children: _recurrenceUnits.map((unit) => Center(
                                child: Text(unit, style: const TextStyle(fontSize: 21)),
                              )).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- UI Layout Helper Modifiers ---
  Widget _buildIOSGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400)),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildDatePickerRow(String title, DateTime currentTime, Function(DateTime) onDateTimeChanged) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(title, style: const TextStyle(fontSize: 17)),
      trailing: Text(
        _formatDateTimeManually(currentTime, _isAllDayEvent),
        style: const TextStyle(color: CupertinoColors.activeBlue, fontSize: 17),
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
                mode: _isAllDayEvent ? CupertinoDatePickerMode.date : CupertinoDatePickerMode.dateAndTime,
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
    final List<String> weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text("REPEATS ON", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
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
                    color: isSelected ? CupertinoColors.activeBlue : const Color(0xFFE5E5EA),
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