import 'package:flutter/cupertino.dart';

import '../logic/create_event_formatters.dart';
import '../models/stored_calendar_event.dart';

class CalendarEventList extends StatelessWidget {
  const CalendarEventList({
    super.key,
    required this.occurrences,
    required this.loading,
    required this.selectedDay,
  });

  final List<CalendarEventOccurrence> occurrences;
  final bool loading;
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CupertinoActivityIndicator()),
        ),
      );
    }

    if (occurrences.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'No events on ${CreateEventFormatters.formatDateOnly(selectedDay)}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final occurrence = occurrences[index];
          return _CalendarEventTile(occurrence: occurrence);
        },
        childCount: occurrences.length,
      ),
    );
  }
}

class _CalendarEventTile extends StatelessWidget {
  const _CalendarEventTile({required this.occurrence});

  final CalendarEventOccurrence occurrence;

  @override
  Widget build(BuildContext context) {
    final event = occurrence.event;
    final location = event.location.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3C3C43).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 44,
            margin: const EdgeInsets.only(right: 12, top: 2),
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.subject,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CreateEventFormatters.formatOccurrenceTime(occurrence),
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
