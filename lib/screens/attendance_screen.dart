import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:labtrack_pro/theme/app_theme.dart';
import 'package:labtrack_pro/widgets/glass_card.dart';
import 'package:labtrack_pro/widgets/shift_timeline.dart';

class _AttendanceDayData {
  final String date;
  final DateTime dateTime;
  final String checkIn;
  final String checkOut;
  final String monthYear;
  final List<ShiftData> shifts;

  _AttendanceDayData({
    required this.date,
    required this.dateTime,
    required this.checkIn,
    required this.checkOut,
    required this.monthYear,
    required this.shifts,
  });
}

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _selectedMonth = 'All Months';
  bool _isNewestFirst = true;

  final List<String> _availableMonths = [
    'All Months',
    'August 2024',
    'July 2024',
    'June 2024',
  ];

  final List<_AttendanceDayData> _allRecords = [
    _AttendanceDayData(
      date: 'Tuesday, 13 Aug 2024',
      dateTime: DateTime(2024, 8, 13),
      checkIn: '07:55 AM',
      checkOut: '10:05 AM',
      monthYear: 'August 2024',
      shifts: [
        ShiftData(shiftLabel: 'Shift 1 (07:30 - 09:10)', timeRange: '07:30 - 09:10', activity: 'Teaching', points: 1, isActive: true),
        ShiftData(shiftLabel: 'Shift 2 (09:20 - 11:00)', timeRange: '09:20 - 11:00', activity: 'Kosong', points: 0),
        ShiftData(shiftLabel: 'Shift 3 (11:10 - 12:50)', timeRange: '11:10 - 12:50', activity: 'Kosong', points: 0),
        ShiftData(shiftLabel: 'Shift 4 (13:00 - 14:40)', timeRange: '13:00 - 14:40', activity: 'Kosong', points: 0),
        ShiftData(shiftLabel: 'Shift 5 (14:50 - 16:30)', timeRange: '14:50 - 16:30', activity: 'Kosong', points: 0),
      ],
    ),
    _AttendanceDayData(
      date: 'Thursday, 18 Jul 2024',
      dateTime: DateTime(2024, 7, 18),
      checkIn: '07:28 AM',
      checkOut: '12:55 PM',
      monthYear: 'July 2024',
      shifts: [
        ShiftData(shiftLabel: 'Shift 1 (07:30 - 09:10)', timeRange: '07:30 - 09:10', activity: 'Teaching', points: 1, isActive: true),
        ShiftData(shiftLabel: 'Shift 2 (09:20 - 11:00)', timeRange: '09:20 - 11:00', activity: 'Stand By', points: 1, isActive: true),
        ShiftData(shiftLabel: 'Shift 3 (11:10 - 12:50)', timeRange: '11:10 - 12:50', activity: 'Kosong', points: 0),
        ShiftData(shiftLabel: 'Shift 4 (13:00 - 14:40)', timeRange: '13:00 - 14:40', activity: 'Piket', points: 2, isActive: true),
        ShiftData(shiftLabel: 'Shift 5 (14:50 - 16:30)', timeRange: '14:50 - 16:30', activity: 'Kosong', points: 0),
      ],
    ),
    _AttendanceDayData(
      date: 'Wednesday, 10 Jul 2024',
      dateTime: DateTime(2024, 7, 10),
      checkIn: '07:20 AM',
      checkOut: '11:05 AM',
      monthYear: 'July 2024',
      shifts: [
        ShiftData(shiftLabel: 'Shift 1 (07:30 - 09:10)', timeRange: '07:30 - 09:10', activity: 'Kosong', points: 0),
        ShiftData(shiftLabel: 'Shift 2 (09:20 - 11:00)', timeRange: '09:20 - 11:00', activity: 'Teaching', points: 2, isActive: true),
        ShiftData(shiftLabel: 'Shift 3 (11:10 - 12:50)', timeRange: '11:10 - 12:50', activity: 'Piket', points: 1, isActive: true),
        ShiftData(shiftLabel: 'Shift 4 (13:00 - 14:40)', timeRange: '13:00 - 14:40', activity: 'Stand By', points: 1, isActive: true),
        ShiftData(shiftLabel: 'Shift 5 (14:50 - 16:30)', timeRange: '14:50 - 16:30', activity: 'Kosong', points: 0),
      ],
    ),
    _AttendanceDayData(
      date: 'Friday, 28 Jun 2024',
      dateTime: DateTime(2024, 6, 28),
      checkIn: '07:45 AM',
      checkOut: '04:15 PM',
      monthYear: 'June 2024',
      shifts: [
        ShiftData(shiftLabel: 'Shift 1 (07:30 - 09:10)', timeRange: '07:30 - 09:10', activity: 'Teaching', points: 1, isActive: true),
        ShiftData(shiftLabel: 'Shift 2 (09:20 - 11:00)', timeRange: '09:20 - 11:00', activity: 'Piket', points: 2, isActive: true),
        ShiftData(shiftLabel: 'Shift 3 (11:10 - 12:50)', timeRange: '11:10 - 12:50', activity: 'Stand By', points: 1, isActive: true),
        ShiftData(shiftLabel: 'Shift 4 (13:00 - 14:40)', timeRange: '13:00 - 14:40', activity: 'Teaching', points: 2, isActive: true),
        ShiftData(shiftLabel: 'Shift 5 (14:50 - 16:30)', timeRange: '14:50 - 16:30', activity: 'Kosong', points: 0),
      ],
    ),
    _AttendanceDayData(
      date: 'Monday, 10 Jun 2024',
      dateTime: DateTime(2024, 6, 10),
      checkIn: '07:30 AM',
      checkOut: '02:30 PM',
      monthYear: 'June 2024',
      shifts: [
        ShiftData(shiftLabel: 'Shift 1 (07:30 - 09:10)', timeRange: '07:30 - 09:10', activity: 'Piket', points: 1, isActive: true),
        ShiftData(shiftLabel: 'Shift 2 (09:20 - 11:00)', timeRange: '09:20 - 11:00', activity: 'Teaching', points: 1, isActive: true),
        ShiftData(shiftLabel: 'Shift 3 (11:10 - 12:50)', timeRange: '11:10 - 12:50', activity: 'Kosong', points: 0),
        ShiftData(shiftLabel: 'Shift 4 (13:00 - 14:40)', timeRange: '13:00 - 14:40', activity: 'Stand By', points: 1, isActive: true),
        ShiftData(shiftLabel: 'Shift 5 (14:50 - 16:30)', timeRange: '14:50 - 16:30', activity: 'Kosong', points: 0),
      ],
    ),
  ];

  List<_AttendanceDayData> get _filteredRecords {
    List<_AttendanceDayData> list = _selectedMonth == 'All Months'
        ? List.from(_allRecords)
        : _allRecords.where((r) => r.monthYear == _selectedMonth).toList();

    list.sort((a, b) => _isNewestFirst
        ? b.dateTime.compareTo(a.dateTime)
        : a.dateTime.compareTo(b.dateTime));

    return list;
  }

  void _showSortFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Material(
              color: AppTheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              clipBehavior: Clip.antiAlias,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // BottomSheet Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sort & Filter',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.onSurfaceVariant),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Filter by Month Title
                  Text(
                    'FILTER BY MONTH',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Month Options Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableMonths.map((month) {
                      final isSelected = _selectedMonth == month;
                      return ChoiceChip(
                        label: Text(month),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedMonth = month;
                            });
                            setModalState(() {});
                          }
                        },
                        selectedColor: AppTheme.primary.withValues(alpha: 0.15),
                        backgroundColor: AppTheme.background,
                        labelStyle: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.outlineVariant,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Sort Order Title
                  Text(
                    'SORT ORDER',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Radio Options
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.south,
                      color: _isNewestFirst ? AppTheme.primary : AppTheme.onSurfaceVariant,
                      size: 20,
                    ),
                    title: Text(
                      'Newest First (Terbaru)',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 15,
                        fontWeight: _isNewestFirst ? FontWeight.w600 : FontWeight.w400,
                        color: _isNewestFirst ? AppTheme.primary : AppTheme.onSurface,
                      ),
                    ),
                    trailing: _isNewestFirst
                        ? const Icon(Icons.check_circle, color: AppTheme.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _isNewestFirst = true;
                      });
                      setModalState(() {});
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.north,
                      color: !_isNewestFirst ? AppTheme.primary : AppTheme.onSurfaceVariant,
                      size: 20,
                    ),
                    title: Text(
                      'Oldest First (Terlama)',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 15,
                        fontWeight: !_isNewestFirst ? FontWeight.w600 : FontWeight.w400,
                        color: !_isNewestFirst ? AppTheme.primary : AppTheme.onSurface,
                      ),
                    ),
                    trailing: !_isNewestFirst
                        ? const Icon(Icons.check_circle, color: AppTheme.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _isNewestFirst = false;
                      });
                      setModalState(() {});
                    },
                  ),

                  const SizedBox(height: 20),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Apply',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      );
    },
  );
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;

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
          'Details',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: OutlinedButton.icon(
              onPressed: _showSortFilterBottomSheet,
              icon: const Icon(Icons.tune, size: 16, color: AppTheme.primary),
              label: Text(
                _selectedMonth == 'All Months'
                    ? 'All'
                    : _selectedMonth,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: AppTheme.primary.withValues(alpha: 0.08),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                minimumSize: const Size(0, 32),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.containerPadding),
        child: Column(
          children: [
            // Day sections or Empty State
            if (records.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 48, color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(
                        'No attendance records found for $_selectedMonth',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 16,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...records.map(
                (record) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.sectionGap),
                  child: _buildDaySection(
                    context,
                    date: record.date,
                    checkIn: record.checkIn,
                    checkOut: record.checkOut,
                    shifts: record.shifts,
                  ),
                ),
              ),

            const SizedBox(height: AppTheme.sectionGap),
            // Download Report Button
            SizedBox(
              width: double.infinity,
              height: AppTheme.touchTarget,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.description, size: 24),
                label: Text(
                  'Download Report',
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
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySection(
    BuildContext context, {
    required String date,
    required String checkIn,
    required String checkOut,
    required List<ShiftData> shifts,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: AppTheme.sectionGap),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header + verified badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  date,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.emerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: AppTheme.emerald.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14, color: AppTheme.emerald),
                    const SizedBox(width: 6),
                    Text(
                      'Verified',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                        color: AppTheme.emerald,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Check-in: $checkIn • Check-out: $checkOut',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTheme.elementGap),
          // Shift timeline in glass card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: ShiftTimeline(shifts: shifts),
          ),
        ],
      ),
    );
  }
}
