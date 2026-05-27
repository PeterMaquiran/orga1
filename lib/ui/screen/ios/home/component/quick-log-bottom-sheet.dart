import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuickLogBottomSheet extends StatefulWidget {
  final Map<String, dynamic> habit;
  final Function(double updatedValue, String notes) onSave;

  const QuickLogBottomSheet({
    super.key,
    required this.habit,
    required this.onSave,
  });

  @override
  State<QuickLogBottomSheet> createState() => _QuickLogBottomSheetState();
}

class _QuickLogBottomSheetState extends State<QuickLogBottomSheet> {
  late TextEditingController _valueController;
  final TextEditingController _notesController = TextEditingController();
  late double _currentValue;
  late bool _isCheckmarkType;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.habit['currentValue'] ?? 0.0;
    _isCheckmarkType = widget.habit['goalType'] == 'checkmark';
    _valueController = TextEditingController(text: _formatValue(_currentValue));
  }

  String _formatValue(double val) {
    return val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
  }

  // Uses our smart adaptive step sizing rule
  double _getStepSize() {
    String type = widget.habit['goalType'];
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
    final Color themeColor = widget.habit['color'];
    final String unit = widget.habit['unit'] ?? '';
    final bool isCompleted = _currentValue >= 1.0;
    final mq = MediaQuery.of(context);

        // Progress calculation safely clamped between 0.0 and 1.0
    final double progressPct = widget.habit['targetValue'] > 0 ? (_currentValue / widget.habit['targetValue']).clamp(0.0, 1.0) : 0.0;

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
              Text(widget.habit['emoji'], style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit['title'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _isCheckmarkType
                          ? (isCompleted ? "Status: Done today!" : "Status: Pending")
                          : "Target: ${_formatValue(widget.habit['targetValue'])} $unit",
                      style: const TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel),
                    ),
                  ],
                ),
              ),

              // 1. EDIT ACTION ICON BUTTON
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                onPressed: () => {},
                child: Icon(
                  CupertinoIcons.pencil_circle_fill,
                  color: themeColor,
                  size: 36,
                ),
              ),

              // 2. STATISTICS ACTION ICON BUTTON
              CupertinoButton(
                padding: const EdgeInsets.only(left: 6, right: 2),
                onPressed: () => {},
                child: Icon(
                  CupertinoIcons.chart_bar_alt_fill,
                  color: themeColor.withOpacity(0.85),
                  size: 34,
                ),
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
                    isCompleted ? "Completed" : "Mark as Completed",
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
              child: const Text(
                'Save Progress',

                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}