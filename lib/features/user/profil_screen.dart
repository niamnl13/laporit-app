import 'package:flutter/material.dart';
import 'package:laporit_app/core/constants/app_colors.dart';
import 'package:laporit_app/features/auth/login.dart';
import 'package:laporit_app/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laporit_app/features/user/edit_profil_screen.dart';
import 'package:laporit_app/features/user/ubah_password_screen.dart';
import 'package:laporit_app/features/user/notifikasi_screen.dart';
import 'package:laporit_app/features/user/bahasa_screen.dart';
import 'package:laporit_app/features/user/tentang_aplikasi_screen.dart';


class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  String _userName = 'User';
  String _userRole = 'user';
  int _totalLaporan = 0;
  int _totalSelesai = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? 'User';
    final role = prefs.getString('role') ?? 'user';
    final reports = await ApiService.getMyReports();
    setState(() {
      _userName = name;
      _userRole = role;
      _totalLaporan = reports.length;
      _totalSelesai = reports.where((r) => r['status'] == 'selesai').length;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── SliverAppBar dengan header navy ──
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF1A2744),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileHeader(),
            ),
            title: const Text(
              "Profil",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 17,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Stat Cards ──
                _buildStatCards(),

                const SizedBox(height: 24),

                // ── Section: Pengaturan Akun ──
                _buildSectionLabel("PENGATURAN AKUN"),
                _buildMenuCard([
                  _buildMenuItem(
                    icon: Icons.person_outline_rounded,
                    iconBg: const Color(0xFFE8EDF7),
                    iconColor: const Color(0xFF1A2744),
                    title: "Edit Profil",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfilScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuDivider(),
                  _buildMenuItem(
                    icon: Icons.lock_outline_rounded,
                    iconBg: const Color(0xFFE8EDF7),
                    iconColor: const Color(0xFF1A2744),
                    title: "Ubah Password",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UbahPasswordScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuDivider(),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    iconBg: const Color(0xFFE8EDF7),
                    iconColor: const Color(0xFF1A2744),
                    title: "Notifikasi",
                    trailing: _buildBadge("3"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotifikasiScreen(),
                        ),
                      );
                    },
                  ),
                ]),

                const SizedBox(height: 16),

                // ── Section: Informasi & Lainnya ──
                _buildSectionLabel("INFORMASI & LAINNYA"),
                _buildMenuCard([
                  _buildMenuItem(
                    icon: Icons.language_rounded,
                    iconBg: const Color(0xFFE8EDF7),
                    iconColor: const Color(0xFF1A2744),
                    title: "Bahasa",
                    subtitle: "Bahasa Indonesia",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BahasaScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuDivider(),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    iconBg: const Color(0xFFE8EDF7),
                    iconColor: const Color(0xFF1A2744),
                    title: "Tentang Aplikasi",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TentangAplikasiScreen(),
                        ),
                      );
                    },
                  ),
                ]),

                const SizedBox(height: 24),

                // ── Tombol Logout ──
                _buildLogoutButton(context),

                const SizedBox(height: 16),

                // ── Version ──
                const Text(
                  "V 2.4.0 (Build 124)  •  BPS Kab Deli Serdang",
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB4B2A9),
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  PROFILE HEADER
  // ─────────────────────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      color: const Color(0xFF1A2744),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 44),
            Stack(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1DBFAA),
                      width: 2.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Container(
                      color: const Color(0xFF243560),
                      child: const Icon(
                        Icons.person,
                        size: 52,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DBFAA),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1A2744), width: 2),
                    ),
                    child: const Icon(Icons.edit, size: 11, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _userName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _userRole == 'admin'
                  ? 'Admin LaporIT'
                  : _userRole == 'operator'
                      ? 'Operator IT'
                      : 'User',
              style: const TextStyle(
                color: Color(0xFF1DBFAA),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 0.5,
                ),
              ),
              child: const Text(
                "NIP: 199208242023011002",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  letterSpacing: 0.3,
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  _isLoading ? '...' : '$_totalLaporan',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2744),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Laporan Terkirim",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888780),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 0.5,
            height: 40,
            color: const Color(0xFFEAEAEA),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _isLoading ? '...' : _totalSelesai.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F6E56),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Selesai",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888780),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  SECTION LABEL
  // ─────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF888780),
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  MENU CARD WRAPPER
  // ─────────────────────────────────────────
  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 0.5),
      ),
      child: Column(children: children),
    );
  }

  // ─────────────────────────────────────────
  //  MENU ITEM
  // ─────────────────────────────────────────
  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888780),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB4B2A9),
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 68),
      child: Divider(height: 0.5, thickness: 0.5, color: Colors.grey.shade100),
    );
  }

  // ─────────────────────────────────────────
  //  BADGE NOTIF
  // ─────────────────────────────────────────
  Widget _buildBadge(String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFA32D2D),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right_rounded, color: Color(0xFFB4B2A9), size: 20),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  LOGOUT BUTTON
  // ─────────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Konfirmasi Logout",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              content: const Text(
                "Apakah kamu yakin ingin keluar dari akun ini?",
                style: TextStyle(fontSize: 13, color: Color(0xFF888780)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    "Batal",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA32D2D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Logout"),
                ),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFCEBEB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF7C1C1), width: 0.5),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFA32D2D), size: 18),
              SizedBox(width: 8),
              Text(
                "Logout",
                style: TextStyle(
                  color: Color(0xFFA32D2D),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}