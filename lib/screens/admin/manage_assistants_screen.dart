import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:labtrack_pro/theme/app_theme.dart';
import 'package:labtrack_pro/widgets/glass_card.dart';
import 'package:labtrack_pro/services/auth_service.dart';

class ManageAssistantsScreen extends StatefulWidget {
  const ManageAssistantsScreen({super.key});

  @override
  State<ManageAssistantsScreen> createState() => _ManageAssistantsScreenState();
}

class _ManageAssistantsScreenState extends State<ManageAssistantsScreen> {
  final AuthService _authService = AuthService();
  List<dynamic> _assistants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAssistants();
  }

  Future<void> _fetchAssistants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final users = await _authService.getAssistants();
      setState(() {
        _assistants = users.where((u) => u['role'] == 'asisten').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showAddAssistantDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddAssistantBottomSheet(),
    ).then((value) {
      if (value == true) {
        _fetchAssistants(); 
      }
    });
  }

  void _showUpdateRfidDialog(int userId, String userName, String currentRfid) {
    final rfidController = TextEditingController(text: currentRfid == 'Belum terdaftar' ? '' : currentRfid);
    
    showDialog(
      context: context,
      builder: (context) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update RFID untuk $userName'),
              content: TextField(
                controller: rfidController,
                decoration: const InputDecoration(
                  labelText: 'Nomor RFID',
                  hintText: 'Tempelkan kartu lalu ketik/paste ke sini',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    final newRfid = rfidController.text.trim();
                    if (newRfid.isEmpty) return;
                    
                    setState(() => isSubmitting = true);
                    try {
                      await _authService.updateUserRfid(userId, newRfid);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('RFID berhasil diupdate!')),
                        );
                        _fetchAssistants(); // Refresh data
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => isSubmitting = false);
                    }
                  },
                  child: isSubmitting 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Text('Simpan'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primary, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kelola Asisten',
                    style: GoogleFonts.outfit(
                      color: AppTheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _showAddAssistantDialog,
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text('Tambah', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                        : _assistants.isEmpty
                            ? const Center(child: Text('Belum ada data asisten.'))
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: _assistants.length,
                                itemBuilder: (context, index) {
                                  final assistant = _assistants[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GlassCard(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                                          child: Text(
                                            assistant['name'][0].toUpperCase(),
                                            style: TextStyle(
                                              color: AppTheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                assistant['name'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                assistant['email'],
                                                style: TextStyle(
                                                  color: AppTheme.onSurfaceVariant,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'RFID: ${assistant['rfid_uid'] ?? 'Belum terdaftar'}',
                                                style: TextStyle(
                                                  color: AppTheme.onSurfaceVariant,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
                                          onPressed: () => _showUpdateRfidDialog(
                                            assistant['id'], 
                                            assistant['name'], 
                                            assistant['rfid_uid'] ?? 'Belum terdaftar'
                                          ),
                                          tooltip: 'Update RFID',
                                        ),
                                      ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddAssistantBottomSheet extends StatefulWidget {
  const AddAssistantBottomSheet({super.key});

  @override
  State<AddAssistantBottomSheet> createState() => _AddAssistantBottomSheetState();
}

class _AddAssistantBottomSheetState extends State<AddAssistantBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rfidController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authService.registerUser(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _rfidController.text,
      );
      if (mounted) {
        Navigator.pop(context, true); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asisten berhasil ditambahkan!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tambah Asisten Baru',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              obscureText: true,
              validator: (v) => v!.length < 6 ? 'Password minimal 6 karakter' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rfidController,
              decoration: const InputDecoration(
                labelText: 'Nomor RFID', 
                border: OutlineInputBorder(),
                helperText: 'Bisa didapatkan dengan menempelkan kartu ke Kiosk',
              ),
              validator: (v) => v!.isEmpty ? 'RFID wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
