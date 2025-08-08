import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final bool showBadge;

  const NotificationBadge({
    super.key,
    required this.child,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBadge) {
      return child;
    }

    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;

        if (state is NotificationLoaded) {
          unreadCount = state.unreadCount;
        }

        return Badge(
          label: Text(
            unreadCount > 99 ? '99+' : unreadCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          isLabelVisible: unreadCount > 0,
          backgroundColor: Colors.red,
          child: child,
        );
      },
    );
  }
}

class NotificationIcon extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;
  final Color? color;

  const NotificationIcon({
    super.key,
    this.onTap,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationBadge(
      child: IconButton(
        icon: Icon(
          Icons.notifications,
          size: size,
          color: color,
        ),
        onPressed: onTap,
      ),
    );
  }
}
