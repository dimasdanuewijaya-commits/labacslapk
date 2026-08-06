import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:labtrack_pro/theme/app_theme.dart';
import 'package:labtrack_pro/widgets/glass_card.dart';

import 'package:labtrack_pro/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.containerPadding,
          vertical: AppTheme.sectionGap,
        ),
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: AppTheme.sectionGap),
            _buildSemesterStats(context),
            const SizedBox(height: AppTheme.sectionGap),
            _buildMenuList(context),
            const SizedBox(height: 16),
            _buildLogoutButton(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final user = AuthService().currentUser;
    final displayName = user?.displayName ?? 'Dimas Danue Wijaya';
    final userEmail = user?.email ?? 'dimas.danue@lab.pro';

    return Column(
      children: [
        // Static Avatar with gradient ring
        _StaticAvatar(),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          userEmail,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'RFID: 1029384756',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: AppTheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterStats(BuildContext context) {
    return GlassCard(
      borderRadius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL PER SEMESTER',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(height: 12),
          // 3x2 grid
          Row(
            children: [
              Expanded(child: _buildStatItem(context, 'Present', '56')),
              Expanded(child: _buildStatItem(context, 'Late', '5')),
              Expanded(child: _buildStatItem(context, 'Absent', '1')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem(context, 'Hours', '87.7')),
              Expanded(child: _buildStatItem(context, 'Points', '105')),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Salary',
                  'Rp 1.250.000',
                  valueColor: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppTheme.secondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuList(BuildContext context) {
    final menuItems = [
      {'icon': Icons.person_outline, 'label': 'Personal Information'},
      {'icon': Icons.bar_chart, 'label': 'Work Statistics'},
      {'icon': Icons.security, 'label': 'Account Security'},
      {'icon': Icons.notifications_outlined, 'label': 'Notification Settings'},
      {'icon': Icons.help_outline, 'label': 'Help & Support'},
    ];

    return GlassCard(
      borderRadius: 12,
      padding: EdgeInsets.zero,
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == menuItems.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          size: 20,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item['label'] as String,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppTheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: AppTheme.outlineVariant.withValues(alpha: 0.3),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GlassCard(
      borderRadius: 12,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () async {
          await AuthService().signOut();
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, color: AppTheme.error),
              const SizedBox(width: 8),
              Text(
                'Logout',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaticAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Avatar with gradient border
        Container(
          width: 96,
          height: 96,
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.tertiaryFixed],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.surface, width: 4),
            ),
            child: const CircleAvatar(
              backgroundColor: AppTheme.surfaceContainerHigh,
              child: Icon(Icons.person, size: 36, color: AppTheme.primary),
            ),
          ),
        ),
        // Verified badge
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                size: 16,
                color: AppTheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

