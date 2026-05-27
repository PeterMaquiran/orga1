import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StatsMenuButton<T> extends StatelessWidget {
  final List<StatsMenuItem<T>> items;
  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  /// Current selected value
  final T? selectedValue;

  /// Triggered when user selects an item
  final ValueChanged<T>? onSelected;

  const StatsMenuButton({
    super.key,
    required this.items,
    this.selectedValue,
    this.onSelected,
    this.icon = CupertinoIcons.chart_bar_alt_fill,
    this.size = 44,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);

    return MenuAnchor(
      alignmentOffset: const Offset(0, 8),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(
          CupertinoColors.systemBackground
              .resolveFrom(context)
              .withOpacity(0.96),
        ),
        surfaceTintColor:
            const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(10),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 6),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      menuChildren: _buildMenuItems(context),
      builder: (context, controller, _) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF3C3C43).withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              onTap?.call();

              controller.isOpen
                  ? controller.close()
                  : controller.open();
            },
            child: Icon(
              icon,
              size: 22,
              color: secondary,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final labelColor = CupertinoColors.label.resolveFrom(context);

    final destructiveColor =
        CupertinoColors.systemRed.resolveFrom(context);

    return items.map((item) {
      if (item.isDivider) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: CupertinoColors.systemGrey4,
          ),
        );
      }

      final color =
          item.isDestructive ? destructiveColor : labelColor;

      final isSelected = item.value == selectedValue;

      return MenuItemButton(
        onPressed: () {
          item.onPressed?.call();

          if (item.value != null) {
            onSelected?.call(item.value as T);
          }
        },
        style: ButtonStyle(
          minimumSize:
              const WidgetStatePropertyAll(Size(220, 44)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16),
          ),
          foregroundColor: WidgetStatePropertyAll(color),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontSize: 16,
              letterSpacing: -0.2,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(item.label),
            ),

            if (isSelected)
              Icon(
                CupertinoIcons.check_mark,
                size: 16,
                color: color,
              )
            else if (item.icon != null)
              Icon(
                item.icon,
                size: 18,
                color: color,
              ),
          ],
        ),
      );
    }).toList();
  }
}

class StatsMenuItem<T> {
  final T? value;
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isDivider;

  const StatsMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.onPressed,
    this.isDestructive = false,
  }) : isDivider = false;

  const StatsMenuItem.divider()
      : value = null,
        label = '',
        icon = null,
        onPressed = null,
        isDestructive = false,
        isDivider = true;
}

class StatsMenuDivider<T> extends StatsMenuItem<T> {
  const StatsMenuDivider() : super.divider();
}