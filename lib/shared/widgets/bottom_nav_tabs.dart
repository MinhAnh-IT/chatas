import 'package:flutter/material.dart';

class BottomNavTab {
  final IconData icon;
  final String label;

  const BottomNavTab({
    required this.icon,
    required this.label,
  });
}

const List<BottomNavTab> bottomNavTabs = [
  BottomNavTab(icon: Icons.chat_bubble_outline, label: 'Chats'),
  BottomNavTab(icon: Icons.people_outline, label: 'Bạn bè'),
  BottomNavTab(icon: Icons.notifications_none, label: 'Thông báo'),
  BottomNavTab(icon: Icons.person, label: 'Cá nhân'),
];
