import 'package:flutter/cupertino.dart';

/// Shows a standard iOS destructive confirmation dialog. Returns `true` if confirmed.
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
  String deleteLabel = 'Delete',
}) async {
  final result = await showCupertinoDialog<bool>(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context, true),
          child: Text(deleteLabel),
        ),
      ],
    ),
  );
  return result == true;
}
