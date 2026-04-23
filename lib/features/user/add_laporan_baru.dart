import 'package:flutter/material.dart';
import 'package:laporit_app/core/constants/app_colors.dart';

class AddLaporanBaru extends StatefulWidget {
  const AddLaporanBaru({super.key});

  @override
  State<AddLaporanBaru> createState() => _AddLaporanBaruState();
}

class _AddLaporanBaruState extends State<AddLaporanBaru> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();

  String? selectedKategori;
  String selectedPrioritas = "Urgent";

  final List<String> kategoriList = [
    "Kerusakan Jaringan",
    "Kerusakan Fisik Komputer",
    "Software Error",
    "Printer / Scanner",
    "Server",
    "Email / Office 365",
    "Lainnya"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Buat Laporan Baru",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              "Detail Kendala",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Lengkapi data di bawah ini untuk mempercepat proses penanganan oleh IT.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Judul Laporan
            const Text("JUDUL LAPORAN", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _judulController,
              decoration: InputDecoration(
                hintText: "Misal: Printer Macet di Lantai 2",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Kategori
            const Text("KATEGORI", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedKategori,
              hint: const Text("Pilih Kategori"),
              items: kategoriList.map((String kategori) {
                return DropdownMenuItem(value: kategori, child: Text(kategori));
              }).toList(),
              onChanged: (value) {
                setState(() => selectedKategori = value);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Lokasi / Ruangan
            const Text("LOKASI / RUANGAN", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _lokasiController,
              decoration: InputDecoration(
                hintText: "Cari Ruangan (Contoh: Lab A1)",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Tingkat Prioritas
            const Text("TINGKAT PRIORITAS", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _priorityChip("Low", Colors.grey),
                _priorityChip("Medium", Colors.blue),
                _priorityChip("High", Colors.orange),
                _priorityChip("Urgent", Colors.red, isSelected: true),
              ],
            ),
            const SizedBox(height: 24),

            // Deskripsi Masalah
            const Text("DESKRIPSI MASALAH", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _deskripsiController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Jelaskan secara detail masalah yang dihadapi...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Lampiran Foto / Video
            const Text("LAMPIRAN FOTO / VIDEO", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                // Tombol Kamera
                GestureDetector(
                  onTap: () {
                    // TODO: Buka kamera
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 32, color: Colors.grey),
                        SizedBox(height: 4),
                        Text("KAMERA", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Upload dari Galeri
                GestureDetector(
                  onTap: () {
                    // TODO: Buka galeri
                  },
                  child: Container(
                    width: 180,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 32, color: Colors.grey),
                        SizedBox(height: 4),
                        Text("Unggah dari Galeri", style: TextStyle(fontSize: 12)),
                        Text("PNG, JPG, MP4 up to 10MB", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Tombol Kirim Laporan
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Logic kirim laporan
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Laporan sedang dikirim...")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Kirim Laporan",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Center(
              child: Text(
                "Dengan mengirim, Anda menyetujui Syarat & Ketentuan\npelaporan IT perusahaan.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityChip(String label, Color color, {bool isSelected = false}) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => selectedPrioritas = label);
      },
      backgroundColor: Colors.white,
      selectedColor: color.withOpacity(0.15),
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(color: isSelected ? color : Colors.grey.shade300),
      ),
    );
  }
}