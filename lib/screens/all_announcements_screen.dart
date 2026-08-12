import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:labtrack_pro/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AllAnnouncementsScreen extends StatefulWidget {
  const AllAnnouncementsScreen({super.key});

  @override
  State<AllAnnouncementsScreen> createState() => _AllAnnouncementsScreenState();
}

class _AllAnnouncementsScreenState extends State<AllAnnouncementsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _announcements = [];

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse('http://127.0.0.1:8000/announcements/');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _announcements = data;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load announcements');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Announcements',
          style: GoogleFonts.outfit(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.error)))
              : _announcements.isEmpty
                  ? const Center(child: Text('Belum ada pengumuman.'))
                  : RefreshIndicator(
                      onRefresh: _fetchAnnouncements,
                      color: AppTheme.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _announcements.length,
                        itemBuilder: (context, index) {
                          final ann = _announcements[index];
                          final title = ann['title'] ?? 'Pengumuman';
                          final content = ann['content'] ?? '';
                          final tag = ann['tag'] ?? 'INFO';
                          final imageUrl = ann['image_url'];
                          final dateStr = ann['created_at'] ?? '';
                          
                          // Format date simply for now (could use intl package)
                          String formattedDate = '';
                          if (dateStr.isNotEmpty) {
                            try {
                              final dt = DateTime.parse(dateStr);
                              formattedDate = '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, "0")}';
                            } catch (_) {}
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.campaign, size: 16, color: AppTheme.primary),
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
                                    if (formattedDate.isNotEmpty)
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.onSurfaceVariant.withOpacity(0.7),
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
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  content,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
