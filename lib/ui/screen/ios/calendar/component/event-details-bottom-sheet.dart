import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../logic/create_event_formatters.dart';
import '../models/stored_calendar_event.dart';
import '../../../../shared/delete_confirmation.dart';
import 'create-event.dart';

class EventDetailsBottomSheet extends StatelessWidget {
  const EventDetailsBottomSheet({
    super.key,
    required this.occurrence,
    required this.onChanged,
    required this.onDelete,
  });

  final CalendarEventOccurrence occurrence;
  final Future<void> Function() onChanged;
  final Future<void> Function(String eventId) onDelete;

  static void open(
    BuildContext context, {
    required CalendarEventOccurrence occurrence,
    required Future<void> Function() onChanged,
    required Future<void> Function(String eventId) onDelete,
  }) {
    showCupertinoModalPopup<void>(
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
          child: EventDetailsBottomSheet(
            occurrence: occurrence,
            onChanged: onChanged,
            onDelete: onDelete,
          ),
        );
      },
    );
  }

  StoredCalendarEvent get _event => occurrence.event;

  Future<void> _openEdit(BuildContext context) async {
    Navigator.pop(context);
    CreateEventBottomSheet.openForEdit(
      context,
      event: _event,
      onSaved: onChanged,
      onDeleted: onChanged,
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await confirmDelete(
      context,
      title: 'Delete Event?',
      message: 'This event will be permanently removed.',
    );
    if (!confirmed || !context.mounted) return;

    await onDelete(_event.id);
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final event = _event;
    final location = event.location.trim();
    final body = event.body?.trim() ?? '';
    final repeatSummary = CreateEventFormatters.formatRecurrenceSummary(event);
    final whenLine = CreateEventFormatters.formatOccurrenceTime(occurrence);
    final dateLine = CreateEventFormatters.formatDateOnly(occurrence.day);

    return Container(
      color: const Color(0xFFF2F2F7),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.redAccent, fontSize: 17),
            ),
          ),
          title: const Text(
            'Event',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 17,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () => _openEdit(context),
              child: const Text(
                'Edit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(
              event.subject,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20),
            _DetailGroup(
              children: [
                _DetailRow(
                  icon: CupertinoIcons.calendar,
                  label: dateLine,
                  subtitle: whenLine,
                ),
                if (location.isNotEmpty)
                  _DetailRow(
                    icon: CupertinoIcons.location_solid,
                    label: location,
                  ),
                if (repeatSummary.isNotEmpty)
                  _DetailRow(
                    icon: CupertinoIcons.repeat,
                    label: repeatSummary,
                  ),
              ],
            ),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 20),
              _DetailGroup(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      body,
                      style: const TextStyle(fontSize: 16, height: 1.35),
                    ),
                  ),
                ],
              ),
            ],
            if (event.checklist.isNotEmpty) ...[
              const SizedBox(height: 20),
              _DetailGroup(
                children: [
                  for (var i = 0; i < event.checklist.length; i++) ...[
                    if (i > 0)
                      const Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Divider(height: 1, color: Color(0xFFE5E5EA)),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            event.checklist[i].isDone
                                ? CupertinoIcons.checkmark_circle_fill
                                : CupertinoIcons.circle,
                            size: 22,
                            color: event.checklist[i].isDone
                                ? CupertinoColors.activeGreen
                                : CupertinoColors.systemGrey3,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              event.checklist[i].text,
                              style: TextStyle(
                                fontSize: 16,
                                decoration: event.checklist[i].isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: event.checklist[i].isDone
                                    ? CupertinoColors.secondaryLabel
                                    : CupertinoColors.label,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                onPressed: () => _confirmDelete(context),
                child: const Text(
                  'Delete Event',
                  style: TextStyle(
                    color: CupertinoColors.destructiveRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailGroup extends StatelessWidget {
  const _DetailGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.only(left: 52),
                child: Divider(height: 1, color: Color(0xFFE5E5EA)),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: CupertinoColors.activeBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 16, height: 1.25),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
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
