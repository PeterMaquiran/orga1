import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

/// Home large-title style row (used with the shrinking header on [HomeScreen]).
class appBar extends StatelessWidget {
  final String title;

  const appBar({super.key, required this.title,});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.37,
            height: 1.1,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {},
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5.resolveFrom(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.person_fill,
              size: 20,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ),
      ],
    );
  }
}

class OrgaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OrgaAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AppBar(
          backgroundColor: Colors.white.withValues(alpha: 0.72),
          elevation: 0,
          title: const Text(
            'Orga',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          actions: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.add, color: Colors.black87),
              onPressed: () => _handleAddTask(context),
            ),
            PopupMenuButton<String>(
              icon: const Icon(CupertinoIcons.ellipsis, color: Colors.black87),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              offset: const Offset(0, 50),
              onSelected: (value) => _handleMenuSelection(value),
              itemBuilder: (context) => [
                _buildMenuItem('Edit Layout', CupertinoIcons.pencil),
                _buildMenuItem('Settings', CupertinoIcons.settings),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String title, IconData icon) {
    return PopupMenuItem(
      value: title,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  void _handleAddTask(BuildContext context) {
    // Logic for adding a new task or habit
  }

  void _handleMenuSelection(String value) {
    // Logic for menu options
  }
}
