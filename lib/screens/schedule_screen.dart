import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:labtrack_pro/theme/app_theme.dart';
import 'package:labtrack_pro/widgets/glass_card.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDay = 14;

  late DateTime _currentMonth;
  final DateTime _minMonth = DateTime(2026, 5);
  final DateTime _maxMonth = DateTime(2026, 10);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = now.day;
    
    DateTime initial = DateTime(now.year, now.month);
    if (initial.isBefore(_minMonth)) {
      initial = _minMonth;
    } else if (initial.isAfter(_maxMonth)) {
      initial = _maxMonth;
    }
    _currentMonth = initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.containerPadding,
            AppTheme.sectionGap,
            AppTheme.containerPadding,
            100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSemesterHeader(context),
              const SizedBox(height: AppTheme.elementGap),
              _buildCalendar(context),
              const SizedBox(height: AppTheme.sectionGap),
              _buildMySchedule(context),
              const SizedBox(height: AppTheme.sectionGap),
              _buildSwapButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Semester View',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          'ATA 2025/2026',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    
    // Calculate offset for the first day of the month
    final firstDayWeekday = _currentMonth.weekday; // 1 = Mon, 7 = Sun
    final startOffset = firstDayWeekday == 7 ? 0 : firstDayWeekday;
    
    // Calculate previous month overflow
    final lastDayOfPrevMonth = DateTime(_currentMonth.year, _currentMonth.month, 0).day;
    final prevMonthDays = List.generate(startOffset, (i) => lastDayOfPrevMonth - startOffset + i + 1);
    
    // Month days
    final monthDays = List.generate(daysInMonth, (i) => i + 1);
    
    // Next month overflow
    final totalCells = startOffset + daysInMonth;
    final nextMonthCells = totalCells % 7 == 0 ? 0 : 7 - (totalCells % 7);
    final nextMonthDays = List.generate(nextMonthCells, (i) => i + 1);

    return GlassCard(
      borderLeftColor: AppTheme.primary,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left, 
                      size: 20, 
                      color: _currentMonth.isAfter(_minMonth) ? AppTheme.primary : AppTheme.outline.withValues(alpha: 0.3)
                    ),
                    onPressed: _currentMonth.isAfter(_minMonth) ? () {
                      setState(() {
                        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                      });
                    } : null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right, 
                      size: 20, 
                      color: _currentMonth.isBefore(_maxMonth) ? AppTheme.primary : AppTheme.outline.withValues(alpha: 0.3)
                    ),
                    onPressed: _currentMonth.isBefore(_maxMonth) ? () {
                      setState(() {
                        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                      });
                    } : null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Day labels
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: daysOfWeek.map((day) => Center(
              child: Text(
                day,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.outline,
                  letterSpacing: 1,
                ),
              ),
            )).toList(),
          ),
          // Calendar grid
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              // Previous month days
              ...prevMonthDays.map((d) => _buildDayCell(d, isOtherMonth: true)),
              // Current month days
              ...monthDays.map((d) => _buildDayCell(d, isSelected: d == _selectedDay && _currentMonth.month == DateTime.now().month && _currentMonth.year == DateTime.now().year)),
              // Next month days
              ...nextMonthDays.map((d) => _buildDayCell(d, isOtherMonth: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(int day, {bool isSelected = false, bool isOtherMonth = false}) {
    return GestureDetector(
      onTap: isOtherMonth ? null : () => setState(() => _selectedDay = day),
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          decoration: isSelected
              ? BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppTheme.onPrimary
                  : isOtherMonth
                      ? AppTheme.outline.withValues(alpha: 0.4)
                      : AppTheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMySchedule(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Schedule',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        _buildShiftCard(
          context,
          shift: 'Shift 1',
          subject: 'JKL',
          classGroup: '3KB02-A',
          day: 'Thursday',
          time: '08:00 - 10:00',
        ),
        const SizedBox(height: 12),
        _buildShiftCard(
          context,
          shift: 'Shift 2',
          subject: 'MCS',
          classGroup: '2DC02-B',
          day: 'Friday',
          time: '10:00 - 12:00',
        ),
      ],
    );
  }

  Widget _buildShiftCard(
    BuildContext context, {
    required String shift,
    required String subject,
    required String classGroup,
    required String day,
    required String time,
  }) {
    return GlassCard(
      borderLeftColor: AppTheme.primary,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              shift.toUpperCase(),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subject,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.groups, classGroup),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.calendar_today, day),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.schedule, time),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.secondary),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
            color: AppTheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSwapButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppTheme.touchTarget,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/new-swap');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: AppTheme.primary.withValues(alpha: 0.2),
        ),
        child: Text(
          'SWAP',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
