import 'package:flutter/material.dart';
import 'bottom_nav_tabs.dart';

class CommonBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CommonBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: bottomNavTabs
          .map(
            (tab) =>
                BottomNavigationBarItem(icon: Icon(tab.icon), label: tab.label),
          )
          .toList(),
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    );
  }
}
