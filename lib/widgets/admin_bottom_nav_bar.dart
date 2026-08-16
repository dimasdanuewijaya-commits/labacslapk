import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:labtrack_pro/theme/app_theme.dart';

class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AdminBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.7),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.2),
                blurRadius: 0,
                spreadRadius: 0,
                offset: const Offset(0, -1),
              ),
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.04),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      isActive: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.fact_check_outlined,
                      activeIcon: Icons.fact_check_rounded,
                      label: 'Attendance',
                      isActive: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.calendar_month_outlined,
                      activeIcon: Icons.calendar_month_rounded,
                      label: 'Schedule',
                      isActive: currentIndex == 2,
                      onTap: () => onTap(2),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.campaign_outlined,
                      activeIcon: Icons.campaign_rounded,
                      label: 'Announcements',
                      isActive: currentIndex == 3,
                      onTap: () => onTap(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        decoration: isActive
            ? BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? AppTheme.primary
                  : AppTheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                color: isActive
                    ? AppTheme.primary
                    : AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
