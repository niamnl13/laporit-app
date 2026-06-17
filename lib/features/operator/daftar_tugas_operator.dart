import 'package:flutter/material.dart';
import 'package:laporit_app/core/constants/app_colors.dart';
import 'package:laporit_app/core/services/api_service.dart';
import 'package:laporit_app/features/operator/notifikasi_operator.dart';

class TugasOperator extends StatefulWidget {
  final int unreadCount; // tgl 11-06-2024: tambahkan parameter untuk jumlah notifikasi belum dibaca
  const TugasOperator({super.key, this.unreadCount = 0}); // tgl 11-06-2024: tambahkan parameter untuk jumlah notifikasi belum dibaca

  @override
  State<TugasOperator> createState() => _TugasOperatorState();
}

const List<String> _tugasFilterList = [
    'Semua',
    'Kerusakan Jaringan',
    'Kerusakan Fisik Komputer',
    'Software Error',
    'Printer / Scanner',
    'Server',
    'Email / Office 365',
    'Lainnya',
  ];

class _TugasOperatorState extends State<TugasOperator> {
  bool _isLoading = true;
  List<dynamic> _reports = [];
  String _selectedFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> get _semua => _reports
      .where((r) => r['status'] == 'pending')
      .toList();

  List<dynamic> get _filtered {
    return _semua.where((r) {
      final jenis = (r['jenis_kerusakan'] ?? '').toString().toLowerCase();
      final deskripsi = (r['deskripsi'] ?? '').toString().toLowerCase();
      final id = (r['id'] ?? '').toString();
      final search = _searchController.text.toLowerCase();

      final matchSearch = search.isEmpty ||
          deskripsi.contains(search) ||
          id.contains(search) ||
          jenis.contains(search);

      final matchFilter = _selectedFilter == 'Semua' ||
      jenis.toLowerCase() == _selectedFilter.toLowerCase();

      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final reports = await ApiService.getAllReports();
      setState(() {
        _reports = reports ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'gawat': return const Color(0xFFA32D2D);
      case 'tinggi': return const Color(0xFF854F0B);
      case 'rendah': return const Color(0xFF888780);
      default: return const Color(0xFF0C447C);
    }
  }

  Color _priorityBgColor(String priority) {
    switch (priority) {
      case 'gawat': return const Color(0xFFFFEBEB);
      case 'tinggi': return const Color(0xFFFAEEDA);
      case 'rendah': return const Color(0xFFF0F0F0);
      default: return const Color(0xFFE6F1FB);
    }
  }

  String _priorityLabel(String priority) {
    switch (priority) {
      case 'gawat': return 'GAWAT';
      case 'tinggi': return 'TINGGI';
      case 'rendah': return 'RENDAH';
      default: return 'NORMAL';
    }
  }

  IconData _kategoriIcon(String jenis) {
    final j = jenis.toLowerCase();
    if (j.contains('jaringan') || j.contains('network') || j.contains('vpn')) {
      return Icons.wifi_outlined;
    } else if (j.contains('printer') || j.contains('scanner') || j.contains('hardware')) {
      return Icons.print_outlined;
    } else if (j.contains('software') || j.contains('email') || j.contains('office')) {
      return Icons.computer_outlined;
    } else if (j.contains('server')) {
      return Icons.dns_outlined;
    } else {
      return Icons.build_outlined;
    }
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
            children: [
              // ── Header ──
              _buildHeader(),

              // ── Search ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _buildSearch(),
              ),

              // ── Filter Chips ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _buildFilterChips(),
              ),

              // ── Stat Cards ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _buildStatCards(),
              ),

              // ── Header List ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Laporan Terbaru',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Terbaru (${_filtered.length})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── List ──
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: AppColors.accent))
                    : _filtered.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              return _buildTugasCard(_filtered[index]);
                            },
                          ),
              ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
          Stack(
            children: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotifikasiOperator()),
                ),
                icon: Icon(Icons.notifications_outlined,
                    color: AppColors.textPrimary, size: 26),
              ),
              if (widget.unreadCount > 0) // tgl 11-06-2024: tampilkan badge jumlah notifikasi belum dibaca
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
        ],
      ),
    );
  }

  // =============================================
  // SEARCH
  // =============================================
  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Cari ID Tiket atau Judul...',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  // =============================================
  // FILTER CHIPS
  // =============================================
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _tugasFilterList.map((String f) {
          final isSelected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (f == 'Semua') ...[
                      Icon(
                        Icons.filter_list_rounded,
                        size: 14,
                        color: isSelected ? Colors.white : Colors.black54,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      f,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // =============================================
  // STAT CARDS
  // =============================================
  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiket Masuk',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_semua.length}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rata-rata\nRespon',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '12m',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =============================================
  // TUGAS CARD
  // =============================================
  Widget _buildTugasCard(Map<String, dynamic> report) {
    final isPending = report['status'] == 'pending';
    final priority = report['priority'] ?? 'normal';
    final priorityColor = _priorityColor(priority);
    final priorityBg = _priorityBgColor(priority);
    final id = report['id']?.toString() ?? '-';
    final jenis = report['jenis_kerusakan'] ?? '-';
    final deskripsi = report['deskripsi'] ?? '-';
    final createdAt = report['created_at']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID + Priority badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#IT-$id',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _priorityLabel(priority),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: priorityColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Deskripsi / Judul
          Text(
            deskripsi,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Kategori + Waktu
          Row(
            children: [
              Icon(_kategoriIcon(jenis),
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                jenis,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                _timeAgo(createdAt),
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tombol
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: isPending
                  ? () => _ambilTugas(report['id'])
                  : () => _selesaikanTugas(report['id']),
              icon: Icon(
                isPending ? Icons.assignment_outlined : Icons.check_circle_outline,
                size: 18,
              ),
              label: Text(
                isPending ? 'Ambil Tugas' : 'Selesaikan',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isPending ? AppColors.primary : AppColors.success,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // EMPTY STATE
  // =============================================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Tidak ada tugas',
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