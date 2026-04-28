import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laporit_app/core/constants/app_constants.dart';

class ApiService {
  static final String _base = AppConstants.baseUrl;

  // =============================================
  // HELPER: ambil token dari SharedPreferences
  // =============================================
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // =============================================
  // HELPER: header dengan token
  // =============================================
  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // =============================================
  // AUTH
  // =============================================
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_base/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<void> logout() async {
    final headers = await _authHeaders();
    await http.post(Uri.parse('$_base/logout'), headers: headers);
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // =============================================
  // REPORTS
  // =============================================

  // Semua laporan (Admin & Operator)
  static Future<List<dynamic>> getAllReports() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_base/reports'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  }

  // Laporan milik sendiri (User)
  static Future<List<dynamic>> getMyReports() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_base/reports/my'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  }

  // Buat laporan baru (User)
  static Future<Map<String, dynamic>> createReport({
    required String jenisKerusakan,
    required String deskripsi,
    String? lokasi,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$_base/reports'),
      headers: headers,
      body: jsonEncode({
        'jenis_kerusakan': jenisKerusakan,
        'deskripsi': deskripsi,
        'lokasi': lokasi,
      }),
    );
    return jsonDecode(response.body);
  }

  // Update status laporan (Operator & Admin)
  static Future<Map<String, dynamic>> updateStatus({
    required int reportId,
    required String status,
    String? tglEksekusi,
  }) async {
    final headers = await _authHeaders();
    final response = await http.patch(
      Uri.parse('$_base/reports/$reportId/status'),
      headers: headers,
      body: jsonEncode({
        'status': status,
        'tgl_eksekusi': tglEksekusi,
      }),
    );
    return jsonDecode(response.body);
  }


  // ADMIN ONLY: Ambil semua user
  // =============================================

  static Future<List<dynamic>> getAllUsers() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_base/users'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  }
}