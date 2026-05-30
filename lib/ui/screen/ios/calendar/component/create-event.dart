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
  final ScrollController _scrollController = ScrollController();

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
  int _recurrenceUnitIndex = 1; 
  List<int> _selectedDaysOfWeekIndices = []; 

  final List<String> _recurrenceUnits = ['Day(s)', 'Week(s)', 'Month(s)', 'Year(s)'];

  // Dynamic Todo Checklist State
  final List<TaskItem> _todoList = [];

  @override
  void initState() {
    super.initState();
    _addNewTaskRow();
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

  String _formatDateTimeManually(DateTime time, bool dateOnly) {
    String baseDate = "${time.year}-${_pad(time.month)}-${_pad(time.day)}";
    if (dateOnly) return baseDate;
    return "$baseDate ${_pad(time.hour)}:${_pad(time.minute)}";
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;
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
              controller: _scrollController,
              padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: bottomInset + 32),
              children: [
                // Section 1: Core Details with FIXED Visible Line
                _buildIOSGroup([
                  TextFormField(
                    controller: _subjectController,
                    style: const TextStyle(fontSize: 17),
                    decoration: const InputDecoration(
                      hintText: 'Title', 
                      border: InputBorder.none, 
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
                  ),
                  // This is the missing explicit line! Indented exactly to match iOS
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Divider(height: 1, color: Color(0xFFE5E5EA), thickness: 1),
                  ),
                  TextFormField(
                    controller: _locationController,
                    style: const TextStyle(fontSize: 17),
                    decoration: const InputDecoration(
                      hintText: 'Location', 
                      border: InputBorder.none, 
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                    ),
                  ),
                ]),

                const SizedBox(height: 22),

                // Section 2: Time configurations
                _buildIOSGroup([
                  _buildSwitchRow('All-day', _isAllDayEvent, (val) => setState(() => _isAllDayEvent = val)),
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Divider(height: 1, color: Color(0xFFE5E5EA), thickness: 1),
                  ),
                  _buildDatePickerRow('Starts', _startDate, (date) => setState(() => _startDate = date)),
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Divider(height: 1, color: Color(0xFFE5E5EA), thickness: 1),
                  ),
                  _buildDatePickerRow('Ends', _endDate, (date) => setState(() => _endDate = date)),
                ]),

                const SizedBox(height: 22),

                // Section 3: Recurrence Picker Hooks
                _buildIOSGroup([
                  _buildSwitchRow('Repeat', _isRecurring, (val) => setState(() => _isRecurring = val)),
                  if (_isRecurring) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Divider(height: 1, color: Color(0xFFE5E5EA), thickness: 1),
                    ),
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
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Divider(height: 1, color: Color(0xFFE5E5EA), thickness: 1),
                      ),
                      _buildDayOfWeekSelector(),
                    ]
                  ],
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Divider(height: 1, color: Color(0xFFE5E5EA), thickness: 1),
                  ),
                  _buildSwitchRow('Private Event', _isPrivate, (val) => setState(() => _isPrivate = val)),
                ]),

                const SizedBox(height: 22),

                // Section 4: Notes
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

                // Section 5: Dynamic Checklist with Visible Lines
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 12.0, bottom: 8.0),
                      child: Text("CHECKLIST", style: TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                    ),
                    _buildIOSGroup([
                      for (int index = 0; index < _todoList.length; index++) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _todoList[index].isDone = !_todoList[index].isDone;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _todoList[index].isDone ? CupertinoColors.activeBlue : CupertinoColors.systemGrey3, 
                                      width: 2,
                                    ),
                                    color: _todoList[index].isDone ? CupertinoColors.activeBlue : Colors.transparent,
                                  ),
                                  child: _todoList[index].isDone
                                      ? const Icon(Icons.check, size: 14, color: Colors.white)
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
                                    color: _todoList[index].isDone ? CupertinoColors.secondaryLabel : Colors.black,
                                    decoration: _todoList[index].isDone ? TextDecoration.lineThrough : TextDecoration.none,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Add item...',
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  onSubmitted: (_) {
                                    if (_todoList[index].controller.text.trim().isNotEmpty) {
                                      _addNewTaskRow();
                                    }
                                  },
                                ),
                              ),
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
                        // Explicitly visible checklist item separator
                        if (index < _todoList.length - 1)
                          const Padding(
                            padding: EdgeInsets.only(left: 50.0),
                            child: Divider(height: 1, color: Color(0xFFE5E5EA), thickness: 1),
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

  // --- Recurrence Wheel Picker ---
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