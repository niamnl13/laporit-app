import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laporit_app/core/constants/app_colors.dart';
import 'package:laporit_app/core/services/api_service.dart';
import 'package:laporit_app/features/auth/login.dart';

class DashboardOperator extends StatefulWidget {
  const DashboardOperator({super.key});

  @override
  State<DashboardOperator> createState() => _DashboardOperatorState();
}

class _DashboardOperatorState extends State<DashboardOperator> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String _operatorName = 'Operator';
  List<dynamic> _reports = [];

  // Stats
  List<dynamic> get _pending =>
      _reports.where((r) => r['status'] == 'pending').toList();
  List<dynamic> get _diproses =>
      _reports.where((r) => r['status'] == 'proses').toList();
  List<dynamic> get _selesai =>
      _reports.where((r) => r['status'] == 'selesai').toList();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('name') ?? 'Operator';

      final reports = await ApiService.getAllReports();
      setState(() {
        _operatorName = name;
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat data', AppColors.error);
    }
  }

  Future<void> _ambilTugas(int reportId) async {
    try {
      final result = await ApiService.updateStatus(
        reportId: reportId,
        status: 'proses',
      );
      if (result['success'] == true) {
        _showSnackBar('Tugas berhasil diambil!', AppColors.success);
        _loadData();
      }
    } catch (e) {
      _showSnackBar('Gagal mengambil tugas', AppColors.error);
    }
  }

  Future<void> _selesaikanTugas(int reportId) async {
    try {
      final now = DateTime.now().toString().substring(0, 10);
      final result = await ApiService.updateStatus(
        reportId: reportId,
        status: 'selesai',
        tglEksekusi: now,
      );
      if (result['success'] == true) {
        _showSnackBar('Tugas berhasil diselesaikan!', AppColors.success);
        _loadData();
      }
    } catch (e) {
      _showSnackBar('Gagal menyelesaikan tugas', AppColors.error);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showSnackBar('Fitur segera hadir!', AppColors.accent),
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildBerandaPage(),
          _buildTugasPage(),
          _buildRiwayatPage(),
          _buildProfilPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // =============================================
  // BERANDA
  // =============================================
  Widget _buildBerandaPage() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.accent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 16),
              _buildSummaryCard(),
              const SizedBox(height: 24),
              _buildTugasBaru(),
              const SizedBox(height: 24),
              _buildAksiCepat(),
              const SizedBox(height: 80),
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.grid_view_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              'Lapor IT',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
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
  // STATS ROW (2 kartu)
  // =============================================
  Widget _buildStatsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang,',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.accent,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          _operatorName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildStatCard2(
                icon: Icons.settings_outlined,
                label: 'Laporan Baru',
                value: '${_pending.length}',
                sub: '+${_pending.length} menunggu',
                subColor: AppColors.accent,
                borderColor: AppColors.accent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildStatCard2(
                icon: Icons.check_box_outlined,
                label: 'Tugas Aktif',
                value: _diproses.length.toString().padLeft(2, '0'),
                sub: 'Target harian: 08',
                subColor: AppColors.textSecondary,
                borderColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard2({
    required IconData icon,
    required String label,
    required String value,
    required String sub,
    required Color subColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
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
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(height: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(sub,
              style: TextStyle(
                  fontSize: 11,
                  color: subColor,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // =============================================
  // SUMMARY CARD (dark)
  // =============================================
  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selesai Minggu Ini',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                '${_selesai.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Avg. Respon',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                '14 Menit',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================
  // TUGAS BARU (laporan pending)
  // =============================================
  Widget _buildTugasBaru() {
    final tugasBaru = _pending.take(3).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tugas Baru',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: Text(
                'Lihat Semua',
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
          Center(child: CircularProgressIndicator(color: AppColors.accent))
        else if (tugasBaru.isEmpty)
          _buildEmptyState('Tidak ada tugas baru')
        else
          ...tugasBaru.map((r) => _buildTugasCard(r, isPending: true)),
      ],
    );
  }

  Widget _buildTugasCard(Map<String, dynamic> report,
      {bool isPending = false}) {
    final priority = report['priority'] ?? 'normal';
    final priorityColor = _priorityColor(priority);
    final id = report['id']?.toString() ?? '-';
    final jenis = report['jenis_kerusakan'] ?? '-';
    final deskripsi = report['deskripsi'] ?? '-';
    final lokasi = report['lokasi'] ?? '-';
    final pelapor = report['user']?['name'] ?? '-';
    final createdAt = report['created_at']?.toString() ?? '';
    final timeAgo = createdAt.length > 10 ? createdAt.substring(0, 10) : createdAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority + ID + Waktu
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        priority.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: priorityColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '#ID-$id',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Judul
                Text(
                  deskripsi,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // Lokasi & Pelapor
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      lokasi,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.person_outline,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Pelapor: $pelapor',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tombol Ambil Tugas
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isPending
                    ? () => _ambilTugas(report['id'])
                    : () => _selesaikanTugas(report['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isPending ? AppColors.primary : AppColors.success,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isPending ? 'Ambil Tugas' : 'Selesaikan',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // AKSI CEPAT
  // =============================================
  Widget _buildAksiCepat() {
    final aksi = [
      {'icon': Icons.description_outlined, 'label': 'Buat Laporan', 'color': AppColors.accent},
      {'icon': Icons.inventory_2_outlined, 'label': 'Inventaris', 'color': const Color(0xFFF59E0B)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: aksi.map((a) {
            final color = a['color'] as Color;
            return Expanded(
              child: GestureDetector(
                onTap: () =>
                    _showSnackBar('Fitur segera hadir!', AppColors.accent),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(a['icon'] as IconData,
                            color: color, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // =============================================
  // TUGAS PAGE (semua laporan pending & proses)
  // =============================================
  Widget _buildTugasPage() {
    final semua = _reports
        .where((r) => r['status'] == 'pending' || r['status'] == 'proses')
        .toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Semua Tugas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.accent))
                  : semua.isEmpty
                      ? _buildEmptyState('Tidak ada tugas')
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: semua.length,
                          itemBuilder: (context, index) {
                            final r = semua[index];
                            return _buildTugasCard(
                              r,
                              isPending: r['status'] == 'pending',
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // RIWAYAT PAGE (laporan selesai)
  // =============================================
  Widget _buildRiwayatPage() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Riwayat Selesai',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.accent))
                  : _selesai.isEmpty
                      ? _buildEmptyState('Belum ada laporan selesai')
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _selesai.length,
                          itemBuilder: (context, index) {
                            final r = _selesai[index];
                            return _buildRiwayatCard(r);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatCard(Map<String, dynamic> report) {
    final jenis = report['jenis_kerusakan'] ?? '-';
    final deskripsi = report['deskripsi'] ?? '-';
    final tglEksekusi = report['tgl_eksekusi'] ?? '-';
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
              color: AppColors.success,
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
                    Text('#TK-$id',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Selesai',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600)),
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
                const SizedBox(height: 6),
                Text('Diselesaikan: $tglEksekusi',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // PROFIL PAGE
  // =============================================
  Widget _buildProfilPage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profil',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Container(
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
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.person,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _operatorName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Operator IT',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
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
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      backgroundColor: Colors.white,
      elevation: 12,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded), label: 'Beranda'),
        BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined), label: 'Tugas'),
        BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded), label: 'Riwayat'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
    );
  }

  // =============================================
  // HELPERS
  // =============================================
  Color _priorityColor(String priority) {
    switch (priority) {
      case 'gawat':
        return AppColors.error;
      case 'tinggi':
        return const Color(0xFFF59E0B);
      case 'rendah':
        return AppColors.success;
      default:
        return AppColors.accent;
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}