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
    // October 2024 starts on Tuesday (index 2), 31 days
    final prevMonthDays = [29, 30]; // Sep overflow
    final monthDays = List.generate(31, (i) => i + 1);
    final nextMonthDays = [1, 2]; // Nov overflow

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
                'October 2024',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20, color: AppTheme.primary),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20, color: AppTheme.primary),
                    onPressed: () {},
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
              ...monthDays.map((d) => _buildDayCell(d, isSelected: d == _selectedDay)),
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
