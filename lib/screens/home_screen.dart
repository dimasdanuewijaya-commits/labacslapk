import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:labtrack_pro/theme/app_theme.dart';
import 'package:labtrack_pro/widgets/glass_card.dart';
import 'package:labtrack_pro/widgets/stat_card.dart';
import 'package:labtrack_pro/widgets/attendance_entry.dart';
import 'package:labtrack_pro/screens/all_announcements_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;
  String? _errorMessage;
  String _userName = '';

  String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userId = prefs.getInt('user_id') ?? 2; // Default fallback to 2
      final userName = prefs.getString('user_name') ?? 'Assistant';
      
      if (token == null) {
        setState(() {
          _errorMessage = 'Sesi Anda telah habis. Silakan login kembali.';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/dashboard/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _dashboardData = jsonDecode(response.body);
          _userName = userName;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data dashboard (Error ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat terhubung ke server lokal.';
        _isLoading = false;
      });
    }
  }

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
          child: RefreshIndicator(
            onRefresh: _fetchDashboardData,
            color: AppTheme.primary,
            backgroundColor: AppTheme.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppTheme.containerPadding),
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 100.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppTheme.error),
                          ),
                        ),
                      )
                    : Column(
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
                          _buildAnnouncements(context),
                          const SizedBox(height: 100), // Bottom nav space
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else if (hour < 20) {
      return 'Good Evening,';
    } else {
      return 'Good Night,';
    }
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
                _greeting,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Text(
                _userName.isNotEmpty ? _userName : 'Assistant',
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
          value: _dashboardData?['total_hadir']?.toString() ?? '0',
          subtitle: 'Days',
          icon: Icons.schedule,
          iconColor: AppTheme.primary,
        ),
        StatCard(
          label: 'Absent',
          value: _dashboardData?['total_alpha']?.toString() ?? '0',
          subtitle: 'Days',
          icon: Icons.person_off_outlined,
          iconColor: AppTheme.error,
        ),
        StatCard(
          label: 'Hours',
          value: _dashboardData?['total_hours_str']?.toString() ?? '0h 0m',
          subtitle: 'Monthly',
          icon: Icons.timer_outlined,
          iconColor: AppTheme.secondary,
        ),
        StatCard(
          label: 'Rank',
          value: _dashboardData?['rank']?.toString() ?? '0',
          subtitle: 'Monthly',
          icon: Icons.emoji_events_outlined,
          iconColor: AppTheme.tertiary,
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
          label: 'Status',
          value: (_dashboardData?['total_alpha'] ?? 0) > 2 ? 'Warning' : 'Good',
          subtitle: 'Condition',
          icon: Icons.health_and_safety,
          iconColor: AppTheme.primary,
        ),
        StatCard(
          label: 'Points',
          value: _dashboardData?['poin_mutu']?.toString() ?? '0',
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
                NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_dashboardData?['gaji_bulan_ini'] ?? 0),
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

  Widget _buildAnnouncements(BuildContext context) {
    final ann = _dashboardData?['latest_announcement'];
    if (ann == null) return const SizedBox.shrink();

    final title = ann['title'] ?? 'Pengumuman';
    final content = ann['content'] ?? '';
    final tag = ann['tag'] ?? 'INFO';
    final imageUrl = ann['image_url'];

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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AllAnnouncementsScreen()),
                );
              },
              child: Text(
                'View All',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
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
                        tag,
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
                  if (imageUrl != null && imageUrl.toString().isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'http://127.0.0.1:8000$imageUrl',
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
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
