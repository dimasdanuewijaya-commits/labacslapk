import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:labtrack_pro/theme/app_theme.dart';
import 'package:labtrack_pro/widgets/glass_card.dart';
import 'package:labtrack_pro/widgets/stat_card.dart';
import 'package:labtrack_pro/widgets/attendance_entry.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [Color(0xFFE8F0FE), AppTheme.background],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.containerPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppTheme.sectionGap),
                _buildStatsGrid(context),
                const SizedBox(height: AppTheme.elementGap),
                _buildSecondaryStats(context),
                const SizedBox(height: AppTheme.elementGap),
                _buildSalaryCard(context),
                const SizedBox(height: AppTheme.sectionGap),
                _buildAttendanceHistory(context),
                const SizedBox(height: AppTheme.sectionGap),
                _buildAnnouncements(context),
                const SizedBox(height: 100), // Bottom nav space
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning,',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Dimas Danue Wijaya',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Of this month',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.outline,
                    ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            // Notification bell
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 20),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/notifications');
                    },
                    color: AppTheme.onSurface,
                    padding: EdgeInsets.zero,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.surface, width: 1),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Avatar
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryContainer,
                  width: 2,
                ),
              ),
              child: const CircleAvatar(
                backgroundColor: AppTheme.surfaceContainerHigh,
                child: Icon(Icons.person, size: 20, color: AppTheme.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppTheme.elementGap,
      mainAxisSpacing: AppTheme.elementGap,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          label: 'Present',
          value: '7',
          subtitle: 'Days',
          icon: Icons.schedule,
          iconColor: AppTheme.primary,
        ),
        StatCard(
          label: 'Late',
          value: '5',
          subtitle: 'Days',
          icon: Icons.error_outline,
          iconColor: AppTheme.error,
        ),
        StatCard(
          label: 'Absent',
          value: '1',
          subtitle: 'Days',
          icon: Icons.person_off_outlined,
          iconColor: AppTheme.error,
        ),
        StatCard(
          label: 'Hours',
          value: '27.7',
          icon: Icons.pie_chart,
          iconColor: AppTheme.tertiary,
          subtitleWidget: Row(
            children: [
              Icon(Icons.arrow_upward, size: 12, color: AppTheme.emerald),
              const SizedBox(width: 2),
              Text(
                '2%',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.emerald,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryStats(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppTheme.elementGap,
      mainAxisSpacing: AppTheme.elementGap,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          label: 'Leaderboard',
          value: '#3',
          subtitle: 'Rank',
          icon: Icons.leaderboard,
          iconColor: AppTheme.primary,
        ),
        StatCard(
          label: 'Points',
          value: '40.5',
          icon: Icons.grade,
          iconColor: AppTheme.tertiary,
          subtitleWidget: Row(
            children: [
              Icon(Icons.trending_up, size: 12, color: AppTheme.emerald),
              const SizedBox(width: 2),
              Text(
                'High',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.emerald,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderLeftColor: AppTheme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimated Salary on This Month',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rp 412.000',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceHistory(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Recent Attendance',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () {
                // Navigate to attendance tab
              },
              child: Text(
                'View History',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.primary,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const AttendanceEntry(
          title: 'JKL - 3KB02-A',
          date: 'Today, 12 Aug 2024',
          timeRange: '07:55 - 10:05',
          status: 'Present',
        ),
        const SizedBox(height: 12),
        const AttendanceEntry(
          title: 'MCS - 2DC02-B',
          date: 'Friday, 09 Aug 2024',
          timeRange: '10:15 - 12:00',
          status: 'Late',
        ),
        const SizedBox(height: 12),
        const AttendanceEntry(
          title: 'Piket',
          date: 'Thursday, 08 Aug 2024',
          timeRange: '08:00 - 10:00',
          status: 'Present',
        ),
      ],
    );
  }

  Widget _buildAnnouncements(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Announcements',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {},
              child: Text(
                'View All',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.primary,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusXxl),
            border: Border.all(color: AppTheme.primaryContainer),
          ),
          padding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.campaign, size: 20, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'NEW UPDATE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lab Safety Protocol v2.4',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please review the updated safety guidelines for the Bio-Metrics lab before your next shift.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                right: -16,
                bottom: -16,
                child: Icon(
                  Icons.science,
                  size: 120,
                  color: Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
