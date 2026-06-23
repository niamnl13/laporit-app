import 'package:flutter/material.dart';
import 'package:laporit_app/features/user/dashboard_user.dart';
import 'package:laporit_app/features/user/daftar_laporan_saya.dart';
import 'package:laporit_app/features/user/add_laporan_baru.dart';
import 'package:laporit_app/features/user/profil_screen.dart';
import 'package:laporit_app/core/services/api_service.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  int _unreadCount = 0;
  Key _laporanKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final notifications = await ApiService.getNotifications();
      final unread = notifications
          .where((n) => n['is_read'] == 0 || n['is_read'] == false)
          .length;
      setState(() => _unreadCount = unread);
    } catch (e) {
      // ignore error, biarkan badge tetap 0
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardUser(),
      DaftarLaporanSaya(key: _laporanKey, unreadCount: _unreadCount),
      const ProfilScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),

      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddLaporanBaru()),
              ),
              backgroundColor: const Color(0xFF1A2744),
              shape: const CircleBorder(),
              elevation: 3,
              child: const Icon(Icons.add, color: Colors.white, size: 26),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 1) {
              _laporanKey = UniqueKey();
              _loadUnreadCount();
            }
            if (index == 0) {
              _loadUnreadCount();
            }
          });
        },
        selectedItemColor: const Color(0xFF1A2744),
        unselectedItemColor: const Color(0xFF888780),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}