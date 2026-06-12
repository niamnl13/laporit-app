import 'package:flutter/material.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController(text: 'Andi Pratama');
  final _usernameController = TextEditingController(text: 'andipratama');
  final _nimController = TextEditingController(text: '199208242023011002');
  final _emailController = TextEditingController(text: 'andi.pratama@email.com');
  final _telpController = TextEditingController(text: '081234567890');

  String _gender = 'L';
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _telpController.dispose();
    super.dispose();
  }

  void _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // simulasi API call
    setState(() => _isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profil berhasil diperbarui'),
        backgroundColor: const Color(0xFF0F6E56),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ──
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF1A2744),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Edit Profil',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: _isLoading ? null : _simpan,
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    color: Color(0xFF1DBFAA),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            // Avatar area di bawah appbar
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildAvatarArea(),
            ),
          ),

          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ── Informasi Pribadi ──
                  _buildSectionLabel('INFORMASI PRIBADI'),
                  _buildCard([
                    _buildField(
                      label: 'Nama Lengkap',
                      controller: _namaController,
                      hint: 'Masukkan nama lengkap',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    _buildDivider(),
                    _buildField(
                      label: 'Username',
                      controller: _usernameController,
                      hint: 'Masukkan username',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Username tidak boleh kosong' : null,
                    ),
                    _buildDivider(),
                    _buildField(
                      label: 'NIM / NIP',
                      controller: _nimController,
                      hint: 'Masukkan nomor induk',
                      keyboardType: TextInputType.number,
                    ),
                    _buildDivider(),
                    _buildGenderRow(),
                  ]),

                  const SizedBox(height: 16),

                  // ── Kontak ──
                  _buildSectionLabel('KONTAK'),
                  _buildCard([
                    _buildField(
                      label: 'Email',
                      controller: _emailController,
                      hint: 'Masukkan email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                        if (!v.contains('@')) return 'Format email tidak valid';
                        return null;
                      },
                    ),
                    _buildDivider(),
                    _buildField(
                      label: 'Nomor Telepon',
                      controller: _telpController,
                      hint: 'Contoh: 08123456789',
                      keyboardType: TextInputType.phone,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ── Tombol Simpan ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _simpan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A2744),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  AVATAR AREA
  // ─────────────────────────────────────────
  Widget _buildAvatarArea() {
    return Container(
      color: const Color(0xFF1A2744),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
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
                      child: const Icon(Icons.person,
                          size: 48, color: Colors.white54),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: implement image picker
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DBFAA),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF1A2744), width: 2),
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 11, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // TODO: implement image picker
              },
              child: const Text(
                'Ubah Foto Profil',
                style: TextStyle(
                  color: Color(0xFF1DBFAA),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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
  //  CARD WRAPPER
  // ─────────────────────────────────────────
  Widget _buildCard(List<Widget> children) {
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

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Divider(height: 0.5, thickness: 0.5, color: Colors.grey.shade100),
    );
  }

  // ─────────────────────────────────────────
  //  TEXT FIELD
  // ─────────────────────────────────────────
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1DBFAA),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1A1A2E),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFBBBBBB),
                fontSize: 15,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              border: InputBorder.none,
              errorStyle: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  GENDER ROW
  // ─────────────────────────────────────────
  Widget _buildGenderRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Jenis Kelamin',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1DBFAA),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Row(
            children: [
              _genderOption('L', 'Laki-laki'),
              const SizedBox(width: 8),
              _genderOption('P', 'Perempuan'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _genderOption(String value, String label) {
    final selected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8FAF5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF1DBFAA) : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? const Color(0xFF0F6E56) : const Color(0xFF888888),
          ),
        ),
      ),
    );
  }
}