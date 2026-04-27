import 'package:flutter/material.dart';

class DetailLaporan extends StatefulWidget {
  final Map<String, dynamic> laporan;

  const DetailLaporan({super.key, required this.laporan});

  @override
  State<DetailLaporan> createState() => _DetailLaporanState();
}

class _DetailLaporanState extends State<DetailLaporan> {
  final TextEditingController _komentarController = TextEditingController();

  final List<Map<String, dynamic>> _riwayat = [
    {
      "title": "Laporan Diterima",
      "time": "24 Okt 2023, 09:15",
      "subtitle": "Menunggu verifikasi sistem...",
      "subtitleColor": Colors.grey,
      "isDone": true,
      "isActive": false,
      "icon": Icons.check,
      "iconBg": Color(0xFF10B981),
    },
    {
      "title": "Ditugaskan ke Operator",
      "time": "24 Okt 2023, 10:30",
      "subtitle": "Tech: Ahmad Subarjo",
      "subtitleColor": Color(0xFF374151),
      "isDone": true,
      "isActive": false,
      "icon": Icons.assignment_ind_outlined,
      "iconBg": Color(0xFF00B4D8),
    },
    {
      "title": "Sedang Dikerjakan",
      "time": "24 Okt 2023, 14:00",
      "subtitle": "Teknisi sedang menuju lokasi Lantai 3.",
      "subtitleColor": Color(0xFF0A9396),
      "isDone": false,
      "isActive": true,
      "icon": Icons.build_outlined,
      "iconBg": Color(0xFF0A2647),
    },
    {
      "title": "Selesai",
      "time": "Estimasi Selesai: 24 Okt, 16:30",
      "subtitle": "",
      "subtitleColor": Colors.grey,
      "isDone": false,
      "isActive": false,
      "icon": Icons.flag_outlined,
      "iconBg": Color(0xFFD1D5DB),
    },
  ];

  final List<Map<String, dynamic>> _komentar = [
    {
      "nama": "Ahmad Subarjo",
      "role": "Operator IT",
      "waktu": "14:15",
      "pesan":
          "Halo Pak, saya sudah di depan Ruang Rapat B tapi ruangannya terkunci. Bisa minta tolong dibukakan?",
      "inisial": "AS",
      "avatarColor": Color(0xFF0A2647),
    },
  ];

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
          "Detail Laporan",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "Lapor IT",
                style: TextStyle(
                  color: const Color(0xFF0A9396),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header Card ──
                  Container(
                    width: double.infinity,
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
                        // ID + Badge Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.laporan["id"] ?? "#IT-2023-0892",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A9396),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F7FA),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.laporan["status"] ?? "Diproses",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00B4D8),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Judul
                        Text(
                          widget.laporan["judul"] ??
                              "Laptop Tidak Bisa Terhubung ke Wi-Fi Kantor",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Progress
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Progress Penanganan",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black54),
                            ),
                            Text(
                              "75%",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: 0.75,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF0A9396)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Info Cards ──
                  _buildInfoCard(
                    icon: Icons.category_outlined,
                    iconBg: const Color(0xFF0A2647),
                    label: "KATEGORI",
                    value: widget.laporan["kategori"] ?? "Hardware & Network",
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    icon: Icons.location_on_outlined,
                    iconBg: const Color(0xFF0A9396),
                    label: "LOKASI",
                    value: "Lantai 3, Ruang Rapat B",
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    icon: Icons.priority_high,
                    iconBg: const Color(0xFFEF4444),
                    label: "PRIORITAS",
                    value: _getPrioritas(),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    icon: Icons.calendar_today_outlined,
                    iconBg: const Color(0xFF6B7280),
                    label: "TANGGAL LAPOR",
                    value: widget.laporan["tanggal"] != null
                        ? "${widget.laporan["tanggal"]}, 09:15 WIB"
                        : "24 Okt 2023, 09:15 WIB",
                  ),

                  const SizedBox(height: 24),

                  // ── Deskripsi Masalah ──
                  _buildSectionTitle("Deskripsi Masalah"),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Sudah mencoba melakukan restart laptop sebanyak 3 kali, namun daftar Wi-Fi kantor (WIFI-OFFICE-01) tidak muncul di pilihan koneksi. Wi-Fi lain seperti tethering HP muncul secara normal. Masalah ini terjadi sejak pembaruan sistem operasi kemarin sore. Pekerjaan saya terhambat karena tidak bisa mengakses server internal.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Foto Lampiran ──
                  _buildSectionTitle("Foto Lampiran"),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 120,
                            color: const Color(0xFF1F2937),
                            child: const Center(
                              child: Icon(Icons.laptop_mac,
                                  size: 48, color: Colors.white54),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 120,
                            color: const Color(0xFF111827),
                            child: const Center(
                              child: Icon(Icons.desktop_windows,
                                  size: 48, color: Colors.white54),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Riwayat Penanganan ──
                  _buildSectionTitle("Riwayat Penanganan"),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: List.generate(_riwayat.length, (index) {
                        final item = _riwayat[index];
                        final isLast = index == _riwayat.length - 1;
                        return _buildRiwayatItem(item, isLast);
                      }),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Diskusi & Komentar ──
                  _buildSectionTitle("Diskusi & Komentar"),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: _komentar.map((k) => _buildKomentarItem(k)).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Input Komentar (Bottom) ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _komentarController,
                    decoration: InputDecoration(
                      hintText: "Tulis balasan...",
                      hintStyle: const TextStyle(
                          color: Color(0xFFB0B8C1), fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    // TODO: Kirim komentar
                    if (_komentarController.text.isNotEmpty) {
                      setState(() {
                        _komentar.add({
                          "nama": "Saya",
                          "role": "User",
                          "waktu": "Baru saja",
                          "pesan": _komentarController.text,
                          "inisial": "S",
                          "avatarColor": const Color(0xFF6B7280),
                        });
                        _komentarController.clear();
                      });
                    }
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0A9396),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper: Section Title ──
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF0A9396),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ── Helper: Info Card ──
  Widget _buildInfoCard({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconBg, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helper: Riwayat Item ──
  Widget _buildRiwayatItem(Map<String, dynamic> item, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon + Garis
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item["iconBg"],
                  shape: BoxShape.circle,
                ),
                child: Icon(item["icon"], color: Colors.white, size: 18),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Konten
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    item["title"],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: item["isActive"]
                          ? Colors.black87
                          : item["isDone"]
                              ? Colors.black87
                              : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item["time"],
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9CA3AF)),
                  ),
                  if (item["subtitle"] != null &&
                      item["subtitle"].toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item["subtitle"],
                      style: TextStyle(
                        fontSize: 13,
                        color: item["subtitleColor"],
                        fontWeight: item["isActive"]
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper: Komentar Item ──
  Widget _buildKomentarItem(Map<String, dynamic> komentar) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: komentar["avatarColor"],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                komentar["inisial"],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Konten
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          komentar["nama"],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          komentar["role"],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      komentar["waktu"],
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  komentar["pesan"],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPrioritas() {
    final p = widget.laporan["prioritas"]?.toString() ?? "TINGGI";
    switch (p) {
      case "TINGGI":
        return "Tinggi (Mendesak)";
      case "MENENGAH":
        return "Menengah";
      case "RENDAH":
        return "Rendah";
      default:
        return p;
    }
  }
}