import 'package:flutter/material.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final List<Map<String, dynamic>> _notifikasiBaru = [
    {
      "icon": Icons.update,
      "iconBg": Color(0xFF0A9396),
      "judul": "Status Laporan Diperbarui",
      "pesan":
          "Laporan perbaikan jaringan IT di Ruang Rapat A telah berubah status menjadi ",
      "highlight": "Diproses.",
      "waktu": "2 menit yang lalu",
      "isRead": false,
      "hasDetail": false,
    },
    {
      "icon": Icons.support_agent,
      "iconBg": Color(0xFF0A2647),
      "judul": "Pesan Baru dari Operator",
      "pesan":
          '"Halo Bpk. Budi, teknisi kami sedang menuju lokasi untuk pengecekan hardware. Mohon standby."',
      "highlight": "",
      "waktu": "15 menit yang lalu",
      "isRead": false,
      "hasDetail": false,
    },
  ];

  final List<Map<String, dynamic>> _notifikasiLama = [
    {
      "icon": Icons.description_outlined,
      "iconBg": Color(0xFFE5E7EB),
      "iconColor": Color(0xFF6B7280),
      "judul": "Tanda Terima Laporan",
      "pesan":
          'Laporan #IT-99283 "Kerusakan Monitor" telah diterima oleh sistem kami.',
      "highlight": "",
      "waktu": "3 jam yang lalu",
      "isRead": true,
      "hasDetail": true,
    },
    {
      "icon": Icons.check_circle_outline,
      "iconBg": Color(0xFFE5E7EB),
      "iconColor": Color(0xFF6B7280),
      "judul": "Laporan Selesai",
      "pesan":
          "Laporan penggantian toner printer di Lantai 4 telah ditandai sebagai selesai oleh teknisi.",
      "highlight": "",
      "waktu": "Kemarin, 14:20",
      "isRead": true,
      "hasDetail": false,
    },
    {
      "icon": Icons.notifications_outlined,
      "iconBg": Color(0xFFE5E7EB),
      "iconColor": Color(0xFF6B7280),
      "judul": "Pemeliharaan Sistem",
      "pesan":
          "Pemberitahuan: Aplikasi Lapor IT akan mengalami downtime pemeliharaan malam ini pukul 23:00.",
      "highlight": "",
      "waktu": "2 hari yang lalu",
      "isRead": true,
      "hasDetail": false,
    },
  ];

  bool _isRefreshing = false;

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isRefreshing = false);
  }

  void _tandaiSemuaDibaca() {
    setState(() {
      for (var n in _notifikasiBaru) {
        n["isRead"] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
        onRefresh: _onRefresh,
        color: const Color(0xFF0A9396),
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 40),
          children: [
            // ── Label Memperbarui ──
            if (_isRefreshing)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0A9396),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "MEMPERBARUI...",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF0A9396),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Notifikasi Baru ──
            ..._notifikasiBaru.map((notif) => _buildNotifBaru(notif)),

            // ── Label Terdahulu ──
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

            // ── Notifikasi Lama ──
            ..._notifikasiLama.map((notif) => _buildNotifLama(notif)),

            // ── Footer Semua Sudah Dibaca ──
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

  // ── Notifikasi Baru (belum dibaca) ──
  Widget _buildNotifBaru(Map<String, dynamic> notif) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: notif["iconBg"],
              shape: BoxShape.circle,
            ),
            child: Icon(notif["icon"], color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),

          // Konten
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul + Dot
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notif["judul"],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (!notif["isRead"])
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

                // Pesan
                if (notif["highlight"] != null &&
                    notif["highlight"].toString().isNotEmpty)
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF374151),
                          height: 1.5),
                      children: [
                        TextSpan(text: notif["pesan"]),
                        TextSpan(
                          text: notif["highlight"],
                          style: const TextStyle(
                            color: Color(0xFF0A9396),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    notif["pesan"],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),

                const SizedBox(height: 8),

                // Waktu
                Text(
                  notif["waktu"],
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Notifikasi Lama (sudah dibaca) ──
  Widget _buildNotifLama(Map<String, dynamic> notif) {
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
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: notif["iconBg"],
              shape: BoxShape.circle,
            ),
            child: Icon(notif["icon"],
                color: notif["iconColor"] ?? const Color(0xFF6B7280),
                size: 20),
          ),
          const SizedBox(width: 14),

          // Konten
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif["judul"],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  notif["pesan"],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      notif["waktu"],
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                    if (notif["hasDetail"] == true) ...[
                      const Text(
                        "  •  ",
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF9CA3AF)),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigasi ke detail laporan
                        },
                        child: const Text(
                          "Lihat Detail",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF0A9396),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}