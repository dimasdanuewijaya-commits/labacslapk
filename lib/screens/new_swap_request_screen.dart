import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:labtrack_pro/theme/app_theme.dart';

class NewSwapRequestScreen extends StatefulWidget {
  const NewSwapRequestScreen({super.key});

  @override
  State<NewSwapRequestScreen> createState() => _NewSwapRequestScreenState();
}

class _NewSwapRequestScreenState extends State<NewSwapRequestScreen> {
  int _selectedSchedule = 0;
  int _selectedAssistant = 0;
  final _reasonController = TextEditingController();

  final _schedules = [
    {'course': 'JKL - 2DC02-B', 'date': 'Oct 24, 2023', 'shift': 'SHIFT 1 08:00 AM - 10:00 AM'},
    {'course': 'JKD - 3KB02-A', 'date': 'Oct 27, 2023', 'shift': '10:00 AM - 06:00 PM'},
  ];

  final _assistants = [
    'Sarah J.',
    'David K.',
    'Elena R.',
    'Marcus L.',
    'Amir H.',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

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
          'New Swap Request',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.surfaceContainerHigh,
              child: const Icon(Icons.person, size: 18, color: AppTheme.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.containerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Select Schedule
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '1',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Your Schedule',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Schedule cards
            ..._schedules.asMap().entries.map((entry) {
              final index = entry.key;
              final schedule = entry.value;
              final isSelected = index == _selectedSchedule;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSchedule = index),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withValues(alpha: 0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule['course']!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppTheme.primary : AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          schedule['date']!,
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (index == 1)
                              Icon(Icons.schedule, size: 14, color: AppTheme.onSurfaceVariant),
                            if (index == 1) const SizedBox(width: 4),
                            Text(
                              schedule['shift']!,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: AppTheme.sectionGap),
            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 20, color: AppTheme.outline),
                  const SizedBox(width: 12),
                  Text(
                    'Search lab assistants...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Assistant list
            ..._assistants.asMap().entries.map((entry) {
              final index = entry.key;
              final name = entry.value;
              final isSelected = index == _selectedAssistant;
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() => _selectedAssistant = index);
                      Navigator.of(context).pushNamed('/select-shift');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary.withValues(alpha: 0.05)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: AppTheme.primary.withValues(alpha: 0.2))
                            : null,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.surfaceContainerHigh,
                            child: const Icon(Icons.person, size: 20, color: AppTheme.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppTheme.outline),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                  if (index < _assistants.length - 1)
                    Divider(
                      height: 1,
                      color: AppTheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                ],
              );
            }),
            const SizedBox(height: AppTheme.sectionGap),
            // Reason field
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _reasonController,
                maxLines: 3,
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Explain why you need the swap...',
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.outline),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.sectionGap),
            // Send Request button
            SizedBox(
              width: double.infinity,
              height: AppTheme.touchTarget,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Swap request sent!')),
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.send, size: 20),
                label: Text(
                  'Send Request',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: AppTheme.primary.withValues(alpha: 0.2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${_assistants[_selectedAssistant]} will receive a notification to approve or decline.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
