import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Mock List of available habits the user could log an event for
  final List<Map<String, dynamic>> _myHabits = [
    {'id': '1', 'title': 'Drink Clean Water', 'emoji': '💧', 'color': const Color(0xFF007AFF), 'goalType': 'liters', 'unit': 'L', 'defaultStep': 0.5},
    {'id': '2', 'title': 'Morning Meditation', 'emoji': '🧘', 'color': const Color(0xFF5856D6), 'goalType': 'time', 'unit': 'min', 'defaultStep': 5.0},
    {'id': '3', 'title': 'Push-ups Challenge', 'emoji': '🏋️‍♂️', 'color': const Color(0xFFFF9500), 'goalType': 'count', 'unit': 'reps', 'defaultStep': 10.0},
    {'id': '4', 'title': 'Take Core Vitamins', 'emoji': '💊', 'color': const Color(0xFF34C759), 'goalType': 'checkmark', 'unit': '', 'defaultStep': 1.0},
  ];

  // Selected State Configuration
  late Map<String, dynamic> _selectedHabit;
  DateTime _eventTimestamp = DateTime.now();
  bool _checkmarkCompleted = true; // State for pure checkbox habits

  @override
  void initState() {
    super.initState();
    // Default to the first habit in the list
    _selectedHabit = _myHabits.first;
    _updateLogValueDisplay(_selectedHabit['defaultStep'].toString());
  }

  void _updateLogValueDisplay(String value) {
    if (_selectedHabit['goalType'] != 'checkmark') {
      // Cleans decimal formatting if it's an exact integer value
      double parsed = double.tryParse(value) ?? 0.0;
      _valueController.text = parsed % 1 == 0 ? parsed.toInt().toString() : parsed.toString();
    }
  }

  // Handles dynamic state adjustment when switching habits from the picker row
  void _changeActiveHabit(Map<String, dynamic> habit) {
    setState(() {
      _selectedHabit = habit;
      _checkmarkCompleted = true;
      _updateLogValueDisplay(habit['defaultStep'].toString());
    });
  }

  // Adjust values using the minus/plus button arrays
  void _adjustNumericValue(bool isIncrement) {
    double currentVal = double.tryParse(_valueController.text) ?? 0.0;
    double step = _selectedHabit['defaultStep'];

    // Adaptive stepping for standard counts based on our scaling rule
    if (_selectedHabit['goalType'] == 'count') {
      if (currentVal < 20) step = 1.0;
      else if (currentVal < 100) step = 5.0;
      else step = 10.0;
    }

    double newVal = isIncrement ? currentVal + step : currentVal - step;
    if (newVal < 0) newVal = 0.0;

    setState(() {
      _updateLogValueDisplay(newVal.toString());
    });
  }

  // Opens an elegant native iOS bottom-sheet calendar wheel picker
  void _showDatePickerModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoDatePicker(
            initialDateTime: _eventTimestamp,
            mode: CupertinoDatePickerMode.dateAndTime,
            maximumDate: DateTime.now(), // Prevents logging items into the future
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() => _eventTimestamp = newDateTime);
            },
          ),
        ),
      ),
    );
  }

  void _submitEvent() {
    // Collect progress value based on metric configuration
    dynamic loggedValue;
    if (_selectedHabit['goalType'] == 'checkmark') {
      loggedValue = _checkmarkCompleted ? 1.0 : 0.0;
    } else {
      loggedValue = double.tryParse(_valueController.text) ?? 0.0;
      if (loggedValue <= 0) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Invalid Amount'),
            content: const Text('Please enter an amount greater than 0 to save this activity.'),
            actions: [
              CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))
            ],
          ),
        );
        return;
      }
    }

    final Map<String, dynamic> newEventLog = {
      'habitId': _selectedHabit['id'],
      'habitTitle': _selectedHabit['title'],
      'goalType': _selectedHabit['goalType'],
      'loggedValue': loggedValue,
      'timestamp': _eventTimestamp.toIso8601String(),
      'notes': _notesController.text.trim(),
    };

    debugPrint('Manually Created Event Log entry: $newEventLog');
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color iosBackground = Color(0xFFF2F2F7);
    const Color iosCardBackground = CupertinoColors.white;
    final Color themeColor = _selectedHabit['color'];

    return Scaffold(
      backgroundColor: iosBackground,
      appBar: CupertinoNavigationBar(
        backgroundColor: iosBackground.withOpacity(0.8),
        middle: const Text('Add Entry', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancel', style: TextStyle(color: CupertinoColors.systemBlue, fontSize: 17)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text('Add', style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.bold, fontSize: 17)),
          onPressed: _submitEvent,
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [

              _buildSectionHeader('SELECT HABIT ROUTINE'),

              // 1. SELECT HABIT CONTAINER CAROUSEL HORIZONTAL LIST
              SizedBox(
                height: 75,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _myHabits.length,
                  itemBuilder: (context, index) {
                    final habit = _myHabits[index];
                    final bool isCurrent = _selectedHabit['id'] == habit['id'];
                    final Color cardTheme = habit['color'];

                    return GestureDetector(
                      onTap: () => _changeActiveHabit(habit),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isCurrent ? cardTheme : iosCardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: isCurrent ? null : Border.all(color: const Color(0xFFE5E5EA), width: 1),
                        ),
                        child: Row(
                          children: [
                            Text(habit['emoji'], style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Text(
                              habit['title'],
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isCurrent ? CupertinoColors.white : CupertinoColors.label
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              _buildSectionHeader('LOG PROGRESS METRIC'),

              // 2. ENTRY LOG VALUE FIELD CARD CONTAINER
              Container(
                decoration: BoxDecoration(
                  color: iosCardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: _selectedHabit['goalType'] == 'checkmark'
                    ? Row(
                  children: [
                    Text(_selectedHabit['emoji'], style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    const Text('Mark as Completed', style: TextStyle(fontSize: 17)),
                    const Spacer(),
                    CupertinoSwitch(
                      activeColor: themeColor,
                      value: _checkmarkCompleted,
                      onChanged: (bool val) => setState(() => _checkmarkCompleted = val),
                    )
                  ],
                )
                    : Row(
                  children: [
                    // Decrement stepper control
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _adjustNumericValue(false),
                      child: const Icon(CupertinoIcons.minus_circle_fill, color: Color(0xFFAEAEB2), size: 30),
                    ),

                    // Input box supporting direct text keys override alongside suffix strings
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          IntrinsicWidth(
                            child: CupertinoTextField(
                              controller: _valueController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: themeColor),
                              decoration: const BoxDecoration(color: Colors.transparent),
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                              _selectedHabit['unit'],
                              style: const TextStyle(fontSize: 16, color: CupertinoColors.secondaryLabel, fontWeight: FontWeight.w500)
                          ),
                        ],
                      ),
                    ),

                    // Increment stepper control
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _adjustNumericValue(true),
                      child: Icon(CupertinoIcons.plus_circle_fill, color: themeColor, size: 30),
                    ),
                  ],
                ),
              ),

              _buildSectionHeader('TIME STAMP'),

              // 3. DATE AND TIME WHEEL MODAL TRIGGER CARD BLOCK
              Container(
                decoration: BoxDecoration(
                  color: iosCardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  onPressed: _showDatePickerModal,
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.calendar_badge_plus, color: CupertinoColors.inactiveGray, size: 22),
                      const SizedBox(width: 12),
                      const Text('Occurred At', style: TextStyle(fontSize: 17, color: CupertinoColors.label)),
                      const Spacer(),
                      Text(
                        _formatDateTimeDisplay(_eventTimestamp),
                        style: TextStyle(fontSize: 16, color: themeColor, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 4),
                      const Icon(CupertinoIcons.chevron_forward, color: CupertinoColors.lightBackgroundGray, size: 16)
                    ],
                  ),
                ),
              ),

              _buildSectionHeader('EVENT NOTES'),

              // 4. MEMO/NOTES LOG FIELDS ARRAY
              Container(
                decoration: BoxDecoration(
                  color: iosCardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: CupertinoTextField(
                  controller: _notesController,
                  placeholder: 'Add performance notes (e.g., felt great today!)...',
                  placeholderStyle: const TextStyle(color: CupertinoColors.placeholderText),
                  decoration: const BoxDecoration(color: Colors.transparent),
                  maxLines: 3,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel, fontWeight: FontWeight.w500, letterSpacing: -0.05),
      ),
    );
  }

  // Formatter mapping a clean visual layout for dates (e.g., May 25, 14:30)
  String _formatDateTimeDisplay(DateTime dt) {
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String hour = dt.hour.toString().padLeft(2, '0');
    String min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, $hour:$min';
  }
}