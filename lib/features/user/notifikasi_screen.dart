import 'package:flutter/material.dart';
import 'package:laporit_app/core/services/api_service.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  bool _isLoading = true;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await ApiService.getNotifications();
      setState(() {
        _notifications = notifications ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _tandaiSemuaDibaca() async {
    await ApiService.readAllNotifications();
    _loadData();
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

  IconData _getIcon(String tipe) {
    switch (tipe) {
      case 'status': return Icons.update;
      case 'tugas': return Icons.support_agent;
      default: return Icons.notifications_outlined;
    }
  }

  Color _getIconBg(String tipe) {
    switch (tipe) {
      case 'status': return const Color(0xFF0A9396);
      case 'tugas': return const Color(0xFF0A2647);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final terbaru = _notifications.where((n) => n['is_read'] == 0 || n['is_read'] == false).toList();
    final lama = _notifications.where((n) => n['is_read'] == 1 || n['is_read'] == true).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _tandaiSemuaDibaca,
            child: const Text(
              "Tandai semua dibaca",
              style: TextStyle(
                color: Color(0xFF0A9396),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF0A9396),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0A9396)))
            : _notifications.isEmpty
                ? _buildEmptyState()
                : ListView(
                    padding: const EdgeInsets.only(top: 8, bottom: 40),
                    children: [
                      ...terbaru.map((notif) => _buildNotifBaru(notif)),
                      if (lama.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            "TERDAHULU",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9CA3AF),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ...lama.map((notif) => _buildNotifLama(notif)),
                      const SizedBox(height: 24),
                      Column(
                        children: [
                          Icon(Icons.done_all_rounded,
                              size: 36, color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          Text(
                            "Semua notifikasi telah diperiksa",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Tidak ada notifikasi',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifBaru(Map<String, dynamic> notif) {
    final tipe = notif['tipe'] ?? 'informasi';
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getIconBg(tipe),
              shape: BoxShape.circle,
            ),
            child: Icon(_getIcon(tipe), color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notif['judul'] ?? '-',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A9396),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notif['pesan'] ?? '-',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _timeAgo(notif['created_at']),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifLama(Map<String, dynamic> notif) {
    final tipe = notif['tipe'] ?? 'informasi';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              shape: BoxShape.circle,
            ),
            child: Icon(_getIcon(tipe), color: const Color(0xFF6B7280), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif['judul'] ?? '-',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  notif['pesan'] ?? '-',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _timeAgo(notif['created_at']),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}