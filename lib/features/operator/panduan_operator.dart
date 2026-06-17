import 'package:flutter/material.dart';
import 'package:laporit_app/core/constants/app_colors.dart';

// =============================================
// MODEL ARTIKEL
// =============================================
class Artikel {
  final String id;
  final String judul;
  final String konten;
  final String kategori;
  final String waktu;
  final int views;
  final int likes;
  final bool isPopuler;

  Artikel({
    required this.id,
    required this.judul,
    required this.konten,
    required this.kategori,
    required this.waktu,
    required this.views,
    required this.likes,
    this.isPopuler = false,
  });
}

// =============================================
// DATA DUMMY ARTIKEL
// =============================================
final List<Artikel> _dummyArtikel = [
  Artikel(
    id: '1',
    judul: 'Panduan Reset Router Kantor',
    konten: '''Langkah-langkah pemulihan koneksi internet saat terjadi gangguan massal.

1. Matikan router dengan mencabut kabel power
2. Tunggu 30 detik
3. Sambungkan kembali kabel power
4. Tunggu hingga lampu indikator stabil (±2 menit)
5. Test koneksi dari beberapa komputer

Jika masalah berlanjut, hubungi ISP atau cek konfigurasi di panel admin router.''',
    kategori: 'Network',
    waktu: '12 Menit Lalu',
    views: 124,
    likes: 42,
    isPopuler: true,
  ),
  Artikel(
    id: '2',
    judul: 'Konfigurasi VPN Baru untuk Remote Work',
    konten: '''Prosedur pengaturan Cisco AnyConnect versi terbaru untuk akses server internal.

1. Download installer Cisco AnyConnect dari server internal
2. Install dengan menjalankan sebagai Administrator
3. Buka aplikasi dan masukkan alamat server VPN
4. Login menggunakan akun SSO kantor
5. Pilih grup koneksi sesuai divisi

Catatan: VPN hanya aktif selama jam kerja 07.00 - 17.00 WIB.''',
    kategori: 'Network',
    waktu: '12 Menit Lalu',
    views: 124,
    likes: 42,
    isPopuler: false,
  ),
  Artikel(
    id: '3',
    judul: 'Troubleshooting Printer Macet (L3110)',
    konten: '''Solusi cepat menangani paper jam dan tinta tidak keluar pada seri printer Epson L3110.

PAPER JAM:
1. Matikan printer
2. Buka penutup belakang
3. Tarik kertas perlahan searah jalur kertas
4. Pastikan tidak ada sobekan kertas tertinggal
5. Nyalakan kembali

TINTA TIDAK KELUAR:
1. Buka Epson Maintenance dari Control Panel
2. Pilih "Head Cleaning"
3. Jalankan 2-3 kali jika perlu
4. Print test page untuk verifikasi''',
    kategori: 'Hardware',
    waktu: '2 Jam Lalu',
    views: 89,
    likes: 15,
    isPopuler: false,
  ),
  Artikel(
    id: '4',
    judul: 'Prosedur Keamanan Password Berkala',
    konten: '''Cara mengganti password SSO dan mengaktifkan 2FA menggunakan aplikasi autentikasi.

GANTI PASSWORD SSO:
1. Buka portal.bps.go.id
2. Login dengan akun lama
3. Klik nama pengguna di pojok kanan atas
4. Pilih "Ubah Password"
5. Masukkan password lama dan password baru
6. Password minimal 8 karakter dengan kombinasi huruf, angka, dan simbol

AKTIFKAN 2FA:
1. Download Google Authenticator atau Microsoft Authenticator
2. Buka pengaturan akun SSO
3. Pilih "Keamanan" → "Autentikasi Dua Faktor"
4. Scan QR code dengan aplikasi authenticator
5. Masukkan kode verifikasi 6 digit''',
    kategori: 'Security',
    waktu: 'Kemarin',
    views: 256,
    likes: 56,
    isPopuler: false,
  ),
  Artikel(
    id: '5',
    judul: 'Cara Install Ulang Windows 10',
    konten: '''Panduan lengkap instalasi ulang Windows 10 untuk komputer kantor.

PERSIAPAN:
1. Backup data penting ke server atau flashdisk
2. Siapkan bootable USB Windows 10
3. Catat product key Windows (ada di stiker bawah komputer)

PROSES INSTALASI:
1. Restart komputer dan tekan F2/F12 untuk masuk BIOS
2. Ubah boot priority ke USB
3. Simpan dan restart
4. Ikuti wizard instalasi Windows
5. Pilih "Custom Install" untuk instalasi bersih
6. Format partisi C: sebelum install

SETELAH INSTALL:
1. Update Windows melalui Windows Update
2. Install driver dari website produsen
3. Install software kantor (Office, antivirus, dll)''',
    kategori: 'Hardware',
    waktu: '3 Hari Lalu',
    views: 312,
    likes: 78,
    isPopuler: false,
  ),
  Artikel(
    id: '6',
    judul: 'Backup Data ke Server NAS',
    konten: '''Prosedur backup data rutin ke server NAS kantor.

JADWAL BACKUP:
- Harian: File dokumen aktif
- Mingguan: Seluruh folder kerja
- Bulanan: Full backup termasuk email

CARA BACKUP:
1. Buka File Explorer
2. Akses \\\\192.168.1.100\\backup
3. Login dengan akun domain kantor
4. Copy folder kerja ke direktori backup
5. Catat tanggal backup di log sheet

Pastikan koneksi ke server stabil sebelum backup.''',
    kategori: 'Network',
    waktu: '5 Hari Lalu',
    views: 67,
    likes: 23,
    isPopuler: false,
  ),
];

