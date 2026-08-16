import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:labtrack_pro/theme/app_theme.dart';
import 'package:labtrack_pro/widgets/glass_card.dart';

import 'package:labtrack_pro/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:labtrack_pro/screens/placeholder_screen.dart';
import 'package:labtrack_pro/screens/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String _displayName = 'Assistant';
  String _userEmail = 'N/A';
  String _userRfid = 'N/A';
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    
    if (userId != null) {
      try {
        final userData = await AuthService().getUserProfile(userId);
        if (mounted) {
          setState(() {
            _displayName = userData['name'] ?? 'Assistant';
            _userEmail = userData['email'] ?? 'N/A';
            _userRfid = userData['rfid_uid'] ?? 'N/A';
            _photoUrl = userData['photo_url'];
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            // Fallback to shared preferences if fetch fails
            _displayName = prefs.getString('user_name') ?? 'Assistant';
            _userEmail = prefs.getString('user_email') ?? 'N/A';
            _userRfid = prefs.getString('user_rfid') ?? 'N/A';
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                _buildProfileHeader(context, _displayName, _userEmail, _userRfid, _photoUrl),
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

  Widget _buildProfileHeader(BuildContext context, String displayName, String userEmail, String userRfid, String? photoUrl) {
    return Column(
      children: [
        // Static Avatar with gradient ring
        _StaticAvatar(photoUrl: photoUrl),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
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
          'RFID: $userRfid',
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



  Widget _buildMenuList(BuildContext context) {
    final menuItems = [
      {'icon': Icons.person_outline, 'label': 'Personal Information'},
      {'icon': Icons.bar_chart, 'label': 'Work Statistics'},
      {'icon': Icons.security, 'label': 'Account Security'},
      {'icon': Icons.lock_outline, 'label': 'Change Password'},
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
                onTap: () {
                  if (item['label'] == 'Change Password') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaceholderScreen(title: item['label'] as String),
                      ),
                    );
                  }
                },
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
  final String? photoUrl;
  
  const _StaticAvatar({this.photoUrl});

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
            child: CircleAvatar(
              backgroundColor: AppTheme.surfaceContainerHigh,
              backgroundImage: photoUrl != null
                  ? NetworkImage(
                      kIsWeb 
                        ? 'https://api.himatekkomug.my.id$photoUrl'
                        : (Platform.isAndroid 
                            ? 'https://api.himatekkomug.my.id$photoUrl' 
                            : 'https://api.himatekkomug.my.id$photoUrl')
                    )
                  : null,
              child: photoUrl == null 
                  ? const Icon(Icons.person, size: 36, color: AppTheme.primary)
                  : null,
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

