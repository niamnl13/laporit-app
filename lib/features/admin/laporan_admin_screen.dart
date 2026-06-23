import 'package:flutter/material.dart';
import 'package:laporit_app/core/constants/app_colors.dart';
import 'package:laporit_app/core/services/api_service.dart';

class LaporanAdminScreen extends StatefulWidget {
  const LaporanAdminScreen({super.key});

  @override
  State<LaporanAdminScreen> createState() => _LaporanAdminScreenState();
}

class _LaporanAdminScreenState extends State<LaporanAdminScreen> {
  List<dynamic> _reports = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  String _activeFilter = 'Semua';
  String _searchQuery = '';

  final List<String> _filters = ['Semua', 'Tertunda', 'Diproses', 'Selesai', 'Ditolak'];

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
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat laporan', AppColors.error);
    }
  }

  void _applyFilter() {
    List<dynamic> result = List.from(_reports);

    // Filter status
    if (_activeFilter != 'Semua') {
      final map = {
        'Tertunda': 'pending',
        'Diproses': 'proses',
        'Selesai': 'selesai',
        'Ditolak': 'ditolak',
      };
      result = result.where((r) => r['status'] == map[_activeFilter]).toList();
    }

    // Filter search
    if (_searchQuery.isNotEmpty) {
      result = result.where((r) {
        final id = r['id']?.toString() ?? '';
        final desk = (r['deskripsi'] ?? '').toString().toLowerCase();
        final jenis = (r['jenis_kerusakan'] ?? '').toString().toLowerCase();
        final q = _searchQuery.toLowerCase();
        return id.contains(q) || desk.contains(q) || jenis.contains(q);
      }).toList();
    }

    setState(() => _filtered = result);
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _updateStatus(dynamic report, String newStatus) async {
    final id = report['id'];
    try {
      await ApiService.updateReportStatus(id, newStatus);
      await _loadData();
      _showSnackBar('Status berhasil diubah ke ${_statusLabel(newStatus)}', AppColors.success);
    } catch (e) {
      _showSnackBar('Gagal mengubah status', AppColors.error);
    }
  }

  void _showStatusPicker(dynamic report) {
    final statuses = ['pending', 'proses', 'selesai', 'ditolak'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ubah Status Laporan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '#TK-${report['id']} • ${report['deskripsi'] ?? ''}',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ...statuses.map((s) {
              final isCurrent = report['status'] == s;
              final color = _statusColor(s);
              return InkWell(
                onTap: isCurrent
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        _updateStatus(report, s);
                      },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isCurrent ? color.withOpacity(0.12) : const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(12),
                    border: isCurrent ? Border.all(color: color, width: 1.5) : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _statusLabel(s),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent ? color : AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (isCurrent)
                        Icon(Icons.check_rounded, color: color, size: 18),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _reports.length;
    final aktif = _reports.where((r) => r['status'] == 'proses').length;
    final selesai = _reports.where((r) => r['status'] == 'selesai').length;

    return SafeArea(
      child: Column(
        children: [
          // ── Search + Filter Header ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                // Search bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          onChanged: (v) {
                            _searchQuery = v;
                            _applyFilter();
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari laporan atau ID tiket...',
                            hintStyle: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary),
                            prefixIcon: Icon(Icons.search,
                                color: AppColors.textSecondary, size: 20),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.filter_list_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Filter chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final f = _filters[i];
                      final active = _activeFilter == f;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _activeFilter = f);
                          _applyFilter();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primary
                                : const Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: active
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: active
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // ── Summary Row ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                _buildSummaryChip(
                  label: 'Total Laporan',
                  value: '$total',
                  color: AppColors.primary,
                  large: true,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      _buildSummaryChipSmall(
                          'AKTIF', '$aktif', AppColors.accent),
                      const SizedBox(height: 8),
                      _buildSummaryChipSmall(
                          'SELESAI', '$selesai', AppColors.success),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── List ──
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.primary))
                  : _filtered.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) =>
                              _buildReportCard(_filtered[i]),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip({
    required String label,
    required String value,
    required Color color,
    bool large = false,
  }) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildSummaryChipSmall(String label, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
          Row(
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color)),
              const SizedBox(width: 4),
              Icon(
                label == 'AKTIF'
                    ? Icons.calendar_today_outlined
                    : Icons.check_circle_outline_rounded,
                color: color,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final status = report['status'] ?? 'pending';
    final prioritas = (report['priority'] ?? report['prioritas'] ?? 'normal').toString();
    final jenis = report['jenis_kerusakan'] ?? '-';
    final lokasi = report['lokasi'] ?? '-';
    final deskripsi = report['deskripsi'] ?? '-';
    final createdAt = report['created_at']?.toString() ?? '';
    final id = report['id']?.toString() ?? '-';
    final pelapor = report['nama_pelapor'] ?? report['user']?['name'] ?? 'User';
    final statusColor = _statusColor(status);
    final prioritasColor = _prioritasColor(prioritas);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ID + badges
                Row(
                  children: [
                    Text(
                      '#LP-$id',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: prioritasColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        prioritas.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: prioritasColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Deskripsi
                Text(
                  deskripsi,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Meta info
                Row(
                  children: [
                    Icon(Icons.build_outlined,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(jenis,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 12),
                    Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(lokasi,
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: Icon(Icons.person,
                          size: 12, color: AppColors.primary),
                    ),
                    const SizedBox(width: 6),
                    Text(pelapor,
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Icon(Icons.access_time,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      createdAt.length > 10
                          ? createdAt.substring(0, 10)
                          : createdAt,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Bottom action bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FC),
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _statusLabel(status),
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Update status button
                GestureDetector(
                  onTap: () => _showStatusPicker(report),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.edit_rounded,
                            color: Colors.white, size: 13),
                        SizedBox(width: 6),
                        Text(
                          'Ubah Status',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Tidak ada laporan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            'Coba ubah filter atau kata kunci',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
      case 'high':    return AppColors.error;
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
}