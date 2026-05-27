import 'package:flutter/material.dart';

class HabitCard extends StatelessWidget {
  final int index;
  final String title;
  final String emoji;
  final String goalType; // 'checkmark', 'time', 'liters', or 'count'
  final double currentValue;
  final double targetValue;
  final String unit;
  final String timeText;
  final Color color;
  final bool isSelected;
  final VoidCallback onActionPressed; // Callback for tapping Check or Log Button

  const HabitCard({
    super.key,
    required this.index,
    required this.title,
    required this.emoji,
    required this.goalType,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.timeText,
    required this.color,
    required this.isSelected,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Progress calculation safely clamped between 0.0 and 1.0
    final double progressPct = targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
    final bool isCompleted = progressPct >= 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withOpacity(1),
        borderRadius: BorderRadius.circular(20),
        // border: Border.all(
        //   color: isSelected ? color.withOpacity(0.8) : Colors.white.withOpacity(0.2),
        //   width: isSelected ? 2.0 : 0.5,
        // ),
        boxShadow: isSelected
            ? [BoxShadow(color: color.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4))]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MAIN ROW: Icon, Text details, and Action Controls
          Row(
            children: [
              // Habit Icon Circle
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),

              // Habit Text Data Stack
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque, // Ensures the empty space between/around text is clickable
                  onTap: () {
                    //this.onActionPressed();
                    debugPrint('Habit clicked: $title');
                    // Handle your tap action here (e.g., open edit screen, toggle progress, show modal)
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        goalType == 'checkmark'
                            ? (isCompleted ? "Completed today!" : "Pending action")
                            : (() {
                                // Calculate percentage safely
                                final double percentage = targetValue > 0 
                                    ? (currentValue / targetValue) * 100 
                                    : 0.0;
                                
                                // Format percentage to a whole number or 1 decimal place (e.g., 85%)
                                String percentageText = "(${percentage.toStringAsFixed(0)}%)";
                                //if(percentageText == "(100%)") {
                                  percentageText = "";
                                //}

                                return "Goal: ${_formatValue(currentValue)} / ${_formatValue(targetValue)} $unit $percentageText";
                              })(),
                        style: TextStyle(
                          fontSize: 13,
                          color: isCompleted ? Colors.green.shade700 : Colors.black45,
                          fontWeight: isCompleted ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Time Label Indicator
              // Text(
              //   timeText,
              //   style: const TextStyle(fontSize: 12, color: Colors.black38),
              // ),
              // const SizedBox(width: 12),

              // DYNAMIC ACTION BUTTON ACTION BLOCK
              if (goalType == 'checkmark')
              // Checkbox variant button
              InkWell(
                  onTap: onActionPressed,
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isCompleted ? Colors.green.shade400 : Colors.black26,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                )
              else
              // Quantity log variant button pill
                InkWell(
                  onTap: onActionPressed,
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isCompleted ?  Colors.green.shade400 : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted ? Icons.check_outlined : Icons.add,
                          size: 24,
                          color: isCompleted ?  Colors.white : color,
                          ),
                        
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // INTEGRATED LINEAR PROGRESS SLIDER BAR (Hidden for simple checkmarks)
          // if (goalType != 'checkmark' && !isCompleted) ...[
          //   const SizedBox(height: 14),
          //   Stack(
          //     children: [
          //       // Track bar background
          //       Container(
          //         height: 6,
          //         width: double.infinity,
          //         decoration: BoxDecoration(
          //           color: Colors.black.withOpacity(0.06),
          //           borderRadius: BorderRadius.circular(3),
          //         ),
          //       ),
          //       // Colored active status indicator fill fill
          //       FractionallySizedBox(
          //         widthFactor: progressPct,
          //         child: Container(
          //           height: 6,
          //           decoration: BoxDecoration(
          //             color: color,
          //             borderRadius: BorderRadius.circular(3),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          //],
        ],
      ),
    );
  }

  // Helper logic cleaner slicing up trailing fractional points (.0 metrics)
  String _formatValue(double val) {
    return val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
  }
}