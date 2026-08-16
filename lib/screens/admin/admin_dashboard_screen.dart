import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:labtrack_pro/theme/app_theme.dart';
import 'package:labtrack_pro/widgets/glass_card.dart';
import 'package:labtrack_pro/services/auth_service.dart';
import 'package:labtrack_pro/screens/admin/manage_assistants_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Timer? _statusTimer;
  Map<String, dynamic>? _systemStatus;
  bool _isLoadingStatus = true;
  Map<String, dynamic>? _adminStats;
  bool _isLoadingStats = true;

  String get _baseUrl {
    if (kIsWeb) return 'https://api.himatekkomug.my.id';
    if (Platform.isAndroid) return 'https://api.himatekkomug.my.id';
    return 'https://api.himatekkomug.my.id';
  }

  @override
  void initState() {
    super.initState();
    _fetchSystemStatus();
    _fetchAdminStats();
    // Refresh status setiap 15 detik
    _statusTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _fetchSystemStatus();
      _fetchAdminStats();
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchSystemStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/system/status'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && mounted) {
        setState(() {
          _systemStatus = jsonDecode(response.body);
          _isLoadingStatus = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Backend unreachable
          _systemStatus = {
            'backend_online': false,
            'database_online': false,
            'rpi_online': false,
            'rfid_ok': false,
            'buzzer_ok': false,
            'camera_ok': false,
          };
          _isLoadingStatus = false;
        });
      }
    }
  }

  Future<void> _fetchAdminStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/dashboard/stats'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && mounted) {
        setState(() {
          _adminStats = jsonDecode(response.body);
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildQuickStats(context),
              const SizedBox(height: 24),
              _buildTodayAttendance(),
              const SizedBox(height: 24),
              _buildSystemMonitoring(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: GoogleFonts.outfit(
                color: AppTheme.primary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome back, Admin',
              style: TextStyle(
                color: AppTheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primary,
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    if (_isLoadingStats) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final totalAsisten = _adminStats?['total_asisten']?.toString() ?? '0';
    final avgHadir = _adminStats?['avg_hadir']?.toString() ?? '0%';

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManageAssistantsScreen()),
              );
            },
            child: _buildStatCard(
              'Total Assistants',
              totalAsisten,
              Icons.people_alt_rounded,
              AppTheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Avg Attendance',
            avgHadir,
            Icons.bar_chart_rounded,
            Colors.tealAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: AppTheme.primary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAttendance() {
    if (_isLoadingStats) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final hadir = _adminStats?['hadir_hari_ini']?.toString() ?? '0';
    final terlambat = _adminStats?['terlambat_hari_ini']?.toString() ?? '0';
    final absen = _adminStats?['absen_hari_ini']?.toString() ?? '0';

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Attendance",
                style: GoogleFonts.outfit(
                  color: AppTheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.more_horiz, color: AppTheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAttendanceItem(hadir, 'Present', AppTheme.emerald),
              _buildAttendanceItem(terlambat, 'Late', AppTheme.amber),
              _buildAttendanceItem(absen, 'Absent', AppTheme.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(String count, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Text(
            count,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ─── SYSTEM MONITORING ───────────────────────────────────────────────────
  Widget _buildSystemMonitoring() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.monitor_heart_outlined, color: AppTheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'System Monitoring',
                    style: GoogleFonts.outfit(
                      color: AppTheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Refresh button
              GestureDetector(
                onTap: () {
                  setState(() => _isLoadingStatus = true);
                  _fetchSystemStatus();
                },
                child: Icon(
                  Icons.refresh_rounded,
                  color: AppTheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingStatus)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            _buildStatusRow(
              icon: Icons.dns_rounded,
              label: 'Backend Server',
              isOk: _systemStatus?['backend_online'] ?? false,
            ),
            const SizedBox(height: 10),
            _buildStatusRow(
              icon: Icons.storage_rounded,
              label: 'Database',
              isOk: _systemStatus?['database_online'] ?? false,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),
            _buildStatusRow(
              icon: Icons.developer_board_rounded,
              label: 'Raspberry Pi',
              isOk: _systemStatus?['rpi_online'] ?? false,
            ),
            const SizedBox(height: 10),
            _buildStatusRow(
              icon: Icons.nfc_rounded,
              label: 'RFID Reader',
              isOk: _systemStatus?['rfid_ok'] ?? false,
            ),
            const SizedBox(height: 10),
            _buildStatusRow(
              icon: Icons.volume_up_rounded,
              label: 'Buzzer',
              isOk: _systemStatus?['buzzer_ok'] ?? false,
            ),
            const SizedBox(height: 10),
            _buildStatusRow(
              icon: Icons.lightbulb_outline_rounded,
              label: 'LED Indicator',
              isOk: _systemStatus?['led_ok'] ?? false,
            ),
            const SizedBox(height: 10),
            _buildStatusRow(
              icon: Icons.camera_alt_rounded,
              label: 'Camera',
              isOk: _systemStatus?['camera_ok'] ?? false,
            ),
            if (_systemStatus?['last_heartbeat'] != null) ...[
              const SizedBox(height: 12),
              Text(
                'Last heartbeat: ${_formatHeartbeat(_systemStatus!['last_heartbeat'])}',
                style: TextStyle(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required bool isOk,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.onSurfaceVariant, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isOk
                ? AppTheme.emerald.withOpacity(0.1)
                : AppTheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isOk
                  ? AppTheme.emerald.withOpacity(0.5)
                  : AppTheme.error.withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isOk ? AppTheme.emerald : AppTheme.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isOk ? 'OK' : 'Offline',
                style: TextStyle(
                  color: isOk ? AppTheme.emerald : AppTheme.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatHeartbeat(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      return '${diff.inHours}h ago';
    } catch (_) {
      return isoString;
    }
  }
}
