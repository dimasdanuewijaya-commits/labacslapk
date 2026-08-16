import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:labtrack_pro/theme/app_theme.dart';
import 'package:labtrack_pro/widgets/glass_card.dart';
import 'package:labtrack_pro/widgets/shift_timeline.dart';

class _AttendanceDayData {
  final String date;
  final DateTime dateTime;
  final String checkIn;
  final String checkOut;
  final String monthYear;
  final String userName;
  final List<ShiftData> shifts;

  _AttendanceDayData({
    required this.date,
    required this.dateTime,
    required this.checkIn,
    required this.checkOut,
    required this.monthYear,
    required this.userName,
    required this.shifts,
  });
}

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  String _selectedMonth = 'All Months';
  String _selectedAssistant = 'All';
  bool _isNewestFirst = true;

  final List<String> _availableMonths = ['All Months'];
  List<Map<String, dynamic>> _assistants = [];

  bool _isLoading = true;
  String? _errorMessage;
  List<_AttendanceDayData> _allRecords = [];

  String get _baseUrl {
    if (kIsWeb) return 'https://api.himatekkomug.my.id';
    if (Platform.isAndroid) return 'https://api.himatekkomug.my.id';
    return 'https://api.himatekkomug.my.id';
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        setState(() {
          _errorMessage = 'Session expired.';
          _isLoading = false;
        });
        return;
      }

      // Fetch users list
      final usersResponse = await http.get(
        Uri.parse('$_baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Map<int, String> userNameMap = {};
      if (usersResponse.statusCode == 200) {
        final usersList = jsonDecode(usersResponse.body) as List;
        _assistants = usersList
            .where((u) => u['role'] != 'admin')
            .map((u) => {'id': u['id'], 'name': u['name']})
            .toList()
            .cast<Map<String, dynamic>>();
        for (var u in usersList) {
          userNameMap[u['id']] = u['name'] ?? 'Unknown';
        }
      }

      // Fetch ALL attendance (no user_id filter)
      final response = await http.get(
        Uri.parse('$_baseUrl/attendance/?limit=200'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final attendances = data['records'] as List? ?? [];

        final List<_AttendanceDayData> fetchedRecords = [];

        for (var att in attendances) {
          final dateStr = att['date'] ?? '';
          final userId = att['user_id'];
          final userName = userNameMap[userId] ?? 'Unknown';

          String monthYear = 'Unknown Month';
          try {
            final parts = dateStr.split(' ');
            if (parts.length >= 3) {
              monthYear = '${parts[parts.length - 2]} ${parts[parts.length - 1]}';
              if (!_availableMonths.contains(monthYear)) {
                _availableMonths.add(monthYear);
              }
            }
          } catch (e) {}

          final List<ShiftData> mappedShifts = [];
          if (att['shifts'] != null) {
            for (var shift in att['shifts']) {
              final isActive = (shift['points'] ?? 0) > 0;
              mappedShifts.add(ShiftData(
                shiftLabel: shift['shift_label'] ?? 'Unknown Shift',
                timeRange: shift['time_range'] ?? '',
                activity: shift['activity'] ?? 'Kosong',
                points: shift['points'] ?? 0,
                isActive: isActive,
              ));
            }
          }

          fetchedRecords.add(_AttendanceDayData(
            date: dateStr,
            dateTime: DateTime.now(),
            checkIn: att['check_in'] ?? '--:--',
            checkOut: att['check_out'] ?? '--:--',
            monthYear: monthYear,
            userName: userName,
            shifts: mappedShifts,
          ));
        }

        setState(() {
          _allRecords = fetchedRecords;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load attendance data.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error connecting to server.';
        _isLoading = false;
      });
    }
  }

  List<_AttendanceDayData> get _filteredRecords {
    List<_AttendanceDayData> list = List.from(_allRecords);

    if (_selectedMonth != 'All Months') {
      list = list.where((r) => r.monthYear == _selectedMonth).toList();
    }

    if (_selectedAssistant != 'All') {
      list = list.where((r) => r.userName == _selectedAssistant).toList();
    }

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

                    // Filter by Assistant
                    Text(
                      'FILTER BY ASSISTANT',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _selectedAssistant == 'All',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedAssistant = 'All');
                              setModalState(() {});
                            }
                          },
                          selectedColor: AppTheme.primary.withValues(alpha: 0.15),
                          backgroundColor: AppTheme.background,
                          labelStyle: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: _selectedAssistant == 'All' ? FontWeight.w600 : FontWeight.w400,
                            color: _selectedAssistant == 'All' ? AppTheme.primary : AppTheme.onSurfaceVariant,
                          ),
                          side: BorderSide(
                            color: _selectedAssistant == 'All' ? AppTheme.primary : AppTheme.outlineVariant,
                          ),
                        ),
                        ..._assistants.map((a) {
                          final name = a['name'] as String;
                          final isSelected = _selectedAssistant == name;
                          return ChoiceChip(
                            label: Text(name),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedAssistant = name);
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
                              color: isSelected ? AppTheme.primary : AppTheme.outlineVariant,
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Filter by Month
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
                              setState(() => _selectedMonth = month);
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
                            color: isSelected ? AppTheme.primary : AppTheme.outlineVariant,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Sort Order
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
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.south,
                        color: _isNewestFirst ? AppTheme.primary : AppTheme.onSurfaceVariant,
                        size: 20,
                      ),
                      title: Text(
                        'Newest First',
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
                        setState(() => _isNewestFirst = true);
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
                        'Oldest First',
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
                        setState(() => _isNewestFirst = false);
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 20),
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
        automaticallyImplyLeading: false,
        title: Text(
          'Attendance',
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
                _selectedAssistant != 'All'
                    ? _selectedAssistant
                    : _selectedMonth == 'All Months'
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
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () async {
                final url = Uri.parse('$_baseUrl/admin/export/attendance');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.download, color: AppTheme.primary),
              tooltip: 'Export CSV',
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.error)))
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppTheme.containerPadding),
                    child: Column(
                      children: [
                        if (records.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: 48,
                                      color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No attendance records found',
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
                                userName: record.userName,
                              ),
                            ),
                          ),
                        const SizedBox(height: 100),
                      ],
                    ),
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
    required String userName,
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
          // User name badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              userName,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
          // Date header
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
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: ShiftTimeline(shifts: shifts),
          ),
        ],
      ),
    );
  }
}
