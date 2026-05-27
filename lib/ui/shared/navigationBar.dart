import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key});

  int _currentIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path == '/calendar') return 1;
    if (path == '/boards') return 2;
    if (path == '/home') return 0;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        return;
      case 1:
        context.go('/calendar');
        return;
      case 2:
        context.go('/boards');
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    return Padding(
      // Slight reduction in horizontal padding to maximize space on smaller screens
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 34),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            // Soft, diffused iOS-style shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            // Slightly stronger blur for that premium frosted look
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                // Combined subtle translucent white with a hairline border
                color: Colors.white.withOpacity(0.65),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem(context, currentIndex, CupertinoIcons.house_fill, CupertinoIcons.house, 0),
                  _navItem(context, currentIndex, CupertinoIcons.calendar_circle_fill, CupertinoIcons.calendar, 1),
                  _navItem(context, currentIndex, CupertinoIcons.square_grid_2x2_fill, CupertinoIcons.square_grid_2x2, 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
      BuildContext context,
      int currentIndex,
      IconData activeIcon,
      IconData inactiveIcon,
      int index,
      ) {
    final bool isSelected = currentIndex == index;

    // Premium iOS color choices
    final Color activeColor = Colors.black.withOpacity(0.9);
    final Color inactiveColor = Colors.black.withOpacity(0.3);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(context, index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Use an animated switcher or clean scale transition for selections
              AnimatedScale(
                scale: isSelected ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  color: isSelected ? activeColor : inactiveColor,
                  size: 26,
                ),
              ),
              const SizedBox(height: 5),
              // Tiny, elegant pill indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                height: 4,
                width: isSelected ? 4 : 0,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}