import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:labtrack_pro/theme/app_theme.dart';
import 'package:labtrack_pro/widgets/glass_card.dart';
import 'package:labtrack_pro/services/auth_service.dart';
import 'package:labtrack_pro/services/schedule_service.dart';

class ManageScheduleScreen extends StatefulWidget {
  const ManageScheduleScreen({super.key});

  @override
  State<ManageScheduleScreen> createState() => _ManageScheduleScreenState();
}

class _ManageScheduleScreenState extends State<ManageScheduleScreen> {
  final AuthService _authService = AuthService();
  final ScheduleService _scheduleService = ScheduleService();

  List<dynamic> _assistants = [];
  dynamic _selectedAssistant;
  List<dynamic> _schedules = [];
  bool _isLoadingAssistants = true;
  bool _isLoadingSchedules = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAssistants();
  }

  Future<void> _fetchAssistants() async {
    try {
      final users = await _authService.getAssistants();
      setState(() {
        _assistants = users.where((u) => u['role'] == 'asisten').toList();
        _isLoadingAssistants = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingAssistants = false;
      });
    }
  }

  Future<void> _fetchSchedules(int userId) async {
    setState(() {
      _isLoadingSchedules = true;
      _error = null;
    });
    try {
      final schedules = await _scheduleService.getUserSchedules(userId);
      setState(() {
        _schedules = schedules;
        _isLoadingSchedules = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingSchedules = false;
      });
    }
  }

  Future<void> _deleteSchedule(int scheduleId) async {
    try {
      await _scheduleService.deleteSchedule(scheduleId);
      if (_selectedAssistant != null) {
        _fetchSchedules(_selectedAssistant['id']);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule successfully deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  void _showAddScheduleDialog() {
    if (_selectedAssistant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an assistant first!')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddScheduleBottomSheet(userId: _selectedAssistant['id']),
    ).then((value) {
      if (value == true && _selectedAssistant != null) {
        _fetchSchedules(_selectedAssistant['id']);
      }
    });
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
              Text(
                'Manage Schedule',
                style: GoogleFonts.outfit(
                  color: AppTheme.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              if (_isLoadingAssistants)
                const Center(child: CircularProgressIndicator())
              else if (_error != null && _assistants.isEmpty)
                Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<dynamic>(
                      isExpanded: true,
                      hint: const Text('Select Assistant...'),
                      value: _selectedAssistant,
                      items: _assistants.map((ast) {
                        return DropdownMenuItem<dynamic>(
                          value: ast,
                          child: Text(ast['name']),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedAssistant = val;
                        });
                        if (val != null) {
                          _fetchSchedules(val['id']);
                        }
                      },
                    ),
                  ),
                ),
              
              if (_selectedAssistant != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showAddScheduleDialog,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add New Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              
              Expanded(
                child: _selectedAssistant == null
                    ? const Center(child: Text('Please select an assistant above to view their schedule.'))
                    : _isLoadingSchedules
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                            : _schedules.isEmpty
                                ? Center(child: Text('${_selectedAssistant['name']} does not have any schedule yet.'))
                                : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: _schedules.length,
                                    itemBuilder: (context, index) {
                                      final sched = _schedules[index];
                                      String rawActivity = sched['activity'] ?? '';
                                      String leftChar = 'T';
                                      String displaySubtitle = '';

                                      if (rawActivity.startsWith('Teaching')) {
                                        leftChar = 'T';
                                        // Format: "Teaching - MCS - 3KB02-A"
                                        List<String> parts = rawActivity.split(' - ');
                                        if (parts.length >= 3) {
                                          String matkum = parts[1];
                                          String classDetail = parts[2];
                                          displaySubtitle = 'Shift ${sched['shift_number']} - $matkum ($classDetail)';
                                        } else {
                                          String classDetail = rawActivity.replaceFirst('Teaching - ', '').trim();
                                          displaySubtitle = 'Shift ${sched['shift_number']} - $classDetail';
                                        }
                                      } else if (rawActivity.toLowerCase() == 'piket') {
                                        leftChar = 'P';
                                        displaySubtitle = 'Shift ${sched['shift_number']} - Piket';
                                      } else {
                                        leftChar = rawActivity.isNotEmpty ? rawActivity[0].toUpperCase() : '?';
                                        displaySubtitle = 'Shift ${sched['shift_number']} - $rawActivity';
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: GlassCard(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 50,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primary.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  leftChar,
                                                  style: TextStyle(
                                                    color: AppTheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 22,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      sched['day_of_week'],
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      displaySubtitle,
                                                      style: TextStyle(
                                                        color: AppTheme.onSurfaceVariant,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                                onPressed: () => _deleteSchedule(sched['id']),
                                              )
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

class AddScheduleBottomSheet extends StatefulWidget {
  final int userId;
  const AddScheduleBottomSheet({super.key, required this.userId});

  @override
  State<AddScheduleBottomSheet> createState() => _AddScheduleBottomSheetState();
}

class _AddScheduleBottomSheetState extends State<AddScheduleBottomSheet> {
  final ScheduleService _scheduleService = ScheduleService();
  bool _isLoading = false;

  String _selectedDay = 'Senin';
  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

  int _selectedShift = 1;
  final List<int> _shifts = [1, 2, 3, 4, 5];

  String _selectedActivity = 'Teaching';
  final List<String> _activities = ['Teaching', 'Piket', 'Riset', 'Rapat'];

  // Variables for Teaching Specifics
  String _selectedJurusan = '3DC'; // default
  final Map<String, String> _jurusanOptions = {
    '3DC': '3DC (Teknik Komputer)',
    '2KB': '2KB (Sistem Komputer)',
  };

  String _selectedKelas = '01';
  final List<String> _kelasOptions = ['01', '02'];

  String _selectedKelompok = 'A';

  List<String> get _kelompokOptions {
    if (_selectedJurusan == '3DC') return ['A', 'B'];
    if (_selectedJurusan == '2KB') return ['A', 'B', 'C'];
    return ['A'];
  }

  String _selectedMatkum = 'JKL';
  List<String> get _matkumOptions {
    if (_selectedJurusan == '3DC') return ['JKL', 'MCS'];
    if (_selectedJurusan == '2KB') return ['JKD', 'FPGA'];
    return ['JKL'];
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    
    String finalActivity = _selectedActivity;
    if (_selectedActivity == 'Teaching') {
      finalActivity = 'Teaching - $_selectedMatkum - $_selectedJurusan$_selectedKelas-$_selectedKelompok';
    }

    try {
      await _scheduleService.addSchedule(
        widget.userId,
        _selectedDay,
        _selectedShift,
        finalActivity,
      );
      if (mounted) {
        Navigator.pop(context, true); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule successfully added!')),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Shift Schedule',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Day', border: OutlineInputBorder()),
            value: _selectedDay,
            items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (v) => setState(() => _selectedDay = v!),
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Shift Number', border: OutlineInputBorder()),
            value: _selectedShift,
            items: _shifts.map((s) => DropdownMenuItem(value: s, child: Text('Shift $s'))).toList(),
            onChanged: (v) => setState(() => _selectedShift = v!),
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Activity', border: OutlineInputBorder()),
            value: _selectedActivity,
            items: _activities.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
            onChanged: (v) => setState(() => _selectedActivity = v!),
          ),
          
          if (_selectedActivity == 'Teaching') ...[
            const SizedBox(height: 16),
            const Text("Practicum Class Details", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Major', border: OutlineInputBorder()),
                    value: _selectedJurusan,
                    items: _jurusanOptions.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedJurusan = v!;
                        // Adjust kelompok if out of bounds
                        if (!_kelompokOptions.contains(_selectedKelompok)) {
                          _selectedKelompok = _kelompokOptions.first;
                        }
                        // Adjust matkum if out of bounds
                        if (!_matkumOptions.contains(_selectedMatkum)) {
                          _selectedMatkum = _matkumOptions.first;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
                    value: _selectedKelas,
                    items: _kelasOptions.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                    onChanged: (v) => setState(() => _selectedKelas = v!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Group', border: OutlineInputBorder()),
                    value: _selectedKelompok,
                    items: _kelompokOptions.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                    onChanged: (v) => setState(() => _selectedKelompok = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Course', border: OutlineInputBorder()),
              value: _selectedMatkum,
              items: _matkumOptions.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (v) => setState(() => _selectedMatkum = v!),
            ),
          ],

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
                  : const Text('Save Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
