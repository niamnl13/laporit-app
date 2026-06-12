import 'package:flutter/material.dart';

class TentangAplikasiScreen extends StatelessWidget {
  const TentangAplikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2744),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),

          // ── Hero Card ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2744),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // App icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF243560),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF1DBFAA),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    size: 38,
                    color: Color(0xFF1DBFAA),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Lapor IT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DBFAA).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Versi 2.4.0 (Build 124)',
                    style: TextStyle(
                      color: Color(0xFF1DBFAA),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Platform pelaporan masalah IT yang cepat,\nmudah, dan terstruktur.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF8BA3CC),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Informasi Aplikasi ──
          _buildSectionLabel('INFORMASI APLIKASI'),
          _buildCard([
            _buildInfoRow('Versi Aplikasi', 'V 2.4.0 (Build 124)'),
            _buildDivider(),
            _buildInfoRow('Terakhir Diperbarui', 'Mei 2025'),
            _buildDivider(),
            _buildInfoRow('Platform', 'Android & iOS'),
            _buildDivider(),
            _buildInfoRow('Instansi', 'BPS Kab Deli Serdang'),
            _buildDivider(),
            _buildInfoRow('Developer', 'Tim IT Internal'),
          ]),

          const SizedBox(height: 16),

          // ── Lainnya ──
          _buildSectionLabel('LAINNYA'),
          _buildCard([
            _buildLinkRow(
              icon: Icons.description_outlined,
              label: 'Syarat & Ketentuan',
              onTap: () {},
            ),
            _buildDivider(),
            _buildLinkRow(
              icon: Icons.privacy_tip_outlined,
              label: 'Kebijakan Privasi',
              onTap: () {},
            ),
            _buildDivider(),
            _buildLinkRow(
              icon: Icons.help_outline_rounded,
              label: 'Pusat Bantuan',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 28),

          // ── Copyright ──
          const Text(
            '© 2025 Lapor IT. Semua hak dilindungi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFB4B2A9),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Dibuat dengan ❤️ oleh Tim IT Internal',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFB4B2A9),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  SECTION LABEL
  // ─────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 10),
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

  // ─────────────────────────────────────────
  //  CARD WRAPPER
  // ─────────────────────────────────────────
  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 0.5),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Divider(height: 0.5, thickness: 0.5, color: Colors.grey.shade100),
    );
  }

  // ─────────────────────────────────────────
  //  INFO ROW
  // ─────────────────────────────────────────
  Widget _buildInfoRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  LINK ROW
  // ─────────────────────────────────────────
  Widget _buildLinkRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE8FAF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: const Color(0xFF1DBFAA)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFB4B2A9), size: 20),
          ],
        ),
      ),
    );
  }
}