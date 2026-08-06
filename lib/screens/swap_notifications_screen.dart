import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:labtrack_pro/theme/app_theme.dart';
import 'package:labtrack_pro/widgets/glass_card.dart';

class SwapNotificationsScreen extends StatelessWidget {
  const SwapNotificationsScreen({super.key});

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
        centerTitle: false,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppTheme.primary),
                onPressed: () {},
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.containerPadding),
        child: Column(
          children: [
            _buildSwapRequest(
              context,
              name: 'Dimas Danue Wijaya',
              subtitle: 'wants to swap with you',
              theirShift: 'Shift 1',
              theirTime: '08:00 AM - 04:00 PM',
              theirClass: '2DC02B- JKL',
              myShift: 'Shift 2',
              myTime: '06:00 AM - 02:00 PM',
              myClass: '3KB01C - JKD',
              reason: "I have a doctor's appointment and need to shift my hours.",
            ),
            const SizedBox(height: 16),
            _buildSwapRequest(
              context,
              name: 'Nicky Tirta',
              subtitle: 'wants to swap with you',
              theirShift: 'Shift 5',
              theirTime: '06:00 AM - 02:00 PM',
              theirClass: '3KB02B - MCS',
              myShift: 'Shift 3',
              myTime: '02:00 PM - 10:00 PM',
              myClass: '3KB01A - FPGA',
              reason: 'Family emergency requires me to be home in the morning.',
            ),
            const SizedBox(height: AppTheme.sectionGap),
            // Status messages
            _buildStatusMessage(
              context,
              icon: Icons.check_circle_outline,
              iconColor: AppTheme.emerald,
              message: 'Your swap request with Elena Rodriguez was Approved by Lab Manager.',
              time: '2 days ago',
              highlightName: 'Elena Rodriguez',
              highlightStatus: 'Approved',
            ),
            const SizedBox(height: 12),
            _buildStatusMessage(
              context,
              icon: Icons.schedule,
              iconColor: AppTheme.outline,
              message: 'New schedule published for December Week 1.',
              time: '3 days ago',
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSwapRequest(
    BuildContext context, {
    required String name,
    required String subtitle,
    required String theirShift,
    required String theirTime,
    required String theirClass,
    required String myShift,
    required String myTime,
    required String myClass,
    required String reason,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Person info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.surfaceContainerHigh,
                child: const Icon(Icons.person, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Their shift
          _buildShiftSection(context, 'THEIR SHIFT', theirShift, theirTime, theirClass),
          const SizedBox(height: 12),
          // Swap icon
          Center(
            child: Icon(Icons.swap_vert, size: 24, color: AppTheme.primary),
          ),
          const SizedBox(height: 12),
          // My shift
          _buildShiftSection(context, 'MY SHIFT', myShift, myTime, myClass),
          const SizedBox(height: 16),
          // Reason card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: 'Reason: ',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: reason),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Arrow icon
          Icon(Icons.subdirectory_arrow_right, size: 16, color: AppTheme.primary),
          const SizedBox(height: 12),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.onPrimary,
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Accept Request',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    minimumSize: const Size(0, 40),
                    side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Decline',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShiftSection(
    BuildContext context,
    String header,
    String shift,
    String time,
    String classInfo,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 14, color: AppTheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(shift, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurface)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.schedule, size: 14, color: AppTheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(time, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurface)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.science_outlined, size: 14, color: AppTheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(classInfo, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurface)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusMessage(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String message,
    required String time,
    String? highlightName,
    String? highlightStatus,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (highlightName != null && highlightStatus != null)
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurface),
                    children: [
                      const TextSpan(text: 'Your swap request with '),
                      TextSpan(
                        text: highlightName,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: ' was '),
                      TextSpan(
                        text: highlightStatus,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                      const TextSpan(text: ' by Lab Manager.'),
                    ],
                  ),
                )
              else
                Text(
                  message,
                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurface),
                ),
              const SizedBox(height: 4),
              Text(
                time,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: AppTheme.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
