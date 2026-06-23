import 'package:flutter/material.dart';
import 'package:laporit_app/core/constants/app_colors.dart';
import 'package:laporit_app/core/services/api_service.dart';

class PenggunaAdminScreen extends StatefulWidget {
  const PenggunaAdminScreen({super.key});

  @override
  State<PenggunaAdminScreen> createState() => _PenggunaAdminScreenState();
}

class _PenggunaAdminScreenState extends State<PenggunaAdminScreen> {
  List<dynamic> _users = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  String _activeRole = 'Semua User';
  String _searchQuery = '';

  final List<String> _roleFilters = ['Semua User', 'User', 'Operator', 'Admin'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final users = await ApiService.getAllUsers();
      setState(() {
        _users = users;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat data pengguna', AppColors.error);
    }
  }

  void _applyFilter() {
    List<dynamic> result = List.from(_users);

    if (_activeRole != 'Semua User') {
      result = result
          .where((u) =>
              (u['role'] ?? '').toString().toLowerCase() ==
              _activeRole.toLowerCase())
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((u) {
        final name = (u['name'] ?? '').toString().toLowerCase();
        final nip = (u['nip'] ?? '').toString().toLowerCase();
        return name.contains(q) || nip.contains(q);
      }).toList();
    }

    setState(() => _filtered = result);
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _toggleAktif(dynamic user) async {
    final id = user['id'];
    final isAktif = user['is_aktif'] == true || user['is_aktif'] == 1;
    try {
      await ApiService.toggleUserStatus(id, !isAktif);
      await _loadData();
      _showSnackBar(
        isAktif ? 'Pengguna dinonaktifkan' : 'Pengguna diaktifkan',
        isAktif ? AppColors.error : AppColors.success,
      );
    } catch (e) {
      _showSnackBar('Gagal mengubah status pengguna', AppColors.error);
    }
  }

  void _showUserForm({dynamic user}) {
    final isEdit = user != null;
    final nameCtrl =
        TextEditingController(text: isEdit ? user['name'] ?? '' : '');
    final nipCtrl =
        TextEditingController(text: isEdit ? user['nip'] ?? '' : '');
    final emailCtrl =
        TextEditingController(text: isEdit ? user['email'] ?? '' : '');
    final passCtrl = TextEditingController();
    String selectedRole = isEdit ? (user['role'] ?? 'operator') : 'operator';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(
            20, 16, 20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isEdit ? 'Edit Pengguna' : 'Tambah User Baru',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Role toggle
                Text('Role',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                        letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Row(
                  children: ['user', 'operator', 'admin'].map((r) {
                    final sel = selectedRole == r;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setModal(() => selectedRole = r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: EdgeInsets.only(right: r != 'admin' ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.primary
                                : const Color(0xFFF5F6FA),
                            borderRadius: BorderRadius.circular(12),
                            border: sel
                                ? null
                                : Border.all(
                                    color: const Color(0xFFEAEAEA)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                r == 'admin'
                                    ? Icons.admin_panel_settings_outlined
                                    : r == 'operator'
                                        ? Icons.support_agent_outlined
                                        : Icons.person_outline,
                                size: 16,
                                color: sel ? Colors.white : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                r == 'admin'
                                    ? 'Admin'
                                    : r == 'operator'
                                        ? 'Operator'
                                        : 'User',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: sel ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                _buildFormField('Nama Lengkap', nameCtrl,
                    hint: 'Masukkan nama lengkap'),
                const SizedBox(height: 12),
                _buildFormField('NIP', nipCtrl,
                    hint: 'Masukkan NIP',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _buildFormField('Email', emailCtrl,
                    hint: 'Masukkan email',
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _buildFormField(
                  isEdit ? 'Password Baru (opsional)' : 'Password',
                  passCtrl,
                  hint: isEdit ? 'Kosongkan jika tidak diubah' : 'Buat password',
                  obscure: true,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        if (isEdit) {
                          await ApiService.updateUser(user['id'], {
                            'name': nameCtrl.text,
                            'nip': nipCtrl.text,
                            'email': emailCtrl.text,
                            'role': selectedRole,
                            if (passCtrl.text.isNotEmpty)
                              'password': passCtrl.text,
                          });
                          _showSnackBar(
                              'Pengguna berhasil diperbarui', AppColors.success);
                        } else {
                          await ApiService.createUser({
                            'name': nameCtrl.text,
                            'nip': nipCtrl.text,
                            'email': emailCtrl.text,
                            'password': passCtrl.text,
                            'role': selectedRole,
                          });
                          _showSnackBar(
                              'Pengguna berhasil ditambahkan', AppColors.success);
                        }
                        _loadData();
                      } catch (e) {
                        _showSnackBar('Gagal menyimpan data', AppColors.error);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      isEdit ? 'Simpan Perubahan' : 'Tambah Pengguna',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(dynamic user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Pengguna',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text(
          'Yakin ingin menghapus ${user['name']}? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiService.deleteUser(user['id']);
                _showSnackBar('Pengguna dihapus', AppColors.success);
                _loadData();
              } catch (e) {
                _showSnackBar('Gagal menghapus pengguna', AppColors.error);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manajemen User',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Kelola akses dan perizinan operator.',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // Tambah user button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _showUserForm(),
                    icon: const Icon(Icons.person_add_rounded, size: 18),
                    label: const Text('Tambah User Baru',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Search
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (v) {
                            _searchQuery = v;
                            _applyFilter();
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari nama atau NIP...',
                            hintStyle: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary),
                            prefixIcon: Icon(Icons.search,
                                color: AppColors.textSecondary, size: 20),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Icon(Icons.filter_list_rounded,
                            color: AppColors.textSecondary, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Role filter tabs
                Row(
                  children: _roleFilters.map((r) {
                    final active = _activeRole == r;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _activeRole = r);
                        _applyFilter();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: active
                              ? null
                              : Border.all(color: const Color(0xFFDDDDDD)),
                        ),
                        child: Text(
                          r,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: active
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // ── User List ──
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: _isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : _filtered.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _buildUserCard(_filtered[i]),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    final name = user['name'] ?? 'Nama User';
    final nip = user['nip'] ?? '-';
    final role = (user['role'] ?? 'user').toString().toLowerCase();
    final isAktif = user['is_aktif'] == true || user['is_aktif'] == 1;
    final roleColor = role == 'admin'
        ? AppColors.error
        : role == 'operator'
            ? AppColors.accent
            : AppColors.primary;

    final roleLabel = role == 'admin'
        ? 'ADMIN'
        : role == 'operator'
            ? 'OPERATOR'
            : 'USER';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAktif ? Colors.white : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAktif
              ? const Color(0xFFEAEAEA)
              : const Color(0xFFDDDDDD),
          width: 0.5,
        ),
        boxShadow: isAktif
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAktif
                  ? AppColors.primary.withOpacity(0.12)
                  : Colors.grey.shade200,
            ),
            child: Icon(
              Icons.person,
              color: isAktif ? AppColors.primary : Colors.grey,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isAktif
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        roleLabel,
                        style: TextStyle(
                          fontSize: 10,
                          color: roleColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'NIP. $nip',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isAktif ? AppColors.success : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isAktif ? 'Aktif' : 'Non-aktif',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isAktif ? AppColors.success : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action menu
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded,
                color: AppColors.textSecondary, size: 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    const Text('Edit', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(
                      isAktif
                          ? Icons.block_rounded
                          : Icons.check_circle_outline_rounded,
                      size: 16,
                      color: isAktif ? AppColors.error : AppColors.success,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isAktif ? 'Nonaktifkan' : 'Aktifkan',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        size: 16, color: AppColors.error),
                    const SizedBox(width: 10),
                    Text('Hapus',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.error)),
                  ],
                ),
              ),
            ],
            onSelected: (val) {
              if (val == 'edit') _showUserForm(user: user);
              if (val == 'toggle') _toggleAktif(user);
              if (val == 'delete') _showDeleteConfirm(user);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController ctrl, {
    String hint = '',
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            obscureText: obscure,
            style:
                TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  fontSize: 14, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Tidak ada pengguna',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary),
          ),
          Text(
            'Coba ubah filter atau tambah pengguna baru',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}