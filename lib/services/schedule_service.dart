import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ScheduleService {
  String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  // Get schedules for a specific user
  Future<List<dynamic>> getUserSchedules(int userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/schedules/$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Gagal mengambil jadwal asisten';
      }
    } catch (e) {
      if (e is SocketException) {
        throw 'Tidak dapat terhubung ke server lokal.';
      }
      rethrow;
    }
  }

  // Add a new schedule
  Future<void> addSchedule(int userId, String dayOfWeek, int shiftNumber, String activity) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/schedules/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'day_of_week': dayOfWeek,
          'shift_number': shiftNumber,
          'activity': activity,
        }),
      );

      if (response.statusCode != 200) {
        String errorMsg = 'Gagal menambahkan jadwal.';
        try {
          final data = jsonDecode(response.body);
          if (data['detail'] != null) {
            errorMsg = data['detail'];
          }
        } catch (_) {}
        throw errorMsg;
      }
    } catch (e) {
      if (e is SocketException) {
        throw 'Tidak dapat terhubung ke server lokal.';
      }
      rethrow;
    }
  }

  // Delete a schedule
  Future<void> deleteSchedule(int scheduleId) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/schedules/$scheduleId'));
      if (response.statusCode != 200) {
        throw 'Gagal menghapus jadwal.';
      }
    } catch (e) {
      if (e is SocketException) {
        throw 'Tidak dapat terhubung ke server lokal.';
      }
      rethrow;
    }
  }
}
