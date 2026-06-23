import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laporit_app/core/constants/app_constants.dart';
import 'package:image_picker/image_picker.dart';


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

  // Tugas milik sendiri (Operator)
  static Future<List<dynamic>> getMyTasks() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_base/reports/my-tasks'),
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
    XFile? foto,
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
      final bytes = await foto.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('foto', bytes, filename: foto.name),
      );
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

  // =============================================
  // NOTIFICATIONS
  // =============================================

  static Future<List<dynamic>> getNotifications() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_base/notifications'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  }

  static Future<void> readAllNotifications() async {
    final headers = await _authHeaders();
    await http.post(
      Uri.parse('$_base/notifications/read-all'),
      headers: headers,
    );
  }

  // =============================================
  // USER MANAGEMENT (Admin only)
  // =============================================

  // Toggle status user (aktif/non-aktif)
  static Future<Map<String, dynamic>> toggleUserStatus(
      dynamic userId, bool isAktif) async {
    final headers = await _authHeaders();
    final response = await http.patch(
      Uri.parse('$_base/users/$userId/status'),
      headers: headers,
      body: jsonEncode({'is_aktif': isAktif}),
    );
    return jsonDecode(response.body);
  }

  // Update user (Admin)
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

  // Buat user baru (Admin)
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

  // Hapus user (Admin)
  static Future<Map<String, dynamic>> deleteUser(dynamic userId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$_base/users/$userId'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }
  
  // Ambil data user saat ini (untuk halaman profile)
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_base/user'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  // Update profile (User)
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? nip,
  }) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$_base/profile'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'nip': nip,
      }),
    );
    return jsonDecode(response.body);
  }

  // Ganti password (User)
  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$_base/change-password'),
      headers: headers,
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      }),
    );
    return jsonDecode(response.body);
  }

  // =============================================
  // KATEGORI
  // =============================================

  static Future<List<dynamic>> getKategoris() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_base/kategoris'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  }

  // Buat kategori baru (Admin)
  static Future<Map<String, dynamic>> createKategori(String nama) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$_base/kategoris'),
      headers: headers,
      body: jsonEncode({'nama': nama}),
    );
    return jsonDecode(response.body);
  }

  // Update kategori (Admin)
  static Future<Map<String, dynamic>> updateKategori(dynamic id, String nama) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$_base/kategoris/$id'),
      headers: headers,
      body: jsonEncode({'nama': nama}),
    );
    return jsonDecode(response.body);
  }

  // Hapus kategori (Admin)
  static Future<Map<String, dynamic>> deleteKategori(dynamic id) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$_base/kategoris/$id'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  // =============================================
  // SETTINGS
  // =============================================

  static Future<Map<String, dynamic>> getSettings() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_base/settings'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  // Update settings (Admin)
  static Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> data) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$_base/settings'),
      headers: headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }
}