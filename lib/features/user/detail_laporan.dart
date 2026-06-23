import 'package:flutter/material.dart';
import 'package:laporit_app/core/constants/app_constants.dart';

class DetailLaporan extends StatelessWidget {
  final Map<String, dynamic> laporan;

  const DetailLaporan({super.key, required this.laporan});

  @override
  Widget build(BuildContext context) {
    final rawStatus = laporan["rawStatus"] ?? "pending";
    final fotoPath = laporan["foto"];

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
      ),
      body: SingleChildScrollView(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        laporan["id"] ?? "-",
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
                          color: (laporan["statusBgColor"] as Color?) ??
                              const Color(0xFFE0F7FA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          laporan["status"] ?? "Pending",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: (laporan["statusColor"] as Color?) ??
                                const Color(0xFF00B4D8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    laporan["judul"] ?? "-",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
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
              value: laporan["kategori"] ?? "-",
            ),
            const SizedBox(height: 10),
            _buildInfoCard(
              icon: Icons.location_on_outlined,
              iconBg: const Color(0xFF0A9396),
              label: "LOKASI",
              value: laporan["lokasi"] ?? "-",
            ),
            const SizedBox(height: 10),
            _buildInfoCard(
              icon: Icons.priority_high,
              iconBg: const Color(0xFFEF4444),
              label: "PRIORITAS",
              value: _capitalize(laporan["prioritas"]?.toString() ?? "-"),
            ),
            const SizedBox(height: 10),
            _buildInfoCard(
              icon: Icons.qr_code_2_rounded,
              iconBg: const Color(0xFF185FA5),
              label: "NUB",
              value: laporan["nub"] ?? "-",
            ),
            const SizedBox(height: 10),
            _buildInfoCard(
              icon: Icons.calendar_today_outlined,
              iconBg: const Color(0xFF6B7280),
              label: "TANGGAL LAPOR",
              value: laporan["tanggal"] ?? "-",
            ),
            if (rawStatus == 'selesai' && laporan["tglEksekusi"] != '-') ...[
              const SizedBox(height: 10),
              _buildInfoCard(
                icon: Icons.check_circle_outline,
                iconBg: const Color(0xFF10B981),
                label: "TANGGAL SELESAI",
                value: laporan["tglEksekusi"] ?? "-",
              ),
            ],

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
              child: Text(
                laporan["deskripsi"] ?? "-",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                  height: 1.6,
                ),
              ),
            ),

            // ── Foto Lampiran (kalau ada) ──
            if (fotoPath != null && fotoPath.toString().isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionTitle("Foto Lampiran"),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '${AppConstants.storageUrl}/$fotoPath',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: const Color(0xFFF3F4F6),
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          size: 40, color: Colors.grey),
                    ),
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 200,
                      color: const Color(0xFFF3F4F6),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Status Penanganan (disederhanakan) ──
            _buildSectionTitle("Status Penanganan"),
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
              child: _buildStatusFlow(rawStatus),
            ),

            const SizedBox(height: 16),
          ],
        ),
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
          Expanded(
            child: Column(
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
          ),
        ],
      ),
    );
  }

  // ── Helper: Status Flow (Pending → Diproses → Selesai/Ditolak) ──
  Widget _buildStatusFlow(String status) {
    final steps = [
      {"key": "pending", "label": "Laporan Diterima", "icon": Icons.check},
      {"key": "proses", "label": "Sedang Diproses", "icon": Icons.build_outlined},
      {
        "key": status == 'ditolak' ? "ditolak" : "selesai",
        "label": status == 'ditolak' ? "Ditolak" : "Selesai",
        "icon": status == 'ditolak' ? Icons.close_rounded : Icons.flag_outlined,
      },
    ];

    final order = ["pending", "proses", "selesai"];
    int currentIndex;
    if (status == 'ditolak') {
      currentIndex = 2; // langsung tampilkan sebagai tahap akhir
    } else {
      currentIndex = order.indexOf(status);
      if (currentIndex == -1) currentIndex = 0;
    }

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        final isDone = index < currentIndex;
        final isActive = index == currentIndex;
        final isRejected = step["key"] == "ditolak";

        final iconBg = isRejected
            ? const Color(0xFFEF4444)
            : isActive || isDone
                ? const Color(0xFF10B981)
                : const Color(0xFFD1D5DB);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(step["icon"] as IconData,
                        color: Colors.white, size: 18),
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
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        step["label"] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: (isActive || isDone)
                              ? Colors.black87
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}