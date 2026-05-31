import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orga1/ui/screen/ios/home/models/habit_form_input.dart';
import 'package:orga1/ui/screen/ios/home/models/habit_goal_type.dart';

import '../../../../shared/emoji.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({
    super.key,
    this.initialInput,
    this.onSaveHabit,
    this.title = 'New Habit',
  });

  final HabitFormInput? initialInput;
  final Future<void> Function(HabitFormInput)? onSaveHabit;
  final String title;

  bool get isEditing => initialInput != null && !initialInput!.isNew;

  static Future<void> open(
    BuildContext context, {
    Future<void> Function(HabitFormInput)? onSaveHabit,
  }) {
    return _showSheet(context, onSaveHabit: onSaveHabit);
  }

  static Future<void> openForEdit(
    BuildContext context, {
    required HabitFormInput initialInput,
    Future<void> Function(HabitFormInput)? onSaveHabit,
  }) {
    return _showSheet(
      context,
      initialInput: initialInput,
      title: 'Edit Habit',
      onSaveHabit: onSaveHabit,
    );
  }

  static Future<void> _showSheet(
    BuildContext context, {
    HabitFormInput? initialInput,
    String title = 'New Habit',
    Future<void> Function(HabitFormInput)? onSaveHabit,
  }) {
    return showCupertinoModalPopup<void>(
      context: context,
      useRootNavigator: true,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          clipBehavior: Clip.antiAlias,
          child: CreateHabitScreen(
            initialInput: initialInput,
            title: title,
            onSaveHabit: onSaveHabit,
          ),
        );
      },
    );
  }

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Core Custom State Configurations
  Color _selectedColor = const Color(0xFF007AFF);
  String _selectedEmoji = '❤️';
  String _selectedFrequency = 'Daily';

  // Goal Targets State
  HabitGoalType _selectedGoalType = HabitGoalType.checkmark;
  int _selectedMinutes = 30;
  double _selectedLiters = 2.0;
  int _selectedCount = 10; // Default lower count to showcase single increments

  final List<String> _daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<bool> _activeDays = [true, true, true, true, true, true, true];

  final List<Color> _habitColors = [
    const Color(0xFFFF3B30),
    const Color(0xFFFF9500),
    const Color(0xFFFFCC00),
    const Color(0xFF34C759),
    const Color(0xFF00C7BE),
    const Color(0xFF30B0C7),
    const Color(0xFF007AFF),
    const Color(0xFF5856D6),
    const Color(0xFFAF52DE),
    const Color(0xFFFF2D55),
    const Color(0xFFE55C75),
    const Color(0xFF1ABC9C),
    const Color(0xFF636E72),
    const Color(0xFF8E8E93),
  ];

  final List<String> _quickEmojis = [
    '❤️', '🏋️‍♂️', '📚', '🛌', '💧', '🧘', '⏱️'
  ];

  @override
  void initState() {
    super.initState();
    _initializeFromInitialInput();
  }

  // Helper calculation to determine smart incremental sizing for counts
  int _getCountStepSize(int currentCount) {
    if (currentCount < 20) return 1;    // Small habits (e.g., 3 books, 8 glasses of water)
    if (currentCount < 100) return 5;   // Medium habits (e.g., 25 pushups, 50 pages)
    return 10;                          // Large targets (e.g., 150 squats, 500 calories)
  }

  void _initializeFromInitialInput() {
    final initial = widget.initialInput;
    if (initial == null) return;

    _titleController.text = initial.title;
    _notesController.text = initial.notes;
    _selectedEmoji = initial.emoji;
    _selectedFrequency = initial.frequency;
    _selectedGoalType = initial.goalType;
    _selectedColor = Color(initial.colorValue);

    for (var i = 0; i < 7; i++) {
      _activeDays[i] = initial.activeDays[i];
    }

    final target = initial.targetValue ?? 0.0;
    if (_selectedGoalType == HabitGoalType.time) {
      _selectedMinutes = target.round().clamp(5, 1440);
    } else if (_selectedGoalType == HabitGoalType.liters) {
      _selectedLiters = target > 0 ? target : 0.5;
    } else if (_selectedGoalType == HabitGoalType.count) {
      _selectedCount = target.round() > 0 ? target.round() : 1;
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

              if (chosenEmoji == '💧' || chosenEmoji == '🥛') {
                _selectedGoalType = HabitGoalType.liters;
              } else if (chosenEmoji == '🏋️‍♂️' || chosenEmoji == '🤸‍♂️') {
                _selectedGoalType = HabitGoalType.count;
                _selectedCount = 30; // Sensible starting count for sports reps
              } else if (chosenEmoji == '📚') {
                _selectedGoalType = HabitGoalType.count;
                _selectedCount = 10; // Sensible target count for pages read
              } else if (chosenEmoji == '🧘' || chosenEmoji == '⏱️') {
                _selectedGoalType = HabitGoalType.time;
              } else {
                _selectedGoalType = HabitGoalType.checkmark;
              }
            });
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _unitForGoalType(HabitGoalType type) => type.defaultUnit;

  HabitFormInput _buildFormInput() {
    double? targetValue;
    if (_selectedGoalType == HabitGoalType.time) {
      targetValue = _selectedMinutes.toDouble();
    } else if (_selectedGoalType == HabitGoalType.liters) {
      targetValue = _selectedLiters;
    } else if (_selectedGoalType == HabitGoalType.count) {
      targetValue = _selectedCount.toDouble();
    }

    final initial = widget.initialInput;

    return HabitFormInput(
      id: initial?.id,
      title: _titleController.text.trim(),
      emoji: _selectedEmoji,
      colorValue: _selectedColor.toARGB32(),
      frequency: _selectedFrequency,
      activeDays: List<bool>.from(_activeDays),
      goalType: _selectedGoalType,
      targetValue: targetValue,
      unit: initial?.unit ?? _unitForGoalType(_selectedGoalType),
      timeText: initial?.timeText ?? '',
      notes: _notesController.text.trim(),
    );
  }

  Future<void> _submitHabit() async {
    if (_titleController.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Title Required'),
          content: const Text('Please add a name for your new routine to get started.'),
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

    final input = _buildFormInput();

    await widget.onSaveHabit?.call(input);
    if (!mounted) return;
    Navigator.of(context).pop(input);
  }

  @override
  Widget build(BuildContext context) {
    const Color iosBackground = Color(0xFFF2F2F7);
    const Color iosCardBackground = CupertinoColors.white;

    return Scaffold(
      backgroundColor: iosBackground,
      appBar: CupertinoNavigationBar(
        backgroundColor: iosBackground.withOpacity(0.8),
        middle: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancel', style: TextStyle(color: CupertinoColors.systemBlue, fontSize: 17)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Save', style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.bold, fontSize: 17)),
          onPressed: _submitHabit,
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [

              // IDENTITY CARD (Title, Color, & Custom Emoji)
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
                      placeholder: 'Name your habit...',
                      placeholderStyle: const TextStyle(color: CupertinoColors.placeholderText),
                      decoration: const BoxDecoration(color: Colors.transparent),
                      clearButtonMode: OverlayVisibilityMode.editing,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 0.5, color: CupertinoColors.separator),
                    ),

                    _buildSubLabel('Theme Color'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _habitColors.length,
                        itemBuilder: (context, index) {
                          final color = _habitColors[index];
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
                        _buildSubLabel('Habit Emoji'),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 24,
                          onPressed: _showEmojiSearchModal,
                          child: Row(
                            children: [
                              Text(
                                'Search All',
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

              _buildSectionHeader('SCHEDULE'),

              // RECURRENCE CONFIGURATION CARD
              Container(
                decoration: BoxDecoration(
                  color: iosCardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
                      child: Row(
                        children: [
                          const Text('Repeat', style: TextStyle(fontSize: 17)),
                          const Spacer(),
                          SizedBox(
                            width: 170,
                            child: CupertinoSegmentedControl<String>(
                              selectedColor: _selectedColor,
                              borderColor: _selectedColor,
                              pressedColor: _selectedColor.withOpacity(0.1),
                              groupValue: _selectedFrequency,
                              children: const {
                                'Daily': Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('Daily', style: TextStyle(fontSize: 13))),
                                'Weekly': Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('Weekly', style: TextStyle(fontSize: 13))),
                              },
                              onValueChanged: (val) => setState(() => _selectedFrequency = val),
                            ),
                          )
                        ],
                      ),
                    ),
                    if (_selectedFrequency == 'Daily') ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Container(height: 0.5, color: CupertinoColors.separator),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_daysOfWeek.length, (index) {
                            final isDayActive = _activeDays[index];
                            return GestureDetector(
                              onTap: () => setState(() => _activeDays[index] = !_activeDays[index]),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                height: 34,
                                width: 34,
                                decoration: BoxDecoration(
                                  color: isDayActive ? _selectedColor : const Color(0xFFE5E5EA),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    _daysOfWeek[index],
                                    style: TextStyle(
                                      color: isDayActive ? Colors.white : CupertinoColors.label,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      )
                    ]
                  ],
                ),
              ),

              _buildSectionHeader('GOAL TARGET'),

              // MULTI-TYPE GOAL SELECTOR CARD WITH ADAPTIVE STEPPING
              Container(
                decoration: BoxDecoration(
                  color: iosCardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Text(_selectedEmoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          const Text('Type', style: TextStyle(fontSize: 17)),
                          const Spacer(),
                          SizedBox(
                            width: 240,
                            child: CupertinoSegmentedControl<HabitGoalType>(
                              selectedColor: _selectedColor,
                              borderColor: _selectedColor,
                              groupValue: _selectedGoalType,
                              children: const {
                                HabitGoalType.checkmark: Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('Check', style: TextStyle(fontSize: 12))),
                                HabitGoalType.time: Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('Time', style: TextStyle(fontSize: 12))),
                                HabitGoalType.liters: Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('Liters', style: TextStyle(fontSize: 12))),
                                HabitGoalType.count: Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('Count', style: TextStyle(fontSize: 12))),
                              },
                              onValueChanged: (val) => setState(() => _selectedGoalType = val),
                            ),
                          )
                        ],
                      ),
                    ),

                    if (_selectedGoalType != HabitGoalType.checkmark) ...[
                      Padding(padding: const EdgeInsets.only(left: 16), child: Container(height: 0.5, color: CupertinoColors.separator)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: Row(
                          children: [
                            const SizedBox(width: 34),
                            Text(
                              _selectedGoalType == HabitGoalType.time
                                  ? 'Daily Duration'
                                  : _selectedGoalType == HabitGoalType.liters
                                  ? 'Water Target'
                                  : 'Target Count',
                              style: const TextStyle(fontSize: 17),
                            ),
                            const Spacer(),

                            // Decrement Button with Dynamic Counts
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  if (_selectedGoalType == HabitGoalType.time) {
                                    _selectedMinutes = _selectedMinutes > 5 ? _selectedMinutes - 5 : 5;
                                  } else if (_selectedGoalType == HabitGoalType.liters) {
                                    _selectedLiters = _selectedLiters > 0.5 ? _selectedLiters - 0.5 : 0.5;
                                  } else if (_selectedGoalType == HabitGoalType.count) {
                                    // Calculate precise step context before pulling back
                                    int step = _getCountStepSize(_selectedCount);
                                    _selectedCount = _selectedCount > step ? _selectedCount - step : 1;
                                  }
                                });
                              },
                              child: const Icon(CupertinoIcons.minus_circle_fill, color: Color(0xFFAEAEB2), size: 28),
                            ),

                            Container(
                              constraints: const BoxConstraints(minWidth: 85),
                              alignment: Alignment.center,
                              child: Text(
                                _selectedGoalType == HabitGoalType.time
                                    ? '$_selectedMinutes min'
                                    : _selectedGoalType == HabitGoalType.liters
                                    ? '${_selectedLiters.toStringAsFixed(1)} L'
                                    : '$_selectedCount',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),

                            // Increment Button with Dynamic Context Steps
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  if (_selectedGoalType == HabitGoalType.time) {
                                    _selectedMinutes += 5;
                                  } else if (_selectedGoalType == HabitGoalType.liters) {
                                    _selectedLiters += 0.5;
                                  } else if (_selectedGoalType == HabitGoalType.count) {
                                    // Scale steps larger automatically as target scales up
                                    _selectedCount += _getCountStepSize(_selectedCount);
                                  }
                                });
                              },
                              child: Icon(CupertinoIcons.plus_circle_fill, color: _selectedColor, size: 28),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              _buildSectionHeader('NOTES'),

              Container(
                decoration: BoxDecoration(
                  color: iosCardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: CupertinoTextField(
                  controller: _notesController,
                  placeholder: 'Add notes or motivation quotes...',
                  placeholderStyle: const TextStyle(color: CupertinoColors.placeholderText),
                  decoration: const BoxDecoration(color: Colors.transparent),
                  maxLines: 4,
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
// --- UPDATED SUB-MODAL COMPONENT (Emoji Native) ---
class EmojiPickerSearchSheet extends StatefulWidget {
  final Map<String, String> emojisDictionary;
  final Color themeColor;
  final String initialSelectedEmoji;
  final ValueChanged<String> onEmojiSelected;

  const EmojiPickerSearchSheet({
    super.key,
    required this.emojisDictionary,
    required this.themeColor,
    required this.initialSelectedEmoji,
    required this.onEmojiSelected,
  });

  @override
  State<EmojiPickerSearchSheet> createState() => _EmojiPickerSearchSheetState();
}

class _EmojiPickerSearchSheetState extends State<EmojiPickerSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredEmojis = [];
  late String _currentSelectedEmoji;

  @override
  void initState() {
    super.initState();
    _currentSelectedEmoji = widget.initialSelectedEmoji;
    _filteredEmojis = widget.emojisDictionary.values.toSet().toList();
  }

  void _onSearchChanged(String query) {
    final cleanQuery = query.toLowerCase().trim();
    if (cleanQuery.isEmpty) {
      setState(() {
        _filteredEmojis = widget.emojisDictionary.values.toSet().toList();
      });
      return;
    }

    final List<String> matches = [];
    widget.emojisDictionary.forEach((keywords, emoji) {
      if (keywords.contains(cleanQuery)) {
        matches.add(emoji);
      }
    });

    setState(() {
      _filteredEmojis = matches.toSet().toList(); // Avoid duplicate icons in display
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFFF2F2F7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Sheet Header Navigation UI
            CupertinoNavigationBar(
              backgroundColor: const Color(0xFFF2F2F7),
              automaticallyImplyLeading: false,
              middle: const Text('Select Emoji', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('Done', style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.bold, fontSize: 17)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Native IOS Style Search Field
            Padding(
              padding: const EdgeInsets.all(16),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Search tags (e.g. fitness, wellness...)',
                onChanged: _onSearchChanged,
              ),
            ),

            // Grid View of Results
            Expanded(
              child: _filteredEmojis.isEmpty
                  ? const Center(
                child: Text(
                  'No matching emojis found',
                  style: TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 16),
                ),
              )
                  : GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: _filteredEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = _filteredEmojis[index];
                  final isSelected = emoji == _currentSelectedEmoji;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _currentSelectedEmoji = emoji);
                      widget.onEmojiSelected(emoji);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      decoration: BoxDecoration(
                        color: isSelected ? widget.themeColor.withOpacity(0.15) : CupertinoColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: widget.themeColor, width: 2) : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}




