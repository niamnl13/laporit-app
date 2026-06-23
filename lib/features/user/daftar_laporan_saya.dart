import 'package:flutter/material.dart';
import 'package:laporit_app/core/constants/app_colors.dart';
import 'package:laporit_app/features/user/detail_laporan.dart';
import 'package:laporit_app/features/user/notifikasi_screen.dart';
import 'package:laporit_app/core/services/api_service.dart';

class DaftarLaporanSaya extends StatefulWidget {
  final int unreadCount;
  const DaftarLaporanSaya({super.key, this.unreadCount = 0});

  @override
  State<DaftarLaporanSaya> createState() => _DaftarLaporanSayaState();
}

class _DaftarLaporanSayaState extends State<DaftarLaporanSaya> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = "Semua";
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final reports = await ApiService.getMyReports();
      setState(() {
        _allLaporan = reports.map<Map<String, dynamic>>((r) {
          final status = r['status'] ?? 'pending';
          return {
            "id": '#LP-${r['id']}',
            "rawId": r['id'],
            "judul": r['jenis_kerusakan'] ?? '-',
            "kategori": r['jenis_kerusakan'] ?? '-',
            "deskripsi": r['deskripsi'] ?? '-',
            "lokasi": r['lokasi'] ?? '-',
            "nub": r['nub'] ?? '-',
            "foto": r['foto'],
            "tanggal": r['created_at']?.toString().substring(0, 10) ?? '-',
            "createdAtFull": r['created_at']?.toString() ?? '-',
            "tglEksekusi": r['tgl_eksekusi']?.toString() ?? '-',
            "rawStatus": status,
            "status": _statusLabel(status),
            "statusFilter": _statusFilter(status),
            "prioritas": (r['priority'] ?? 'normal').toUpperCase(),
            "statusColor": _statusColor(status),
            "statusBgColor": _statusBgColor(status),
            "prioritasColor": _prioritasColor(r['priority'] ?? 'normal'),
            "prioritasDot": _prioritasDot(r['priority'] ?? 'normal'),
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  final List<String> _filterList = ["Semua", "Pending", "Ditolak", "Diproses", "Selesai"];

  bool _isLoading = true;
  List<Map<String, dynamic>> _allLaporan = [];

  List<Map<String, dynamic>> get _filteredLaporan {
    return _allLaporan.where((laporan) {
      final matchFilter = _selectedFilter == "Semua" ||
          laporan["statusFilter"] == _selectedFilter;
      final matchSearch = _searchController.text.isEmpty ||
          laporan["judul"]
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          laporan["id"]
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();
  }

  int get _totalLaporan => _allLaporan.length;
  int get _selesaiLaporan =>
      _allLaporan.where((l) => l["statusFilter"] == "Selesai").length;
  
  String _statusLabel(String status) {
    switch (status) {
      case 'proses': return 'Diproses';
      case 'selesai': return 'Selesai';
      case 'ditolak': return 'Ditolak';
      default: return 'Pending';
    }
  }

  String _statusFilter(String status) {
    switch (status) {
      case 'proses': return 'Diproses';
      case 'selesai': return 'Selesai';
      case 'ditolak': return 'Ditolak';
      default: return 'Pending';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'proses': return const Color(0xFF0C447C);
      case 'selesai': return const Color(0xFF27500A);
      case 'ditolak': return const Color(0xFFA32D2D);
      default: return const Color(0xFF633806);
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'proses': return const Color(0xFFE6F1FB);
      case 'selesai': return const Color(0xFFEAF3DE);
      case 'ditolak': return const Color(0xFFFFEBEB);
      default: return const Color(0xFFFAEEDA);
    }
  }

  Color _prioritasColor(String priority) {
    switch (priority) {
      case 'gawat': return const Color(0xFFA32D2D);
      case 'tinggi': return const Color(0xFFA32D2D);
      case 'rendah': return const Color(0xFF888780);
      default: return const Color(0xFF854F0B);
    }
  }

  Color _prioritasDot(String priority) {
    switch (priority) {
      case 'gawat': return const Color(0xFFE24B4A);
      case 'tinggi': return const Color(0xFFE24B4A);
      case 'rendah': return const Color(0xFFB4B2A9);
      default: return const Color(0xFFEF9F27);
    }
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF5F6FA),
      child: Column(
        children: [
          // Header Navy 
          _buildHeader(),

          // Body scrollable
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stat Cards
                  _buildStatCards(),

                  // Section title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "RIWAYAT LAPORAN TERBARU",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF888780),
                            letterSpacing: 0.06 * 11,
                          ),
                        ),
                        Text(
                          "Lihat semua",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List laporan
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredLaporan.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                              itemCount: _filteredLaporan.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                return _buildLaporanCard(_filteredLaporan[index], context);
                              },
                            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  HEADER (navy background menyatu)
  // ─────────────────────────────────────────
  Widget _buildHeader() {
    return Material(
      color: const Color(0xFF1A2744),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Laporan Saya",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotifikasiScreen()),
                        ),
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      if (widget.unreadCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: widget.unreadCount > 9 ? BoxShape.rectangle : BoxShape.circle,
                              borderRadius: widget.unreadCount > 9 ? BorderRadius.circular(8) : null,
                              border: Border.all(color: const Color(0xFF1A2744), width: 1.5),
                            ),
                            child: Text(
                              widget.unreadCount > 99 ? '99+' : '${widget.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
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
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: "Cari ID tiket atau judul...",
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(Icons.search,
                      color: Colors.white.withOpacity(0.45), size: 20),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.10),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.15), width: 0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.15), width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.4), width: 0.5),
                  ),
                ),
              ),
            ),

            // Filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filterList.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedFilter = filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.20),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF1A2744)
                                  : Colors.white.withOpacity(0.7),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  STAT CARDS
  // ─────────────────────────────────────────
  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2744),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TOTAL LAPORAN",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white60,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$_totalLaporan",
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "semua status",
                    style: TextStyle(fontSize: 10, color: Colors.white38),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFFD4F5EE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "BERHASIL SELESAI",
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF0F6E56),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selesaiLaporan.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF085041),
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "laporan tuntas",
                    style: TextStyle(fontSize: 10, color: Color(0xFF0F6E56)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  EMPTY STATE
  // ─────────────────────────────────────────
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              "Tidak ada laporan ditemukan",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  KARTU LAPORAN
  // ─────────────────────────────────────────
  Widget _buildLaporanCard(
      Map<String, dynamic> laporan, BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                laporan["id"],
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF888780),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: laporan["statusBgColor"] as Color,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  laporan["status"],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: laporan["statusColor"] as Color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            laporan["judul"],
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFF1A1A1A),
              height: 1.35,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.account_tree_outlined,
                  size: 13, color: Color(0xFF888780)),
              const SizedBox(width: 4),
              Text(
                laporan["kategori"],
                style:
                    const TextStyle(fontSize: 11, color: Color(0xFF888780)),
              ),
              const SizedBox(width: 8),
              const Text("·",
                  style: TextStyle(fontSize: 12, color: Color(0xFF888780))),
              const SizedBox(width: 8),
              const Icon(Icons.calendar_today_outlined,
                  size: 12, color: Color(0xFF888780)),
              const SizedBox(width: 4),
              Text(
                laporan["tanggal"],
                style:
                    const TextStyle(fontSize: 11, color: Color(0xFF888780)),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100, height: 1, thickness: 0.5),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: laporan["prioritasDot"] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Prioritas ${_capitalize(laporan["prioritas"])}",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: laporan["prioritasColor"] as Color,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailLaporan(laporan: laporan),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      "Lihat detail",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_right,
                        size: 15, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}