import 'package:flutter/material.dart';
import 'package:labtrack_pro/screens/home_screen.dart';
import 'package:labtrack_pro/screens/attendance_screen.dart';
import 'package:labtrack_pro/screens/schedule_screen.dart';
import 'package:labtrack_pro/screens/profile_screen.dart';
import 'package:labtrack_pro/widgets/bottom_nav_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    AttendanceScreen(),
    ScheduleScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
