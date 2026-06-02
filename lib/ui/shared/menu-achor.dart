import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StatsMenuButton<T> extends StatefulWidget {
  final List<StatsMenuItem<T>> items;
  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  /// Single-value selection (one checkmark in the whole menu).
  final T? selectedValue;

  /// Multi-group selection (one checkmark per group).
  final Map<Object, Object>? selectedByGroup;

  /// Triggered when user selects an item with a non-null [StatsMenuItem.value].
  final ValueChanged<T>? onSelected;

  const StatsMenuButton({
    super.key,
    required this.items,
    this.selectedValue,
    this.selectedByGroup,
    this.onSelected,
    this.icon = CupertinoIcons.chart_bar_alt_fill,
    this.size = 44,
    this.onTap,
  });

  @override
  State<StatsMenuButton<T>> createState() => _StatsMenuButtonState<T>();
}

class _StatsMenuButtonState<T> extends State<StatsMenuButton<T>> {
  final MenuController _menuController = MenuController();

  bool _isItemSelected(StatsMenuItem<T> item) {
    if (item.selectionGroup != null) {
      return widget.selectedByGroup?[item.selectionGroup] ==
          item.selectionValue;
    }
    return item.isSelected || item.value == widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);

    return MenuAnchor(
      controller: _menuController,
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
          width: widget.size,
          height: widget.size,
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
              widget.onTap?.call();
              setState(() {});

              if (_menuController.isOpen) {
                _menuController.close();
              } else {
                _menuController.open();
              }
            },
            child: Icon(
              widget.icon,
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
    final checkColor = CupertinoColors.activeBlue.resolveFrom(context);

    final destructiveColor =
        CupertinoColors.systemRed.resolveFrom(context);

    return widget.items.map((item) {
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

      final isSelected = _isItemSelected(item);

      return MenuItemButton(
        onPressed: () {
          item.onPressed?.call();

          if (item.value != null) {
            widget.onSelected?.call(item.value as T);
          }

          _menuController.close();
          setState(() {});
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
            SizedBox(
              width: 22,
              child: isSelected
                  ? Icon(
                      CupertinoIcons.check_mark,
                      size: 18,
                      color: checkColor,
                    )
                  : null,
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
  final bool isSelected;

  /// Group key for [StatsMenuButton.selectedByGroup] (multiple checkmarks).
  final Object? selectionGroup;

  /// Value within [selectionGroup] that should show the checkmark.
  final Object? selectionValue;

  const StatsMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.onPressed,
    this.isDestructive = false,
    this.isSelected = false,
    this.selectionGroup,
    this.selectionValue,
  }) : isDivider = false;

  const StatsMenuItem.divider()
      : value = null,
        label = '',
        icon = null,
        onPressed = null,
        isDestructive = false,
        isSelected = false,
        selectionGroup = null,
        selectionValue = null,
        isDivider = true;
}

class StatsMenuDivider<T> extends StatsMenuItem<T> {
  const StatsMenuDivider() : super.divider();
}
