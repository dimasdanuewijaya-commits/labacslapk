import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Gunakan IP yang sesuai dengan emulator/device
  String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000'; // Untuk iOS Simulator dan Desktop
  }

  // Sign In with Email & Password
  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final userId = data['user']?['id'];
        final userName = data['user']?['name'];
        final userRole = data['user']?['role'];
        final userEmail = data['user']?['email'];
        final userRfid = data['user']?['rfid_uid'];
        
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', token);
          if (userId != null) {
            await prefs.setInt('user_id', userId);
          }
          if (userName != null) {
            await prefs.setString('user_name', userName);
          }
          if (userRole != null) {
            await prefs.setString('user_role', userRole);
          }
          if (userEmail != null) {
            await prefs.setString('user_email', userEmail);
          }
          if (userRfid != null) {
            await prefs.setString('user_rfid', userRfid);
          }
        } else {
          throw 'Token tidak ditemukan dalam response server.';
        }
      } else {
        // Coba parsing pesan error dari server
        String errorMsg = 'Login gagal. Cek email dan password Anda.';
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
        throw 'Tidak dapat terhubung ke server lokal. Pastikan server FastAPI berjalan.';
      }
      rethrow;
    }
  }

  // Change Password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        throw 'Sesi Anda telah habis. Silakan login kembali.';
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/auth/change-password/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        String errorMsg = 'Gagal mengubah password.';
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

  // Register User
  Future<void> registerUser(String name, String email, String password, String rfidUid, {String role = 'asisten'}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'rfid_uid': rfidUid.trim(),
          'role': role,
        }),
      );

      if (response.statusCode != 200) {
        String errorMsg = 'Gagal mendaftarkan asisten.';
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
        throw 'Tidak dapat terhubung ke server lokal. Pastikan server FastAPI berjalan.';
      }
      rethrow;
    }
  }

  // Upload Profile Photo
  Future<void> uploadProfilePhoto(int userId, File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/users/$userId/photo'));
      request.headers['Authorization'] = 'Bearer $token';
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        )
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        String errorMsg = 'Gagal mengunggah foto.';
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

  // Get User Profile
  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      // FastAPI doesn't have a specific /users/{id} endpoint yet? 
      // Actually we have /users which returns all users. We can fetch all and filter, or just make a /users/{id} endpoint.
      // Wait, we need to check if /users/{id} exists.
      final response = await http.get(
        Uri.parse('$_baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        final user = users.firstWhere((u) => u['id'] == userId, orElse: () => null);
        if (user != null) return user;
        throw 'User tidak ditemukan.';
      } else {
        throw 'Gagal mengambil data user.';
      }
    } catch (e) {
      throw 'Terjadi kesalahan: $e';
    }
  }

  // Update User RFID
  Future<void> updateUserRfid(int userId, String rfidUid) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/$userId/rfid'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rfid_uid': rfidUid.trim()}),
      );

      if (response.statusCode != 200) {
        String errorMsg = 'Gagal mendaftarkan RFID.';
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
        throw 'Tidak dapat terhubung ke server lokal. Pastikan server FastAPI berjalan.';
      }
      rethrow;
    }
  }

  // Get All Users (Assistants)
  Future<List<dynamic>> getAssistants() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Gagal mengambil data asisten';
      }
    } catch (e) {
      if (e is SocketException) {
        throw 'Tidak dapat terhubung ke server lokal.';
      }
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('user_id');
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}
