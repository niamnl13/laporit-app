import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laporit_app/core/constants/app_constants.dart';
import 'dart:io';

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
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
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
    String? judul,
    String? priority,
    String? nub,
    File? foto,
  }) async {
    final token = await _getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_base/reports'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields['jenis_kerusakan'] = jenisKerusakan;
    request.fields['deskripsi'] = deskripsi;
    if (lokasi != null) request.fields['lokasi'] = lokasi;
    if (judul != null) request.fields['judul'] = judul;
    if (priority != null) request.fields['priority'] = priority;
    if (nub != null) request.fields['nub'] = nub;

    if (foto != null) {
      request.files.add(await http.MultipartFile.fromPath('foto', foto.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  // Update status laporan — method lama (tetap dipertahankan)
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
        if (tglEksekusi != null) 'tgl_eksekusi': tglEksekusi,
      }),
    );
    return jsonDecode(response.body);
  }

  // Update status laporan — versi baru untuk LaporanAdminScreen
  static Future<Map<String, dynamic>> updateReportStatus(
      dynamic reportId, String status) async {
    final headers = await _authHeaders();
    final response = await http.patch(
      Uri.parse('$_base/reports/$reportId/status'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );
    return jsonDecode(response.body);
  }

  // =============================================
  // USERS (Admin only)
  // =============================================

  // Ambil semua user
  static Future<List<dynamic>> getAllUsers() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_base/users'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  }

  // Tambah user baru
  static Future<Map<String, dynamic>> createUser(
      Map<String, dynamic> data) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$_base/users'),
      headers: headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // Edit user
  static Future<Map<String, dynamic>> updateUser(
      dynamic userId, Map<String, dynamic> data) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$_base/users/$userId'),
      headers: headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // Hapus user
  static Future<Map<String, dynamic>> deleteUser(dynamic userId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$_base/users/$userId'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  // Aktifkan / nonaktifkan user
  static Future<Map<String, dynamic>> toggleUserStatus(
      dynamic userId, bool isActive) async {
    final headers = await _authHeaders();
    final response = await http.patch(
      Uri.parse('$_base/users/$userId/status'),
      headers: headers,
      body: jsonEncode({'is_active': isActive}),
    );
    return jsonDecode(response.body);
  }
}