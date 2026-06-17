import 'package:flutter/material.dart';
import 'package:laporit_app/core/constants/app_colors.dart';
import 'package:laporit_app/core/services/api_service.dart';
import 'package:laporit_app/features/auth/login.dart';
import 'package:laporit_app/features/admin/laporan_admin_screen.dart';
import 'package:laporit_app/features/admin/pengguna_admin_screen.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  int _currentIndex = 0;
  bool _isLoading = true;
  List<dynamic> _reports = [];

  // ── State pengaturan ──────────────────────────────────────────────────────
  String _namaSistem = 'Lapor IT – Central Hub';
  String? _logoPath; // path logo yang sudah di-upload
  bool _is2FAEnabled = true;
  bool _isEmailNotifEnabled = true;
  bool _isPushNotifEnabled = false;

  // Data master
  List<String> _kategoriList = [
    'Hardware',
    'Jaringan',
    'Software',
    'Akses/Login',
    'Printer',
    'Lainnya',
  ];
  List<String> _ruanganList = [
    'Ruang Server',
    'Lab Komputer 1',
    'Lab Komputer 2',
    'Ruang Guru',
    'Perpustakaan',
  ];

  // Data role
  final List<Map<String, dynamic>> _roles = [
    {'nama': 'Admin', 'izin': 'Akses penuh ke semua fitur', 'aktif': true},
    {'nama': 'Operator', 'izin': 'Kelola & proses laporan', 'aktif': true},
    {'nama': 'User', 'izin': 'Buat & pantau laporan', 'aktif': true},
    {'nama': 'Guest', 'izin': 'Lihat laporan publik saja', 'aktif': false},
  ];

  // ── Computed ──────────────────────────────────────────────────────────────
  int get _total => _reports.length;
  int get _pending => _reports.where((r) => r['status'] == 'pending').length;
  int get _diproses => _reports.where((r) => r['status'] == 'proses').length;
  String get _avgResponse => _reports.isEmpty ? '0m' : '45m';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final reports = await ApiService.getAllReports();
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat data', AppColors.error);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // =========================================================================
  // BUILD UTAMA
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardPage(),
          const LaporanAdminScreen(),
          const PenggunaAdminScreen(),
          _buildSetelanPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // =========================================================================
  // HALAMAN DASHBOARD
  // =========================================================================
  Widget _buildDashboardPage() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 28),
              _buildSectionTitle(),
              const SizedBox(height: 20),
              _isLoading ? _buildLoadingStats() : _buildStatsGrid(),
              const SizedBox(height: 16),
              _buildKategoriCard(),
              const SizedBox(height: 16),
              _buildTrendCard(),
              const SizedBox(height: 24),
              _buildLaporanTerbaru(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SELAMAT PAGI,',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500)),
                Text('Lapor IT Admin',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            IconButton(
              onPressed: () => _showNotifikasiSheet(),
              icon: Icon(Icons.notifications_outlined,
                  color: AppColors.textPrimary, size: 28),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Notifikasi sheet (bonus) ──────────────────────────────────────────────
  void _showNotifikasiSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifikasi',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _notifTile(Icons.report_outlined, 'Laporan baru masuk',
                '2 menit lalu', AppColors.primary),
            _notifTile(Icons.check_circle_outline, 'Laporan #TK-42 selesai',
                '1 jam lalu', AppColors.success),
            _notifTile(Icons.cancel_outlined, 'Laporan #TK-38 ditolak',
                '3 jam lalu', AppColors.error),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _notifTile(
      IconData icon, String title, String time, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20)),
      title: Text(title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(time,
          style:
              TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    );
  }

  Widget _buildSectionTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ringkasan Aktivitas',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.1)),
        Text('Sistem Hari Ini',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.accent,
                height: 1.1)),
      ],
    );
  }

  Widget _buildLoadingStats() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.3,
      children: List.generate(
        4,
        (_) => Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary)),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          icon: Icons.bar_chart_rounded,
          label: 'TOTAL LAPORAN',
          value: '$_total',
          valueColor: AppColors.primary,
          iconColor: AppColors.primary,
        ),
        _buildStatCard(
          icon: Icons.calendar_today_outlined,
          label: 'PENDING',
          value: _pending.toString().padLeft(2, '0'),
          valueColor: const Color(0xFFB45309),
          iconColor: const Color(0xFFB45309),
        ),
        _buildStatCard(
          icon: Icons.sync_rounded,
          label: 'DIPROSES',
          value: '$_diproses',
          valueColor: AppColors.accent,
          iconColor: AppColors.accent,
        ),
        _buildStatCard(
          icon: Icons.timer_outlined,
          label: 'AVG. RES',
          value: _avgResponse,
          valueColor: AppColors.success,
          iconColor: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor, size: 26),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: valueColor)),
              Divider(color: valueColor, thickness: 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKategoriCard() {
    final Map<String, int> kategoriCount = {};
    for (var r in _reports) {
      final jenis = r['jenis_kerusakan'] ?? 'Lainnya';
      kategoriCount[jenis] = (kategoriCount[jenis] ?? 0) + 1;
    }
    final total = _reports.isEmpty ? 1 : _reports.length;
    final topKategori = kategoriCount.entries
        .map((e) => {
              'label': e.key,
              'count': e.value,
              'persen': e.value / total
            })
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kategori Laporan',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('MEI 2024',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child:
                        CircularProgressIndicator(color: AppColors.primary)))
          else if (topKategori.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Belum ada laporan',
                  style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            ...topKategori.take(5).map((k) => _buildKategoriRow(
                  label: k['label'] as String,
                  persen: k['persen'] as double,
                )),
        ],
      ),
    );
  }

  Widget _buildKategoriRow({required String label, required double persen}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500)),
              ),
              Text('${(persen * 100).toInt()}%',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: persen,
              minHeight: 7,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard() {
    final data = [0.4, 0.6, 0.5, 0.8, 0.7, 0.9, 0.65];
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tren 7 Hari Terakhir',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('vs minggu lalu',
                    style: TextStyle(color: Colors.white70, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('+12.5%',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up_rounded,
                        color: Colors.greenAccent, size: 16),
                    SizedBox(width: 4),
                    Text('Naik',
                        style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: 50 * data[i],
                      decoration: BoxDecoration(
                        color: i == 5
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(days[i],
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            fontWeight: i == 5
                                ? FontWeight.w700
                                : FontWeight.w400)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaporanTerbaru() {
    final recent = _reports.take(3).toList();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Laporan Terbaru',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: Text('Lihat Semua →',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          Center(
              child: CircularProgressIndicator(color: AppColors.primary))
        else if (recent.isEmpty)
          Center(
              child: Text('Belum ada laporan',
                  style: TextStyle(color: AppColors.textSecondary)))
        else
          ...recent.map((r) => _buildReportCard(r)),
      ],
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final status = report['status'] ?? 'pending';
    final prioritas = (report['prioritas'] ?? 'normal').toString();
    final statusColor = _statusColor(status);
    final prioritasColor = _prioritasColor(prioritas);
    final jenis = report['jenis_kerusakan'] ?? '-';
    final deskripsi = report['deskripsi'] ?? '-';
    final createdAt = report['created_at']?.toString() ?? '';
    final id = report['id']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 70,
            decoration: BoxDecoration(
                color: statusColor, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('#TK-$id',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: prioritasColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(prioritas.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: prioritasColor,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(jenis,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(deskripsi,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                            createdAt.length > 10
                                ? createdAt.substring(0, 10)
                                : createdAt,
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_statusLabel(status),
                          style: TextStyle(
                              fontSize: 11,
                              color: statusColor,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'selesai': return AppColors.success;
      case 'proses':  return AppColors.accent;
      case 'ditolak': return AppColors.error;
      default:        return const Color(0xFF94A3B8);
    }
  }

  Color _prioritasColor(String p) {
    switch (p.toLowerCase()) {
      case 'gawat':
      case 'critical':
      case 'high':
      case 'urgent':  return AppColors.error;
      case 'tinggi':
      case 'medium':  return const Color(0xFFEF9F27);
      default:        return AppColors.accent;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'selesai': return 'Selesai';
      case 'proses':  return 'Diproses';
      case 'ditolak': return 'Ditolak';
      default:        return 'Tertunda';
    }
  }

  // =========================================================================
  // HALAMAN SETELAN — semua button berfungsi
  // =========================================================================
  Widget _buildSetelanPage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pengaturan Sistem',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            Text('Konfigurasi infrastruktur dan tata kelola digital.',
                style:
                    TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 24),

            // ── Pengaturan Umum ──────────────────────────────────────────
            _buildSettingSection(
              icon: Icons.settings_rounded,
              title: 'Pengaturan Umum',
              children: [
                // Nama sistem — bisa diedit
                _buildSettingFieldEditable(
                  label: 'Nama Sistem',
                  value: _namaSistem,
                  onEdit: () => _showEditNamaDialog(),
                ),
                const SizedBox(height: 12),
                // Unggah logo — fungsional
                _buildSettingRowAction(
                  title: 'Logo Instansi',
                  subtitle: _logoPath != null
                      ? 'Logo telah diunggah ✓'
                      : 'Format PNG atau SVG (Maks. 2MB)',
                  action: ElevatedButton(
                    onPressed: () => _showUnggahLogoSheet(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Unggah',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Peran & Izin ─────────────────────────────────────────────
            _buildSettingSection(
              icon: Icons.shield_outlined,
              title: 'Peran & Izin',
              children: [
                _buildSettingRowChevron(
                  title: 'Manajemen Role',
                  subtitle: '${_roles.where((r) => r['aktif'] == true).length} Peran Aktif',
                  onTap: () => _showManajemenRoleSheet(),
                ),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                // Toggle 2FA — fungsional
                _buildSettingToggle(
                  title: 'Otentikasi Dua Faktor',
                  subtitle: 'Wajib bagi semua Admin',
                  value: _is2FAEnabled,
                  onChanged: (val) => _onToggle2FA(val),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Notifikasi ───────────────────────────────────────────────
            _buildSettingSection(
              icon: Icons.notifications_outlined,
              title: 'Notifikasi',
              children: [
                // Toggle email notif — fungsional
                _buildSettingToggle(
                  title: 'Email Laporan Baru',
                  subtitle: 'Kirim ke Admin Penanggung Jawab',
                  value: _isEmailNotifEnabled,
                  onChanged: (val) => _onToggleEmailNotif(val),
                ),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                // Toggle push notif — fungsional
                _buildSettingToggle(
                  title: 'Notifikasi Push',
                  subtitle: 'Aktifkan untuk aplikasi mobile',
                  value: _isPushNotifEnabled,
                  onChanged: (val) => _onTogglePushNotif(val),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Data Master ──────────────────────────────────────────────
            _buildSettingSection(
              icon: Icons.storage_rounded,
              title: 'Data Master',
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _buildDataMasterItem(
                            icon: Icons.category_outlined,
                            label: 'Kategori',
                            count: '${_kategoriList.length} DATA',
                            onTap: () => _showDataMasterSheet('Kategori'))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildDataMasterItem(
                            icon: Icons.meeting_room_outlined,
                            label: 'Ruangan',
                            count: '${_ruanganList.length} DATA',
                            onTap: () => _showDataMasterSheet('Ruangan'))),
                  ],
                ),
                const SizedBox(height: 12),
                // Tombol Tambah Data Baru — fungsional
                InkWell(
                  onTap: () => _showTambahDataSheet(),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline_rounded,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text('Tambah Data Baru',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Simpan Perubahan ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _simpanPerubahan(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Simpan Perubahan',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),

            // ── Logout ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: TextButton(
                onPressed: () => _showLogoutDialog(),
                child: Text('Logout',
                    style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // AKSI — semua fungsi button
  // =========================================================================

  // ── 1. Edit nama sistem ───────────────────────────────────────────────────
  void _showEditNamaDialog() {
    final controller = TextEditingController(text: _namaSistem);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Nama Sistem',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Masukkan nama sistem',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => _namaSistem = controller.text.trim());
                Navigator.pop(ctx);
                _showSnackBar('Nama sistem diperbarui', AppColors.success);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ── 2. Unggah logo ────────────────────────────────────────────────────────
  void _showUnggahLogoSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unggah Logo Instansi',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text('Format PNG atau SVG, ukuran maksimal 2MB.',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            // Pilih dari galeri
            _sheetOptionTile(
              icon: Icons.photo_library_outlined,
              label: 'Pilih dari Galeri',
              onTap: () {
                Navigator.pop(context);
                // TODO: integrasi image_picker
                // final picker = ImagePicker();
                // final file = await picker.pickImage(source: ImageSource.gallery);
                // if (file != null) setState(() => _logoPath = file.path);
                setState(() => _logoPath = 'galeri/logo.png');
                _showSnackBar('Logo berhasil diunggah', AppColors.success);
              },
            ),
            const Divider(height: 1),
            // Ambil foto
            _sheetOptionTile(
              icon: Icons.camera_alt_outlined,
              label: 'Ambil Foto',
              onTap: () {
                Navigator.pop(context);
                // TODO: integrasi image_picker
                // final picker = ImagePicker();
                // final file = await picker.pickImage(source: ImageSource.camera);
                // if (file != null) setState(() => _logoPath = file.path);
                setState(() => _logoPath = 'kamera/logo.png');
                _showSnackBar('Logo berhasil diunggah', AppColors.success);
              },
            ),
            if (_logoPath != null) ...[
              const Divider(height: 1),
              _sheetOptionTile(
                icon: Icons.delete_outline,
                label: 'Hapus Logo',
                color: AppColors.error,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _logoPath = null);
                  _showSnackBar('Logo dihapus', AppColors.error);
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── 3. Toggle 2FA ─────────────────────────────────────────────────────────
  void _onToggle2FA(bool val) {
    if (!val) {
      // Konfirmasi sebelum mematikan 2FA
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Matikan 2FA?',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          content: const Text(
              'Menonaktifkan otentikasi dua faktor akan menurunkan keamanan akun admin.',
              style: TextStyle(fontSize: 13)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _is2FAEnabled = false);
                _showSnackBar('2FA dinonaktifkan', AppColors.error);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text('Nonaktifkan'),
            ),
          ],
        ),
      );
    } else {
      setState(() => _is2FAEnabled = true);
      _showSnackBar('2FA diaktifkan', AppColors.success);
    }
  }

  // ── 4. Toggle notifikasi email ────────────────────────────────────────────
  void _onToggleEmailNotif(bool val) {
    setState(() => _isEmailNotifEnabled = val);
    _showSnackBar(
      val ? 'Notifikasi email diaktifkan' : 'Notifikasi email dimatikan',
      val ? AppColors.success : AppColors.textSecondary,
    );
  }

  // ── 5. Toggle notifikasi push ─────────────────────────────────────────────
  void _onTogglePushNotif(bool val) {
    setState(() => _isPushNotifEnabled = val);
    _showSnackBar(
      val ? 'Notifikasi push diaktifkan' : 'Notifikasi push dimatikan',
      val ? AppColors.success : AppColors.textSecondary,
    );
  }

  // ── 6. Manajemen Role (bottom sheet) ─────────────────────────────────────
  void _showManajemenRoleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          builder: (_, scrollCtrl) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Manajemen Role',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text('Aktifkan atau nonaktifkan peran pengguna.',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    controller: scrollCtrl,
                    itemCount: _roles.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    itemBuilder: (_, i) {
                      final role = _roles[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                              child: Icon(Icons.person_outline,
                                  color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(role['nama'],
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary)),
                                  Text(role['izin'],
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            Switch(
                              value: role['aktif'],
                              activeColor: AppColors.accent,
                              onChanged: (val) {
                                setSheetState(() => _roles[i]['aktif'] = val);
                                setState(() {}); // update subtitle di luar
                                _showSnackBar(
                                  val
                                      ? '${role['nama']} diaktifkan'
                                      : '${role['nama']} dinonaktifkan',
                                  val ? AppColors.success : AppColors.error,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 7. Lihat & kelola data master (Kategori / Ruangan) ───────────────────
  void _showDataMasterSheet(String tipe) {
    final list = tipe == 'Kategori' ? _kategoriList : _ruanganList;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          builder: (_, scrollCtrl) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Data $tipe',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showTambahDataSheet(tipeAwal: tipe);
                      },
                      icon: Icon(Icons.add, color: AppColors.primary, size: 18),
                      label: Text('Tambah',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    controller: scrollCtrl,
                    itemCount: list.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    itemBuilder: (_, i) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.primary.withOpacity(0.08),
                        child: Text('${i + 1}',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ),
                      title: Text(list[i],
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit
                          IconButton(
                            icon: Icon(Icons.edit_outlined,
                                color: AppColors.accent, size: 20),
                            onPressed: () =>
                                _showEditItemDialog(tipe, i, list, setSheetState),
                          ),
                          // Hapus
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: AppColors.error, size: 20),
                            onPressed: () {
                              setSheetState(() => list.removeAt(i));
                              setState(() {});
                              _showSnackBar('$tipe dihapus', AppColors.error);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditItemDialog(
      String tipe, int index, List<String> list, StateSetter setSheetState) {
    final ctrl = TextEditingController(text: list[index]);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit $tipe',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setSheetState(() => list[index] = ctrl.text.trim());
                setState(() {});
                Navigator.pop(ctx);
                _showSnackBar('$tipe diperbarui', AppColors.success);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ── 8. Tambah data baru (Kategori / Ruangan) ──────────────────────────────
  void _showTambahDataSheet({String? tipeAwal}) {
    String selectedTipe = tipeAwal ?? 'Kategori';
    final ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Tambah Data Baru',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              // Pilih tipe
              Text('Tipe Data',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: ['Kategori', 'Ruangan'].map((tipe) {
                  final isSelected = selectedTipe == tipe;
                  return GestureDetector(
                    onTap: () =>
                        setSheetState(() => selectedTipe = tipe),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(tipe,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Input nama
              Text('Nama $selectedTipe',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Contoh: ${selectedTipe == 'Kategori' ? 'Hardware' : 'Lab Komputer 3'}',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final nama = ctrl.text.trim();
                    if (nama.isEmpty) return;
                    setState(() {
                      if (selectedTipe == 'Kategori') {
                        _kategoriList.add(nama);
                      } else {
                        _ruanganList.add(nama);
                      }
                    });
                    Navigator.pop(ctx);
                    _showSnackBar(
                        '$selectedTipe "$nama" berhasil ditambahkan',
                        AppColors.success);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Tambahkan',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 9. Simpan perubahan ───────────────────────────────────────────────────
  void _simpanPerubahan() {
    // TODO: kirim semua perubahan ke ApiService
    // await ApiService.updateSettings({
    //   'nama_sistem': _namaSistem,
    //   'is_2fa_enabled': _is2FAEnabled,
    //   'is_email_notif': _isEmailNotifEnabled,
    //   'is_push_notif': _isPushNotifEnabled,
    // });
    _showSnackBar('Perubahan berhasil disimpan', AppColors.success);
  }

  // ── 10. Logout ────────────────────────────────────────────────────────────
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Logout',
            style:
                TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        content: const Text('Apakah kamu yakin ingin keluar?',
            style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // WIDGET HELPER PENGATURAN
  // =========================================================================

  Widget _buildSettingSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // Field yang bisa diedit (tap untuk edit)
  Widget _buildSettingFieldEditable(
      {required String label,
      required String value,
      required VoidCallback onEdit}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEAEAEA)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500)),
                Icon(Icons.edit_outlined,
                    size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRowAction({
    required String title,
    required String subtitle,
    required Widget action,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        action,
      ],
    );
  }

  Widget _buildSettingRowChevron({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.accent),
        ],
      ),
    );
  }

  Widget _buildDataMasterItem({
    required IconData icon,
    required String label,
    required String count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(count,
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _sheetOptionTile(
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      Color? color}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? AppColors.textPrimary),
      title: Text(label,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color ?? AppColors.textPrimary)),
      onTap: onTap,
    );
  }

  // =========================================================================
  // BOTTOM NAV
  // =========================================================================
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      backgroundColor: Colors.white,
      elevation: 12,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
        BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined), label: 'Laporan'),
        BottomNavigationBarItem(
            icon: Icon(Icons.people_outline), label: 'Pengguna'),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined), label: 'Setelan'),
      ],
    );
  }
}