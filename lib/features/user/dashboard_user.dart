import 'package:flutter/material.dart';
import 'package:laporit_app/core/constants/app_colors.dart';
import 'package:laporit_app/features/user/add_laporan_baru.dart';
import 'package:laporit_app/features/user/notifikasi_screen.dart';
import 'package:laporit_app/features/user/daftar_laporan_saya.dart'; 
import 'package:laporit_app/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardUser extends StatefulWidget {
  const DashboardUser({super.key});

  @override
  State<DashboardUser> createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
  String _userName = 'User';
  bool _isLoading = true;
  List<dynamic> _reports = [];

  int get _total => _reports.length;
  int get _diproses => _reports.where((r) => r['status'] == 'proses').length;
  int get _selesai => _reports.where((r) {
    if (r['status'] != 'selesai') return false;
    final tgl = r['tgl_eksekusi']?.toString();
    if (tgl == null) return false;
    final now = DateTime.now();
    final eksekusi = DateTime.tryParse(tgl);
    if (eksekusi == null) return false;
    return eksekusi.month == now.month && eksekusi.year == now.year;
  }).length;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  int _unreadCount = 0;

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('name') ?? 'User';

      final results = await Future.wait([
        ApiService.getMyReports(),
        ApiService.getNotifications(),
      ]);

      final reports = results[0] as List<dynamic>;
      final notifications = results[1] as List<dynamic>;

      final unread = notifications
          .where((n) => n['is_read'] == 0 || n['is_read'] == false)
          .length;
      
      print('Total notifikasi: ${notifications.length}');
      print('Unread count: $unread');
      print('Data notifikasi: $notifications');

      setState(() {
        _userName = name;
        _reports = reports;
        _unreadCount = unread;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'proses': return 'Diproses';
      case 'selesai': return 'Selesai';
      case 'ditolak': return 'Ditolak';
      default: return 'Pending';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'proses': return const Color(0xFF00B4D8);
      case 'selesai': return Colors.green;
      case 'ditolak': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Selamat Pagi,",
                  style: TextStyle(
                    fontSize: 13, 
                    color: Colors.grey),
                  ),
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotifikasiScreen()),
                  );
                  _loadData(); // refresh badge setelah kembali
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: _unreadCount > 9 ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius: _unreadCount > 9 ? BorderRadius.circular(9) : null,
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
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Banner "Ada Kendala IT?" ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2647),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ada Kendala IT?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Laporkan masalah perangkat\natau jaringan Anda sekarang.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push( // await untuk refresh setelah kembali
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddLaporanBaru()),
                        );
                        _loadData(); // refresh data setelah kembali dari form laporan baru
                      },
                      icon: const Icon(Icons.add_circle_outline,
                          size: 18, color: Colors.white),
                      label: const Text(
                        "Buat Laporan Baru",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4D8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // ── Statistik ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TOTAL LAPORAN SAYA",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.insert_chart_outlined,
                      color: Colors.blue, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Total besar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100, width: 0.5),
              ),
              child: Text(
                _isLoading ? '...' : '$_total',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1,
                ),
              ),
            ),

            const SizedBox(height: 10),
            
            // Sedang diproses + Selesai bulan ini
            Row(
              children: [
                _buildStatCard(
                  icon: Icons.sync,
                  iconColor: const Color(0xFF00B4D8),
                  label: "SEDANG DIPROSES ",
                  value: _isLoading ? '...' : '$_diproses',
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: Colors.green,
                  label: "SELESAI BULAN INI",
                  value: _isLoading ? '...' : '$_selesai',
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Laporan Terkini ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Laporan Terkini",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DaftarLaporanSaya(unreadCount: _unreadCount)),
                    );
                  },
                  child: Text(
                    "Lihat Semua",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_reports.isEmpty)
              const Center(
                child: Text('Belum ada laporan',
                style: TextStyle(color: Colors.grey)),
              )
            else
              ..._reports.take(3).map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildRecentTicket(
                  icon: _getIcon(r['jenis_kerusakan'] ?? ''),
                  title: r['jenis_kerusakan'] ?? '-',
                  subtitle: r['deskripsi'] ?? '-',
                  time: r['created_at']?.toString().substring(0, 10) ?? '-',
                  status: _statusLabel(r['status'] ?? 'pending'),
                  statusColor: _statusColor(r['status'] ?? 'pending'),
                ),
              )
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      ),
    );
  }

  IconData _getIcon(String jenis) {
    final j = jenis.toLowerCase();
    if (j.contains('jaringan') || j.contains('wifi') || j.contains('vpn')) {
      return Icons.wifi;
    } else if (j.contains('printer') || j.contains('scanner')) {
      return Icons.print;
    } else if (j.contains('komputer') || j.contains('monitor') || j.contains('laptop')) {
      return Icons.monitor;
    } else if (j.contains('server')) {
      return Icons.dns;
    } else if (j.contains('software') || j.contains('email') || j.contains('office')) {
      return Icons.computer;
    } else {
      return Icons.build_outlined;
    }
  }

  // ── Stat Card dengan icon ──
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Recent Ticket Card ──
  Widget _buildRecentTicket({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black87, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}