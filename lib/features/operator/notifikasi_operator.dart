import 'package:flutter/material.dart';
import 'package:laporit_app/core/constants/app_colors.dart';
import 'package:laporit_app/core/services/api_service.dart';

class NotifikasiOperator extends StatefulWidget {
  const NotifikasiOperator({super.key});

  @override
  State<NotifikasiOperator> createState() =>
      _NotifikasiOperatorState();
}

class _NotifikasiOperatorState extends State<NotifikasiOperator> {
  String _selectedTab = 'Semua';
  bool _isLoading = true;
  List<dynamic> _notifications = [];

  final List<String> _tabs = ['Semua', 'Tugas', 'Status', 'Informasi'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await ApiService.getNotifications();
      print('Notifikasi: $notifications');
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      print ('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _readAll() async {
    await ApiService.readAllNotifications();
    _loadData();
  }

  List<dynamic> get _filtered {
    if (_selectedTab == 'Semua') return _notifications;
    return _notifications
        .where((n) => n['tipe'] == _selectedTab.toLowerCase())
        .toList();
  }

  // =============================================
  // HELPERS
  // =============================================
  IconData _getIcon(String tipe) {
    switch (tipe) {
      case 'tugas': return Icons.task_alt_rounded;
      case 'status': return Icons.info_outline_rounded;
      default: return Icons.notifications_outlined;
    }
  }

  Color _getIconColor(String tipe) {
    switch (tipe) {
      case 'tugas': return AppColors.accent;
      case 'status': return AppColors.success;
      default: return const Color(0xFFF59E0B);
    }
  }

  Color _getIconBg(String tipe) {
    switch (tipe) {
      case 'tugas': return AppColors.accent.withOpacity(0.12);
      case 'status': return AppColors.success.withOpacity(0.12);
      default: return const Color(0xFFF59E0B).withOpacity(0.12);
    }
  }

  String _getTipeLabel(String tipe) {
    switch (tipe) {
      case 'tugas': return 'TUGAS BARU';
      case 'status': return 'STATUS UPDATE';
      default: return 'INFORMASI';
    }
  }

  Color _getTipeColor(String tipe) {
    switch (tipe) {
      case 'tugas': return AppColors.accent;
      case 'status': return AppColors.success;
      default: return const Color(0xFFF59E0B);
    }
  }

  String _timeAgo(String? createdAt) {
    if (createdAt == null) return '-';
    final now = DateTime.now();
    final created = DateTime.tryParse(createdAt);
    if (created == null) return '-';
    final diff = now.difference(created);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari yang lalu';
  }

  @override
  Widget build(BuildContext context) {
    // Pisahkan terbaru (belum dibaca) dan sebelumnya (sudah dibaca)
    final terbaru = _filtered.where((n) => n['is_read'] == 0 || n['is_read'] == false).toList();
    final sebelumnya = _filtered.where((n) => n['is_read'] == 1 || n['is_read'] == true).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _readAll,
            child: Text(
              'Tandai semua dibaca',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.accent,
        child: Column(
          children: [
            // Filter Tabs
            _buildTabs(),

            // List 
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.accent))
                  : _filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          children: [
                            if (terbaru.isNotEmpty) ...[
                              _buildSectionLabel('TERBARU'),
                              ...terbaru.map((n) => _buildNotifCard(n)),
                            ],
                            if (sebelumnya.isNotEmpty) ...[
                              _buildSectionLabel('SEBELUMNYA'),
                              ...sebelumnya.map((n) => _buildNotifCard(n)),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // TABS
  // =============================================
  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tabs.map((tab) {
            final isSelected = _selectedTab == tab;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // =============================================
  // SECTION LABEL
  // =============================================
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF888780),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // =============================================
  // NOTIF CARD
  // =============================================
  Widget _buildNotifCard(Map<String, dynamic> notif) {
    final tipe = notif['tipe'] ?? 'informasi';
    // Anggap is_read bisa berupa int (0/1) atau bool (true/false)
    final isRead = notif['is_read'] == 1 || notif['is_read'] == true;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : AppColors.accent.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRead ? const Color(0xFFEAEAEA) : AppColors.accent.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _getIconBg(tipe),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIcon(tipe), color: _getIconColor(tipe), size: 20),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getTipeLabel(tipe),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _getTipeColor(tipe),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _timeAgo(notif['created_at']),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF888780),
                          ),
                        ),
                        if (!isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notif['judul'] ?? '-',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notif['pesan'] ?? '-',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888780),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
          Icon(Icons.notifications_off_outlined,
              size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}