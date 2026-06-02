import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orga1/ui/screen/ios/home/component/create-habit.dart';
import 'package:orga1/ui/screen/ios/home/models/quick_log_habit.dart';
import 'package:orga1/ui/shared/menu-achor.dart';

enum _QuickLogMenuAction { statistics, edit, delete }

class QuickLogBottomSheet extends StatefulWidget {
  final QuickLogHabit habit;
  final DateTime logDate;
  final Function(double updatedValue, String notes) onSave;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onStatistics;
  final Future<void> Function(QuickLogHabit updatedHabit)? onEditHabit;

  const QuickLogBottomSheet({
    super.key,
    required this.habit,
    required this.logDate,
    required this.onSave,
    this.onEdit,
    this.onDelete,
    this.onStatistics,
    this.onEditHabit,
  });

  @override
  State<QuickLogBottomSheet> createState() => _QuickLogBottomSheetState();
}

class _QuickLogBottomSheetState extends State<QuickLogBottomSheet> {
  late QuickLogHabit _habit;
  late TextEditingController _valueController;
  final TextEditingController _notesController = TextEditingController();
  late double _currentValue;
  late bool _isCheckmarkType;

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
    _currentValue = _habit.currentValue;
    _isCheckmarkType = _habit.goalType == 'checkmark';
    _valueController = TextEditingController(text: _formatValue(_currentValue));
  }

  String _formatValue(double val) {
    return val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
  }

  DateTime get _logDayNormalized => DateTime(
        widget.logDate.year,
        widget.logDate.month,
        widget.logDate.day,
      );

  bool get _isLoggingToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _logDayNormalized == today;
  }

  String get _logDayLabel {
    if (_isLoggingToday) return 'Today';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final d = _logDayNormalized;
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  String _statusSubtitle(double targetValue, String unit) {
    if (_isCheckmarkType) {
      return _currentValue >= 1.0
          ? 'Completed · $_logDayLabel'
          : 'Not completed · $_logDayLabel';
    }
    final unitSuffix = unit.isNotEmpty ? ' $unit' : '';
    return '${_formatValue(_currentValue)} / ${_formatValue(targetValue)}$unitSuffix · $_logDayLabel';
  }

  String get _saveButtonLabel =>
      _isLoggingToday ? 'Save Progress' : 'Save for $_logDayLabel';

  bool get _showMenu =>
      onEdit != null || onDelete != null || onStatistics != null;

  VoidCallback? get onEdit => widget.onEdit;
  VoidCallback? get onDelete => widget.onDelete;
  VoidCallback? get onStatistics => widget.onStatistics;

  List<StatsMenuItem<_QuickLogMenuAction>> _menuItems() {
    return [
      StatsMenuItem(
        value: _QuickLogMenuAction.statistics,
        label: 'Statistics',
        icon: CupertinoIcons.chart_bar_alt_fill,
        onPressed: onStatistics,
      ),
      StatsMenuItem(
        value: _QuickLogMenuAction.edit,
        label: 'Edit Habit',
        icon: CupertinoIcons.pencil,
        onPressed: _handleEdit,
      ),
      if (onDelete != null) const StatsMenuItem.divider(),
      if (onDelete != null)
        StatsMenuItem(
          value: _QuickLogMenuAction.delete,
          label: 'Delete Habit',
          icon: CupertinoIcons.delete,
          isDestructive: true,
          onPressed: _handleDelete,
        ),
    ];
  }

  void _handleEdit() {
    if (widget.onEdit != null) {
      widget.onEdit!();
      return;
    }
    _openEditHabitBottomSheet();
  }

  Future<void> _openEditHabitBottomSheet() async {
    await CreateHabitScreen.openForEdit(
      context,
      initialInput: _habit.toFormInput(),
      onSaveHabit: (input) async {
        final next = _habit.applyFormInput(input);
        setState(() {
          _habit = next;
          _isCheckmarkType = next.isCheckmark;
        });
        await widget.onEditHabit?.call(next);
      },
      onDeleteHabit: widget.onDelete != null
          ? (id) async {
              widget.onDelete!();
            }
          : null,
    );
  }

  void _handleDelete() => widget.onDelete?.call();

  // Uses our smart adaptive step sizing rule
  double _getStepSize() {
    final type = _habit.goalType;
    if (type == 'liters') return 0.5;
    if (type == 'time') return 5.0;

    // Scaling steps for counts
    if (_currentValue < 20) return 1.0;
    if (_currentValue < 100) return 5.0;
    return 10.0;
  }

  void _adjustValue(bool isIncrement) {
    if (_isCheckmarkType) return; // Prevent adjustment loop on checkmarks

    double step = _getStepSize();
    setState(() {
      if (isIncrement) {
        _currentValue += step;
      } else {
        // Drop the value, but stop it right at 0.0 so it never goes negative
        _currentValue = _currentValue - step;
        if (_currentValue < 0.0) _currentValue = 0.0;
      }
      _valueController.text = _formatValue(_currentValue);
    });
  }

  void _toggleCheckmark() {
    setState(() {
      // Toggle back and forth between 0.0 (incomplete) and 1.0 (completed)
      _currentValue = _currentValue >= 1.0 ? 0.0 : 1.0;
    });
  }

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = _habit.color;
    final String unit = _habit.unit;
    final mq = MediaQuery.of(context);
    final double targetValue = _habit.targetValue;
    final bool isCompleted =
        targetValue > 0 ? _currentValue >= targetValue : _currentValue >= 1.0;
    final double progressPct = targetValue > 0
        ? (_currentValue / targetValue).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: max(mq.viewInsets.bottom, mq.viewPadding.bottom) + 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle bar
          Center(
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey4,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Profile Info row
          Row(
            children: [
              Text(_habit.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _habit.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // const SizedBox(height: 4),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 8,
                    //     vertical: 3,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: themeColor.withOpacity(0.12),
                    //     borderRadius: BorderRadius.circular(6),
                    //   ),
                    //   child: Text(
                    //     _logDayLabel,
                    //     style: TextStyle(
                    //       fontSize: 12,
                    //       fontWeight: FontWeight.w600,
                    //       color: themeColor,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 2),
                    // Text(
                    //   _statusSubtitle(targetValue, unit),
                    //   style: const TextStyle(
                    //     fontSize: 13,
                    //     color: CupertinoColors.secondaryLabel,
                    //   ),
                    // ),
                  ],
                ),
              ),
              if (_showMenu)
                StatsMenuButton<_QuickLogMenuAction>(
                  icon: CupertinoIcons.ellipsis,
                  size: 36,
                  items: _menuItems(),
                ),
            ],
          ),
          if (!_isCheckmarkType) ...[
            const SizedBox(height: 24),
            Stack(
              children: [
                // Track bar background
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // Colored active status indicator fill fill
                FractionallySizedBox(
                  widthFactor: progressPct,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // Core Input Display Area (Adapts based on layout requirement)
          _isCheckmarkType
              ? GestureDetector(
            onTap: _toggleCheckmark,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isCompleted ? themeColor : CupertinoColors.white,
                borderRadius: BorderRadius.circular(14),
                border: !isCompleted
                    ? Border.all(color: CupertinoColors.systemGrey4, width: 1)
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCompleted
                        ? CupertinoIcons.checkmark_seal_fill
                        : CupertinoIcons.circle,
                    color: isCompleted ? CupertinoColors.white : CupertinoColors.systemGrey,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isCompleted
                        ? (_isLoggingToday
                            ? 'Completed'
                            : 'Completed on $_logDayLabel')
                        : (_isLoggingToday
                            ? 'Mark as Completed'
                            : 'Mark $_logDayLabel Complete'),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? CupertinoColors.white : CupertinoColors.label,
                    ),
                  ),
                ],
              ),
            ),
          )
              : Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _adjustValue(false),
                  child: const Icon(CupertinoIcons.minus_circle_fill, color: Color(0xFFAEAEB2), size: 36),
                ),
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
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: themeColor),
                          decoration: const BoxDecoration(color: Colors.transparent),
                          onChanged: (val) {
                            double? parsed = double.tryParse(val);
                            if (parsed != null) _currentValue = parsed;
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(unit, style: const TextStyle(fontSize: 18, color: CupertinoColors.secondaryLabel)),
                    ],
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _adjustValue(true),
                  child: Icon(CupertinoIcons.plus_circle_fill, color: themeColor, size: 36),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Optional Quick Session Notes Card
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: CupertinoTextField(
              controller: _notesController,
              placeholder: 'Add note (e.g., hit a personal record!)...',
              placeholderStyle: const TextStyle(color: CupertinoColors.placeholderText),
              decoration: const BoxDecoration(color: Colors.transparent),
              maxLines: 2,
              style: const TextStyle(fontSize: 15),
            ),
          ),

          // Save Bar Integration
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: themeColor,
              borderRadius: BorderRadius.circular(14),
              onPressed: () {
                widget.onSave(_currentValue, _notesController.text.trim());
                Navigator.pop(context);
              },
              child: Text(
                _saveButtonLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}