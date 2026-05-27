import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../shared/emoji.dart';
import '../../home/component/create-habit.dart'; // Adjust path if necessary

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

enum EventAlertType { none, atTime, mins5, mins15, mins30, hour1, day1 }

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Style & Identity Configurations
  Color _selectedColor = const Color(0xFF007AFF);
  String _selectedEmoji = '📅';

  // Date & Time States
  bool _isAllDay = false;
  DateTime _startDate = DateTime.now().add(const Duration(hours: 1)).subtract(Duration(minutes: DateTime.now().minute));
  DateTime _endDate = DateTime.now().add(const Duration(hours: 2)).subtract(Duration(minutes: DateTime.now().minute));

  // Configuration States
  EventAlertType _selectedAlert = EventAlertType.none;
  String _selectedAvailability = 'Busy';

  final List<Color> _eventColors = [
    const Color(0xFFFF3B30), // Work / Urgent
    const Color(0xFFFF9500), // Personal
    const Color(0xFFFFCC00), // Family
    const Color(0xFF34C759), // Health / Sport
    const Color(0xFF00C7BE), // Design
    const Color(0xFF30B0C7), // Tech
    const Color(0xFF007AFF), // Default Blue
    const Color(0xFF5856D6), // Deep Projects
    const Color(0xFFAF52DE), // Study
    const Color(0xFFFF2D55), // Entertainment
    const Color(0xFF636E72), // Sidebar / Casual
    const Color(0xFF8E8E93), // System / Reminders
  ];

  final List<String> _quickEmojis = [
    '📅', '💻', '🏋️‍♂️', '🏥', '🍕', '✈️', '🎓', '💼'
  ];

  String _getAlertLabel(EventAlertType alert) {
    switch (alert) {
      case EventAlertType.none: return 'None';
      case EventAlertType.atTime: return 'At time of event';
      case EventAlertType.mins5: return '5 minutes before';
      case EventAlertType.mins15: return '15 minutes before';
      case EventAlertType.mins30: return '30 minutes before';
      case EventAlertType.hour1: return '1 hour before';
      case EventAlertType.day1: return '1 day before';
    }
  }

  void _showEmojiSearchModal() {
    showCupertinoModalPopup(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return EmojiPickerSearchSheet(
          emojisDictionary: allEmojisDictionary,
          themeColor: _selectedColor,
          initialSelectedEmoji: _selectedEmoji,
          onEmojiSelected: (String chosenEmoji) {
            setState(() {
              _selectedEmoji = chosenEmoji;
              if (!_quickEmojis.contains(chosenEmoji)) {
                _quickEmojis.insert(0, chosenEmoji);
              }

              // Smart Color Hints based on selected Event Emoji context
              if (chosenEmoji == '💻' || chosenEmoji == '🚀') {
                _selectedColor = const Color(0xFF30B0C7); // Tech Cyan
              } else if (chosenEmoji == '🏋️‍♂️' || chosenEmoji == '🏃‍♂️') {
                _selectedColor = const Color(0xFF34C759); // Health Green
              } else if (chosenEmoji == '🏥' || chosenEmoji == '🩺') {
                _selectedColor = const Color(0xFFFF3B30); // Medical Red
              } else if (chosenEmoji == '💼' || chosenEmoji == '👔') {
                _selectedColor = const Color(0xFF5856D6); // Work Indigo
              }
            });
          },
        );
      },
    );
  }

  void _showDatePickerModal(bool isStartDate) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: _isAllDay ? CupertinoDatePickerMode.date : CupertinoDatePickerMode.dateAndTime,
                initialDateTime: isStartDate ? _startDate : _endDate,
                use24hFormat: true,
                onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    if (isStartDate) {
                      _startDate = newDate;
                      if (_endDate.isBefore(_startDate)) {
                        _endDate = _startDate.add(const Duration(hours: 1));
                      }
                    } else {
                      _endDate = newDate;
                      if (_endDate.isBefore(_startDate)) {
                        _startDate = _endDate.subtract(const Duration(hours: 1));
                      }
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlertSelector() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Event Alert'),
        actions: EventAlertType.values.map((type) {
          return CupertinoActionSheetAction(
            child: Text(_getAlertLabel(type)),
            onPressed: () {
              setState(() => _selectedAlert = type);
              Navigator.pop(context);
            },
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitEvent() {
    if (_titleController.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Title Required'),
          content: const Text('Please provide a title or summary description for this agenda item.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
      return;
    }

    final Map<String, dynamic> newEvent = {
      'title': _titleController.text.trim(),
      'location': _locationController.text.trim(),
      'color': _selectedColor.value,
      'emoji': _selectedEmoji,
      'isAllDay': _isAllDay,
      'startTimestamp': _startDate.toIso8601String(),
      'endTimestamp': _endDate.toIso8601String(),
      'alertType': _selectedAlert.name,
      'availability': _selectedAvailability,
      'notes': _notesController.text.trim(),
    };

    debugPrint('Saving Agenda Event: $newEvent');
    Navigator.of(context).pop(newEvent);
  }

  @override
  Widget build(BuildContext context) {
    const Color iosBackground = Color(0xFFF2F2F7);
    const Color iosCardBackground = CupertinoColors.white;

    return Scaffold(
      backgroundColor: iosBackground,
      appBar: CupertinoNavigationBar(
        backgroundColor: iosBackground.withOpacity(0.8),
        middle: const Text('New Event', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancel', style: TextStyle(color: CupertinoColors.systemBlue, fontSize: 17)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Add', style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.bold, fontSize: 17)),
          onPressed: _submitEvent,
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [

              // IDENTITY CARD (Title, Location, Color & Emoji)
              Container(
                decoration: BoxDecoration(
                  color: iosCardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CupertinoTextField(
                      controller: _titleController,
                      placeholder: 'Title',
                      placeholderStyle: const TextStyle(color: CupertinoColors.placeholderText),
                      decoration: const BoxDecoration(color: Colors.transparent),
                      clearButtonMode: OverlayVisibilityMode.editing,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 0.5, color: CupertinoColors.separator),
                    ),
                    CupertinoTextField(
                      controller: _locationController,
                      placeholder: 'Location or Video Call link',
                      placeholderStyle: const TextStyle(color: CupertinoColors.placeholderText),
                      decoration: const BoxDecoration(color: Colors.transparent),
                      clearButtonMode: OverlayVisibilityMode.editing,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 0.5, color: CupertinoColors.separator),
                    ),

                    _buildSubLabel('Calendar Display Tag Color'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _eventColors.length,
                        itemBuilder: (context, index) {
                          final color = _eventColors[index];
                          final isSelected = _selectedColor == color;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = color),
                            child: Container(
                              margin: const EdgeInsets.only(right: 14),
                              width: 34,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                              child: isSelected
                                  ? const Icon(CupertinoIcons.checkmark, color: Colors.white, size: 16)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 0.5, color: CupertinoColors.separator),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSubLabel('Event Visual Identifier'),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 24,
                          onPressed: _showEmojiSearchModal,
                          child: Row(
                            children: [
                              Text(
                                'Browse',
                                style: TextStyle(fontSize: 14, color: _selectedColor, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 4),
                              Icon(CupertinoIcons.search, size: 16, color: _selectedColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _quickEmojis.length,
                        itemBuilder: (context, index) {
                          final emoji = _quickEmojis[index];
                          final isSelected = _selectedEmoji == emoji;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedEmoji = emoji),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.only(right: 12),
                              width: 44,
                              decoration: BoxDecoration(
                                color: isSelected ? _selectedColor.withOpacity(0.12) : const Color(0xFFF2F2F7),
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected ? Border.all(color: _selectedColor, width: 1.5) : null,
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),

              _buildSectionHeader('TIMING MATRIX'),

              // DATE & TIME CARD
              Container(
                decoration: BoxDecoration(
                  color: iosCardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
                      child: Row(
                        children: [
                          const Text('All-day Event', style: TextStyle(fontSize: 17)),
                          const Spacer(),
                          CupertinoSwitch(
                            activeColor: _selectedColor,
                            value: _isAllDay,
                            onChanged: (val) => setState(() => _isAllDay = val),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Container(height: 0.5, color: CupertinoColors.separator),
                    ),

                    // Starts Row
                    GestureDetector(
                      onTap: () => _showDatePickerModal(true),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Starts', style: TextStyle(fontSize: 17)),
                            Text(
                              _isAllDay
                                  ? '${_startDate.day}/${_startDate.month}/${_startDate.year}'
                                  : '${_startDate.day}/${_startDate.month}/${_startDate.year} ${_startDate.hour.toString().padLeft(2, '0')}:${_startDate.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 17, color: _selectedColor, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Container(height: 0.5, color: CupertinoColors.separator),
                    ),

                    // Ends Row
                    GestureDetector(
                      onTap: () => _showDatePickerModal(false),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Ends', style: TextStyle(fontSize: 17)),
                            Text(
                              _isAllDay
                                  ? '${_endDate.day}/${_endDate.month}/${_endDate.year}'
                                  : '${_endDate.day}/${_endDate.month}/${_endDate.year} ${_endDate.hour.toString().padLeft(2, '0')}:${_endDate.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 17, color: _selectedColor, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildSectionHeader('AVAILABILITY & SYSTEMS'),

              // SYSTEM ALERTS & ACCESSIBILITY CONFIGURATION
              Container(
                decoration: BoxDecoration(
                  color: iosCardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showAlertSelector,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Text('Alert', style: TextStyle(fontSize: 17)),
                            const Spacer(),
                            Text(
                              _getAlertLabel(_selectedAlert),
                              style: const TextStyle(fontSize: 17, color: CupertinoColors.secondaryLabel),
                            ),
                            const SizedBox(width: 6),
                            const Icon(CupertinoIcons.chevron_forward, size: 16, color: CupertinoColors.systemGrey3),
                          ],
                        ),
                      ),
                    ),
                    Padding(padding: const EdgeInsets.only(left: 16), child: Container(height: 0.5, color: CupertinoColors.separator)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
                      child: Row(
                        children: [
                          const Text('Show As', style: TextStyle(fontSize: 17)),
                          const Spacer(),
                          SizedBox(
                            width: 170,
                            child: CupertinoSegmentedControl<String>(
                              selectedColor: _selectedColor,
                              borderColor: _selectedColor,
                              pressedColor: _selectedColor.withOpacity(0.1),
                              groupValue: _selectedAvailability,
                              children: const {
                                'Busy': Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('Busy', style: TextStyle(fontSize: 13))),
                                'Free': Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('Free', style: TextStyle(fontSize: 13))),
                              },
                              onValueChanged: (val) => setState(() => _selectedAvailability = val),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              _buildSectionHeader('AGENDA REMARKS & CHECKPOINTS'),

// INTEGRATED CHECKLIST & DESCRIPTION WRAPPER
              Container(
                decoration: BoxDecoration(
                  color: iosCardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Text Field for overall rich text summary description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: CupertinoTextField(
                        controller: _notesController,
                        placeholder: 'Add description notes, context summaries or links...',
                        placeholderStyle: const TextStyle(color: CupertinoColors.placeholderText),
                        decoration: const BoxDecoration(color: Colors.transparent),
                        maxLines: 3,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    if (_checklistItems.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Container(height: 0.5, color: CupertinoColors.separator),
                      ),

                      // 2. Dynamic Interactive Checkpoint Rows
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _checklistItems.length,
                        itemBuilder: (context, index) {
                          final item = _checklistItems[index];
                          return Dismissible(
                            key: Key('check_$index${item['text']}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: CupertinoColors.systemRed,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.all(4),
                              child: const Icon(CupertinoIcons.delete, color: Colors.white, size: 20),
                            ),
                            onDismissed: (_) {
                              setState(() => _checklistItems.removeAt(index));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: CupertinoColors.extraLightBackgroundGray, width: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        item['done'] = !item['done'];
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(right: 12),
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: item['done'] ? _selectedColor : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: item['done'] ? _selectedColor : CupertinoColors.systemGrey3,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: item['done']
                                          ? const Icon(CupertinoIcons.checkmark, size: 14, color: Colors.white)
                                          : null,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      item['text'],
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: item['done'] ? CupertinoColors.secondaryLabel : CupertinoColors.label,
                                        decoration: item['done'] ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],

                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Container(height: 0.5, color: CupertinoColors.separator),
                    ),

                    // 3. Apple Notes-Style Inline Sub-task Creator Row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.add_circled_solid, color: _selectedColor, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CupertinoTextField(
                              controller: _newItemController,
                              placeholder: 'Add a sub-task item...',
                              placeholderStyle: const TextStyle(color: CupertinoColors.placeholderText, fontSize: 15),
                              decoration: const BoxDecoration(color: Colors.transparent),
                              style: const TextStyle(fontSize: 15),
                              onSubmitted: (_) => _addChecklistItem(),
                            ),
                          ),
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            onPressed: _addChecklistItem,
                            child: Text(
                              'Add',
                              style: TextStyle(color: _selectedColor, fontWeight: FontWeight(600), fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
// Under your existing text controllers:
  final List<Map<String, dynamic>> _checklistItems = [];
  final TextEditingController _newItemController = TextEditingController();
  
  void _addChecklistItem() {
    final text = _newItemController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _checklistItems.add({
          'text': text,
          'done': false,
        });
        _newItemController.clear();
      });
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel, fontWeight: FontWeight.w500, letterSpacing: -0.05),
      ),
    );
  }

  Widget _buildSubLabel(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel.withOpacity(0.8), fontWeight: FontWeight.w600, letterSpacing: -0.01),
    );
  }
}