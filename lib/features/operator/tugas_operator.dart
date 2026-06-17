import 'package:flutter/material.dart';
import 'package:laporit_app/core/constants/app_colors.dart';
import 'package:laporit_app/core/services/api_service.dart';
import 'package:laporit_app/features/operator/notifikasi_operator.dart';
import 'package:laporit_app/features/operator/update_progress.dart';
import 'package:laporit_app/features/operator/profil_operator.dart';

class TugasSayaOperator extends StatefulWidget {
  final int unreadCount;
  const TugasSayaOperator({super.key, this.unreadCount = 0});

  @override
  State<TugasSayaOperator> createState() => _TugasSayaOperatorState();
}

class _TugasSayaOperatorState extends State<TugasSayaOperator> {
  bool _isLoading = true;
  List<dynamic> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await ApiService.getMyTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selesaikanTugas(int reportId) async {
    // hapus dari lokal dulu untuk responsif, nanti kalau API gagal baru panggil _loadData() untuk refresh
    setState(() {
      _tasks.removeWhere((r) => r['id'] == reportId);
    });
    try {
      final now = DateTime.now().toString().substring(0, 10);
      final result = await ApiService.updateStatus(
        reportId: reportId,
        status: 'selesai',
        tglEksekusi: now,
      );
      if (result['success'] == true) {
        _showSnackBar('Tugas berhasil diselesaikan!', AppColors.success);
      } else {
        _loadData();
      }
    } catch (e) {
      _showSnackBar('Gagal menyelesaikan tugas', AppColors.error);
    }
  }

  Future<void> _tolakTugas(int reportId) async {
    // Tampilkan dialog konfirmasi sebelum menolak laporan
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Laporan?'),
        content: const Text('Laporan ini akan ditolak dan tidak bisa diambil kembali.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Tolak', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    setState(() {
      _tasks.removeWhere((t) => t['id'] == reportId); // Hapus dari lokal dulu untuk responsif
    });

    try {
      final result = await ApiService.updateStatus(
        reportId: reportId,
        status: 'ditolak',
      );
      if (result['success'] == true) {
        _showSnackBar('Laporan ditolak', AppColors.error);
      } else {
        _loadData();
      }
    } catch (e) {
      _showSnackBar('Gagal menolak laporan', AppColors.error);
    }
  }

  void _showUpdateDialog(Map<String, dynamic> report) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdateProgressOperator(report: report),
      ),
    );
    if (result == true) _loadData();
  }

  Widget _buildUpdateOption(BuildContext ctx, int reportId, String status,
      String label, IconData icon, Color color) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      onTap: () async {
        Navigator.pop(ctx);
        if (status == 'selesai') {
          await _selesaikanTugas(reportId);
        } else if (status == 'ditolak') {
          await _tolakTugas(reportId);
        }
      },
    );
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

  String _timeAgo(String? createdAt) {
    if (createdAt == null) return '-';
    final now = DateTime.now();
    final created = DateTime.tryParse(createdAt);
    if (created == null) return '-';
    final diff = now.difference(created);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari yang lalu';
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.grid_view_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                'Lapor IT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotifikasiOperator()),
                      );
                    },
                    icon: Icon(Icons.notifications_outlined,
                        color: AppColors.textPrimary, size: 26),
                  ),
                  if (widget.unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: widget.unreadCount > 9
                              ? BoxShape.rectangle
                              : BoxShape.circle,
                          borderRadius: widget.unreadCount > 9
                              ? BorderRadius.circular(9)
                              : null,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          widget.unreadCount > 99 ? '99+' : '${widget.unreadCount}',
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
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfilOperator(),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: const Text(
                    'OP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              // Header Judul
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tugas Saya',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pantau dan kelola laporan teknis aktif Anda.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // List
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: AppColors.accent))
                    : _tasks.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: _tasks.length,
                            itemBuilder: (context, index) {
                              return _buildTaskCard(_tasks[index]);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> report) {
    final id = report['id']?.toString() ?? '-';
    final deskripsi = report['deskripsi'] ?? '-';
    final jenis = report['jenis_kerusakan'] ?? '-';
    final lokasi = report['lokasi'] ?? '-';
    final pelapor = report['user']?['name'] ?? '-';
    final createdAt = report['created_at']?.toString();
    final priority = report['priority'] ?? 'normal';

    final priorityColor = switch (priority) {
      'gawat' => AppColors.error,
      'tinggi' => const Color(0xFFF59E0B),
      'rendah' => AppColors.success,
      _ => AppColors.accent,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ID + Status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID TICKET: #IT-$id',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.sync_rounded,
                              size: 12, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text(
                            'Diproses',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Deskripsi
                Text(
                  deskripsi,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Pelapor & Waktu
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pelapor',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                        Text(pelapor,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Icon(Icons.access_time_outlined,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Masuk',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                        Text(_timeAgo(createdAt),
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Lokasi
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        lokasi,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tombol-tombol
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Update Progress
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () => _showUpdateDialog(report),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text(
                      'Update Progress',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Selesai + Tolak
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () => _selesaikanTugas(report['id']),
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text(
                            'Selesai',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton.icon(
                          onPressed: () => _tolakTugas(report['id']),
                          icon: Icon(Icons.close_rounded,
                              size: 18, color: AppColors.error),
                          label: Text(
                            'Tolak',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_outlined, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Belum ada tugas aktif',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ambil tugas dari halaman Tugas',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}