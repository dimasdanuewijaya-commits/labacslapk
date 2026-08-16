import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> _pickAndUploadPhoto(int userId) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() {
          _isLoading = true;
        });
        
        await _authService.uploadProfilePhoto(userId, File(pickedFile.path));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto berhasil diunggah')),
        );
        
        _fetchAssistants();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    }
  }

  String get _baseUrl {
    if (kIsWeb) return 'https://api.himatekkomug.my.id';
    if (Platform.isAndroid) return 'https://api.himatekkomug.my.id';
    return 'https://api.himatekkomug.my.id';
  }

  void _showEditAssistantDialog(int userId, String currentName, String currentEmail, String currentRfid) {
    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail);
    final rfidController = TextEditingController(text: currentRfid == 'Not registered' ? '' : currentRfid);
    
    showDialog(
      context: context,
      builder: (context) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Assistant'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: rfidController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor RFID',
                        prefixIcon: Icon(Icons.nfc_outlined),
                        hintText: 'Kosongkan jika belum ada',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    final newName = nameController.text.trim();
                    final newEmail = emailController.text.trim();
                    final newRfid = rfidController.text.trim();
                    
                    if (newName.isEmpty || newEmail.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nama dan Email tidak boleh kosong')),
                      );
                      return;
                    }
                    
                    setState(() => isSubmitting = true);
                    try {
                      final response = await http.put(
                        Uri.parse('$_baseUrl/users/$userId'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'name': newName,
                          'email': newEmail,
                          'rfid_uid': newRfid.isEmpty ? '' : newRfid,
                        }),
                      );
                      
                      if (response.statusCode == 200) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Assistant data successfully updated!')),
                          );
                          _fetchAssistants();
                        }
                      } else {
                        final body = jsonDecode(response.body);
                        throw Exception(body['detail'] ?? 'Gagal mengupdate data');
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
                    : const Text('Save'),
                ),
              ],
            );
          }
        );
      }
    );
  }
  Future<void> _deleteAssistant(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/users/$userId'),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assistant successfully deleted')),
          );
          _fetchAssistants();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete assistant')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _confirmDeleteAssistant(int userId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assistant'),
        content: Text('Are you sure you want to delete assistant $name? Their attendance and schedule data will also be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAssistant(userId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
                    'Manage Assistants',
                    style: GoogleFonts.outfit(
                      color: AppTheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _showAddAssistantDialog,
                    icon: const Icon(Icons.add, color: Colors.white, size: 16),
                    label: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                            ? const Center(child: Text('No assistants found.'))
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
                                        GestureDetector(
                                          onTap: () => _pickAndUploadPhoto(assistant['id']),
                                          child: Stack(
                                            children: [
                                              CircleAvatar(
                                                radius: 24,
                                                backgroundColor: AppTheme.primary.withOpacity(0.1),
                                                backgroundImage: assistant['photo_url'] != null
                                                    ? NetworkImage(
                                                        kIsWeb 
                                                          ? 'https://api.himatekkomug.my.id${assistant['photo_url']}'
                                                          : (Platform.isAndroid 
                                                              ? 'https://api.himatekkomug.my.id${assistant['photo_url']}' 
                                                              : 'https://api.himatekkomug.my.id${assistant['photo_url']}')
                                                      )
                                                    : null,
                                                child: assistant['photo_url'] == null 
                                                    ? Text(
                                                        assistant['name'][0].toUpperCase(),
                                                        style: TextStyle(
                                                          color: AppTheme.primary,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.primary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                                                ),
                                              ),
                                            ],
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
                                                'RFID: ${assistant['rfid_uid'] ?? 'Not registered'}',
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
                                          onPressed: () => _showEditAssistantDialog(
                                            assistant['id'], 
                                            assistant['name'],
                                            assistant['email'],
                                            assistant['rfid_uid'] ?? 'Not registered'
                                          ),
                                          tooltip: 'Edit Assistant',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                          onPressed: () => _confirmDeleteAssistant(assistant['id'], assistant['name']),
                                          tooltip: 'Delete Assistant',
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
          const SnackBar(content: Text('Assistant successfully added!')),
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
              'Add New Assistant',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Email is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              obscureText: true,
              validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rfidController,
              decoration: const InputDecoration(
                labelText: 'RFID Number', 
                border: OutlineInputBorder(),
                helperText: 'Can be obtained by tapping card on Kiosk',
              ),
              validator: (v) => v!.isEmpty ? 'RFID is required' : null,
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
                    : const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
