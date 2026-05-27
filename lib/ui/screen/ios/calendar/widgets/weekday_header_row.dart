import 'package:flutter/cupertino.dart';

import '../logic/calendar_date_utils.dart';

class WeekdayHeaderRow extends StatelessWidget {
  const WeekdayHeaderRow({
    super.key,
    required this.highlightedColumnIndex,
    this.height = 40,
    this.topPadding = 5,
    this.letterSpacing = 0,
  });

  final int highlightedColumnIndex;
  final double height;
  final double topPadding;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    const days = OrgaCalendarDateUtils.weekdayLabels;
    final active = CupertinoColors.activeBlue.resolveFrom(context);
    final tertiary = CupertinoColors.tertiaryLabel.resolveFrom(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(0, topPadding, 0, 0),
      child: SizedBox(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.asMap().entries.map((entry) {
            final isHighlighted = entry.key == highlightedColumnIndex;
            return SizedBox(
              width: OrgaCalendarDateUtils.monthGridRowExtent,
              child: Text(
                entry.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: letterSpacing,
                  color: isHighlighted ? active : tertiary,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
