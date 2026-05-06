import 'package:flutter/material.dart';
import 'package:laporit_app/core/constants/app_colors.dart';
import 'package:laporit_app/core/services/api_service.dart';
import 'dart:io'; // File untuk handling lampiran foto/video
import 'package:image_picker/image_picker.dart'; // Untuk memilih gambar/video dari galeri atau kamera

class AddLaporanBaru extends StatefulWidget {
  const AddLaporanBaru({super.key});

  @override
  State<AddLaporanBaru> createState() => _AddLaporanBaruState();
}

class _AddLaporanBaruState extends State<AddLaporanBaru> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _nubController = TextEditingController(); // BARU

  String? selectedKategori;
  String selectedPrioritas = "Urgent";
  bool _isLoading = false;
  File? _selectedImage;

  final List<String> kategoriList = [
    "Kerusakan Jaringan",
    "Kerusakan Fisik Komputer",
    "Software Error",
    "Printer / Scanner",
    "Server",
    "Email / Office 365",
    "Lainnya",
  ];

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _nubController.dispose(); // BARU
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Buat Laporan Baru",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "Lapor IT",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header Section ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Detail Kendala",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Lengkapi data di bawah ini untuk\nmempercepat proses penanganan\noleh tim IT.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB2EBF2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: Color(0xFF00838F),
                    size: 28,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Judul Laporan ──
            _buildLabel("JUDUL LAPORAN"),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _judulController,
              hint: "Misal: Printer Macet di Lantai 2",
            ),

            const SizedBox(height: 20),

            // ── Kategori ──
            _buildLabel("KATEGORI"),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedKategori,
              hint: const Text(
                "Pilih Kategori",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey),
              items: kategoriList.map((String kategori) {
                return DropdownMenuItem(
                  value: kategori,
                  child: Text(kategori,
                      style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedKategori = value);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Colors.grey.shade200, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Colors.grey.shade200, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Lokasi / Ruangan ──
            _buildLabel("LOKASI / RUANGAN"),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _lokasiController,
              hint: "Cari Ruangan (Contoh: Lab A1)",
              prefixIcon: const Icon(Icons.search,
                  color: Colors.grey, size: 20),
              suffixIcon: const Icon(Icons.location_on_outlined,
                  color: Colors.grey, size: 20),
            ),

            const SizedBox(height: 20),

            // ────────────────────────────────────────
            //  NUB : NOMOR URUT BARANG  (FIELD BARU)
            // ────────────────────────────────────────
            _buildLabel("NUB : NOMOR URUT BARANG"),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.grey.shade200, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input field NUB
                  TextField(
                    controller: _nubController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        letterSpacing: 0.5),
                    decoration: InputDecoration(
                      hintText: "Misal: NUB-2024-001",
                      hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          letterSpacing: 0),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F1FB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          color: Color(0xFF185FA5),
                          size: 18,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(
                          right: 16, top: 14, bottom: 14),
                    ),
                  ),

                  // Divider tipis
                  Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Colors.grey.shade100),

                  // Info strip bawah
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: Color(0xFF378ADD),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Nomor tertera pada stiker aset perangkat",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Tingkat Prioritas ──
            _buildLabel("TINGKAT PRIORITAS"),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _priorityChip("Low", Colors.grey),
                _priorityChip("Medium", Colors.blue),
                _priorityChip("High", Colors.orange),
                _priorityChip("Urgent", Colors.red),
              ],
            ),

            const SizedBox(height: 24),

            // ── Deskripsi Masalah ──
            _buildLabel("DESKRIPSI MASALAH"),
            const SizedBox(height: 8),
            TextField(
              controller: _deskripsiController,
              maxLines: 5,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText:
                    "Jelaskan secara detail masalah yang dihadapi...",
                hintStyle: const TextStyle(
                    color: Colors.grey, fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Colors.grey.shade200, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Colors.grey.shade200, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Lampiran Foto / Video ──
            _buildLabel("LAMPIRAN FOTO / VIDEO"),
            const SizedBox(height: 12),
            // Kalau gambar sudah dipilih, tampilan opsinya berubah jadi preview dengan tombol hapus, kalau belum ada tampilannya dua opsi untuk pilih dari kamera atau galeri
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImage = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.camera), // untuk membuka kamera
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              size: 30, color: Colors.grey.shade400),
                          const SizedBox(height: 6),
                          Text("Kamera",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery), // untuk membuka galeri
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2744),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined,
                                size: 28, color: Colors.white70),
                            SizedBox(height: 6),
                            Text("Unggah dari Galeri",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                )),
                            SizedBox(height: 2),
                            Text("PNG, JPG, MP4 up to 10MB",
                                style: TextStyle(fontSize: 10, color: Colors.white54)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 36),

            // ── Tombol Kirim Laporan ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  // Validasi dulu
                  if (_judulController.text.isEmpty) {
                    _showSnackBar('Judul laporan wajib diisi!');
                    return;
                  }
                  if (selectedKategori == null) {
                    _showSnackBar('Kategori wajib dipilih!');
                    return;
                  }
                  if (_deskripsiController.text.isEmpty) {
                    _showSnackBar('Deskripsi wajib diisi!');
                    return;
                  }

                  setState(() => _isLoading = true);

                  try {
                    final result = await ApiService.createReport(
                      jenisKerusakan: selectedKategori!, // kirim kategori yang dipilih ke API
                      deskripsi: _deskripsiController.text, // kirim deskripsi ke API
                      lokasi: _lokasiController.text, // kirim lokasi ke API
                      judul: _judulController.text, // kirim judul laporan ke API
                      priority: _convertPriority(selectedPrioritas), // prioritas dikonversi ke bahasa Indonesia sesuai API
                      nub: _nubController.text, // kirim NUB (Nomor Unit Barang) ke API
                      foto: _selectedImage, // kirim file gambar/video ke API
                    );
                    
                    if (result['success'] == true) {
                      if (!mounted) return;
                      _showSuccessDialog();
                    } else {
                      _showSnackBar(result['message'] ?? 'Gagal mengirim laporan');
                    }
                  } catch (e) {
                    _showSnackBar('Terjadi kesalahan koneksi');
                  }

                  setState(() => _isLoading = false);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Kirim Laporan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Syarat & Ketentuan
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey),
                  children: [
                    const TextSpan(
                        text:
                            "Dengan mengirim, Anda menyetujui "),
                    TextSpan(
                      text: "Syarat & Ketentuan",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(
                        text: "\npelaporan IT perusahaan."),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk memilih gambar/video dari kamera atau galeri
  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  // Fungsi untuk mengonversi tingkat prioritas ke format yang sesuai dengan API karena di Api bhs indonesia
  String _convertPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'low': return 'rendah';
      case 'medium': return 'normal';
      case 'high': return 'tinggi';
      case 'urgent': return 'gawat';
      default: return 'normal';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _priorityChip(String label, Color color) {
    final bool isSelected = selectedPrioritas == label;
    return GestureDetector(
      onTap: () => setState(() => selectedPrioritas = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.black54,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  SUCCESS DIALOG (dipertahankan dari asli)
  // ─────────────────────────────────────────

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 36, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 56,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Laporan Berhasil Dikirim!",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Tim IT kami akan segera menangani kendala yang Anda laporkan.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // tutup dialog
                    Navigator.pop(context); // kembali ke halaman sebelumnya
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Oke, Kembali",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}