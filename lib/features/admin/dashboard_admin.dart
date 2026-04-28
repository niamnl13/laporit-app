import 'package:flutter/material.dart';
import 'package:laporit_app/core/constants/app_colors.dart';
import 'package:laporit_app/core/services/api_service.dart';
import 'package:laporit_app/features/auth/login.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  int _currentIndex = 0;
  bool _isLoading = true;
  List<dynamic> _reports = [];

  int get _total => _reports.length;
  int get _pending => _reports.where((r) => r['status'] == 'pending').length;
  int get _diproses => _reports.where((r) => r['status'] == 'proses').length;
  int get _selesai => _reports.where((r) => r['status'] == 'selesai').length;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardPage(),
          _buildPlaceholder('Laporan'),
          _buildPlaceholder('Pengguna'),
          _buildSetelanPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // =============================================
  // HALAMAN DASHBOARD
  // =============================================
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
              const SizedBox(height: 20),
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

  // =============================================
  // HEADER
  // =============================================
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELAMAT PAGI,',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Lapor IT Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            IconButton(
              onPressed: () {},
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

  // =============================================
  // SECTION TITLE
  // =============================================
  Widget _buildSectionTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Aktivitas',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          'Sistem Hari Ini',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  // =============================================
  // LOADING PLACEHOLDER
  // =============================================
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  // =============================================
  // STATS GRID 2x2
  // =============================================
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
          icon: Icons.check_circle_outline_rounded,
          label: 'SELESAI',
          value: '$_selesai',
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
            offset: const Offset(0, 4),
          ),
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
              ),
              Divider(color: valueColor, thickness: 2),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================
  // KATEGORI LAPORAN
  // =============================================
  Widget _buildKategoriCard() {
    final Map<String, int> kategoriCount = {};
    for (var r in _reports) {
      final jenis = r['jenis_kerusakan'] ?? 'Lainnya';
      kategoriCount[jenis] = (kategoriCount[jenis] ?? 0) + 1;
    }

    final total = _reports.isEmpty ? 1 : _reports.length;
    final kategoriList = kategoriCount.entries
        .map((e) => {'label': e.key, 'persen': e.value / total})
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kategori Laporan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$_total laporan',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            CircularProgressIndicator(color: AppColors.primary)
          else if (kategoriList.isEmpty)
            Text('Belum ada laporan',
                style: TextStyle(color: AppColors.textSecondary))
          else
            ...kategoriList.map((k) => _buildKategoriRow(
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

  // =============================================
  // TREN CARD
  // =============================================
  Widget _buildTrendCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Laporan Masuk',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$_total Laporan',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'keseluruhan',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================
  // LAPORAN TERBARU
  // =============================================
  Widget _buildLaporanTerbaru() {
    final recent = _reports.take(3).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Laporan Terbaru',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: Text(
                'Lihat Semua →',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          Center(child: CircularProgressIndicator(color: AppColors.primary))
        else if (recent.isEmpty)
          Center(
            child: Text('Belum ada laporan',
                style: TextStyle(color: AppColors.textSecondary)),
          )
        else
          ...recent.map((r) => _buildReportCard(r)),
      ],
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final status = report['status'] ?? 'pending';
    final statusColor = _statusColor(status);
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#TK-$id',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        jenis,
                        style: TextStyle(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  deskripsi,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusLabel(status),
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
      case 'selesai':
        return AppColors.success;
      case 'proses':
        return AppColors.accent;
      case 'ditolak':
        return AppColors.error;
      default:
        return const Color(0xFF94A3B8);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'selesai':
        return 'Selesai';
      case 'proses':
        return 'Diproses';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Pending';
    }
  }

  // =============================================
  // SETELAN PAGE
  // =============================================
  Widget _buildSetelanPage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Setelan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Keluar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // BOTTOM NAV
  // =============================================
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

  // =============================================
  // PLACEHOLDER
  // =============================================
  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded,
              size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Halaman $title\nSedang Dikembangkan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}