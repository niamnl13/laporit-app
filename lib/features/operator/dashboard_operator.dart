import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laporit_app/core/constants/app_colors.dart';
import 'package:laporit_app/core/services/api_service.dart';
import 'package:laporit_app/features/auth/login.dart';
import 'package:laporit_app/features/operator/notifikasi_operator.dart';
import 'package:laporit_app/features/operator/panduan_operator.dart';
import 'package:laporit_app/features/operator/daftar_tugas_operator.dart';
import 'package:laporit_app/features/operator/riwayat_operator.dart';
import 'package:laporit_app/features/operator/profil_operator.dart';
import 'package:laporit_app/features/operator/tugas_operator.dart';

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
  int _unreadCount = 0; // Jumlah notifikasi belum dibaca
  Key _tugasSayaKey = UniqueKey(); // untuk paksa rebuild TugasSaya saat tab dibuka
  Key _riwayatKey = UniqueKey(); // untuk paksa rebuild Riwayat saat tab dibuka


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

      final results = await Future.wait([
        ApiService.getAllReports(),
        ApiService.getNotifications(),
      ]);

      final reports = results[0] as List<dynamic>;
      final notifications = results[1] as List<dynamic>;

      final unread = notifications
          .where((n) => n['is_read'] == 0 || n['is_read'] == false)
          .length;

      setState(() {
        _operatorName = name;
        _reports = reports;
        _unreadCount = unread;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat data', AppColors.error);
    }
  }
  Future<void> _bukaNotifikasi() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotifikasiOperator()),
    );
    _loadData(); // refresh badge setelah kembali
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
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildBerandaPage(),
          TugasOperator(unreadCount: _unreadCount),
          TugasSayaOperator(key: _tugasSayaKey, unreadCount: _unreadCount),// paksa rebuild saat tab dibuka
          RiwayatOperator(key: _riwayatKey, unreadCount: _unreadCount),
          ProfilOperator(unreadCount: _unreadCount),
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
              onPressed: _bukaNotifikasi,
              icon: Icon(Icons.notifications_outlined,
                  color: AppColors.textPrimary, size: 28),
            ),
            if (_unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: _unreadCount > 9
                        ? BoxShape.rectangle
                        : BoxShape.circle,
                    borderRadius: _unreadCount > 9
                        ? BorderRadius.circular(9)
                        : null,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    _unreadCount > 99 ? '99+' : '$_unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
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
        ...tugasBaru.map((r) => _buildTugasBaruCard(r)),
    ],
  );
}

Widget _buildTugasBaruCard(Map<String, dynamic> report) {
  final priority = report['priority'] ?? 'normal';
  final id = report['id']?.toString() ?? '-';
  final deskripsi = report['deskripsi'] ?? '-';
  final lokasi = report['lokasi'] ?? '-';
  final pelapor = report['user']?['name'] ?? '-';
  final createdAt = report['created_at']?.toString() ?? '';
  final timeAgo = createdAt.length > 10 ? createdAt.substring(0, 10) : createdAt;

  final priorityColor = switch (priority) {
    'gawat' => AppColors.error,
    'tinggi' => const Color(0xFFF59E0B),
    'rendah' => AppColors.success,
    _ => AppColors.accent,
  };

  return Container(
    margin: const EdgeInsets.only(bottom: 14),
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
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            Text('#ID-$id',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(timeAgo,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 10),
        Text(deskripsi,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(lokasi,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(width: 16),
            Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('Pelapor: $pelapor',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
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
      {'icon': Icons.menu_book_outlined, 'label': 'Panduan', 'color': const Color(0xFFF59E0B)},
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
        Column(
          children: aksi.map((a) {
            final color = a['color'] as Color;
            return SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  if (a['label'] == 'Panduan') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PanduanOperator()),
                    );
                  } else {
                    _showSnackBar('Fitur segera hadir!', AppColors.accent);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(a['icon'] as IconData, color: color, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        a['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: color,
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
  // BOTTOM NAV
  // =============================================
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) {
        setState(() {
          _currentIndex = i;
          if (i == 2) {
            _tugasSayaKey = UniqueKey(); // paksa rebuild
          }
          if (i == 3) {
            _riwayatKey = UniqueKey();
          }
        });
        if (i == 0) {
          _loadData();
        }
      },
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
            icon: Icon(Icons.assignment_turned_in_outlined), label: 'Tugas Saya'),
        BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded), label: 'Riwayat'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
    );
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