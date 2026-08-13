import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labtrack_pro/theme/app_theme.dart';
import 'package:labtrack_pro/screens/admin/admin_dashboard_screen.dart';
import 'package:labtrack_pro/screens/admin/admin_attendance_screen.dart';
import 'package:labtrack_pro/screens/admin/manage_schedule_screen.dart';
import 'package:labtrack_pro/screens/admin/manage_announcements_screen.dart';
import 'package:labtrack_pro/widgets/admin_bottom_nav_bar.dart';

class AdminMainShell extends StatefulWidget {
  const AdminMainShell({super.key});

  @override
  State<AdminMainShell> createState() => _AdminMainShellState();
}

class _AdminMainShellState extends State<AdminMainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminAttendanceScreen(),
    const ManageScheduleScreen(),
    const ManageAnnouncementsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: AdminBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