// =============================================
// HALAMAN PANDUAN OPERATOR
// =============================================
class PanduanOperator extends StatefulWidget {
  const PanduanOperator({super.key});

  @override
  State<PanduanOperator> createState() => _PanduanOperatorState();
}

class _PanduanOperatorState extends State<PanduanOperator> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedKategori = 'Semua';
  final List<String> _kategoriList = ['Semua', 'Hardware', 'Network', 'Security'];

  List<Artikel> get _filtered {
    return _dummyArtikel.where((a) {
      final matchKategori = _selectedKategori == 'Semua' || a.kategori == _selectedKategori;
      final matchSearch = _searchController.text.isEmpty ||
          a.judul.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchKategori && matchSearch;
    }).toList();
  }

  Artikel get _artikelPopuler => _dummyArtikel.firstWhere((a) => a.isPopuler);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            _buildHeader(),

            // ── Body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Search
                    _buildSearch(),
                    const SizedBox(height: 16),

                    // Filter Kategori
                    _buildKategoriFilter(),
                    const SizedBox(height: 20),

                    // Artikel Populer
                    if (_selectedKategori == 'Semua' && _searchController.text.isEmpty) ...[
                      _buildArtikelPopuler(),
                      const SizedBox(height: 24),
                    ],

                    // Artikel Terbaru
                    _buildSectionLabel('ARTIKEL TERBARU'),
                    const SizedBox(height: 12),
                    ..._filtered
                        .where((a) => !a.isPopuler)
                        .map((a) => _buildArtikelCard(a)),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // HEADER
  // =============================================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Basis Pengetahuan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cari solusi teknis dan panduan dokumentasi\ndengan cepat.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
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

  // =============================================
  // SEARCH
  // =============================================
  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Cari solusi atau artikel...',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
  // FILTER KATEGORI
  // =============================================
  Widget _buildKategoriFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _kategoriList.map((k) {
          final isSelected = _selectedKategori == k;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedKategori = k),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  k,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // =============================================
  // ARTIKEL POPULER (featured card)
  // =============================================
  Widget _buildArtikelPopuler() {
    final artikel = _artikelPopuler;
    return GestureDetector(
      onTap: () => _bukaDetail(artikel),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'POPULER',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              artikel.judul,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              artikel.konten.split('\n').first,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Baca Selengkapnya →',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // SECTION LABEL
  // =============================================
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF888780),
        letterSpacing: 0.8,
      ),
    );
  }

  // =============================================
  // ARTIKEL CARD
  // =============================================
  Widget _buildArtikelCard(Artikel artikel) {
    final kategoriColor = _kategoriColor(artikel.kategori);

    return GestureDetector(
      onTap: () => _bukaDetail(artikel),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEAEAEA), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kategoriColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    artikel.kategori,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: kategoriColor,
                    ),
                  ),
                ),
                Text(
                  artikel.waktu,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              artikel.judul,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              artikel.konten.split('\n').first,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.remove_red_eye_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${artikel.views}',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(width: 12),
                Icon(Icons.thumb_up_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${artikel.likes}',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // BUKA DETAIL ARTIKEL
  // =============================================
  void _bukaDetail(Artikel artikel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailArtikelScreen(artikel: artikel),
      ),
    );
  }

  Color _kategoriColor(String kategori) {
    switch (kategori) {
      case 'Hardware': return const Color(0xFF00B4D8);
      case 'Network': return AppColors.accent;
      case 'Security': return const Color(0xFFF59E0B);
      default: return AppColors.primary;
    }
  }
}

// =============================================
// HALAMAN DETAIL ARTIKEL
// =============================================
class DetailArtikelScreen extends StatelessWidget {
  final Artikel artikel;
  const DetailArtikelScreen({super.key, required this.artikel});

  @override
  Widget build(BuildContext context) {
    final kategoriColor = _kategoriColor(artikel.kategori);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Panduan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori + waktu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kategoriColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    artikel.kategori,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: kategoriColor,
                    ),
                  ),
                ),
                Text(
                  artikel.waktu,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Judul
            Text(
              artikel.judul,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            // Stats
            Row(
              children: [
                Icon(Icons.remove_red_eye_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${artikel.views} views',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(width: 12),
                Icon(Icons.thumb_up_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${artikel.likes} likes',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),

            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 20),

            // Konten
            Text(
              artikel.konten,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A1A),
                height: 1.8,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Color _kategoriColor(String kategori) {
    switch (kategori) {
      case 'Hardware': return const Color(0xFF00B4D8);
      case 'Network': return AppColors.accent;
      case 'Security': return const Color(0xFFF59E0B);
      default: return AppColors.primary;
    }
  }
}