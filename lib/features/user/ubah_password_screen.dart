import 'package:flutter/material.dart';

class UbahPasswordScreen extends StatefulWidget {
  const UbahPasswordScreen({super.key});

  @override
  State<UbahPasswordScreen> createState() => _UbahPasswordScreenState();
}

class _UbahPasswordScreenState extends State<UbahPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _oldPassVisible = false;
  bool _newPassVisible = false;
  bool _confirmPassVisible = false;
  bool _isLoading = false;

  // Syarat password
  bool get _hasMinLength => _newPassController.text.length >= 8;
  bool get _hasNumber => _newPassController.text.contains(RegExp(r'\d'));
  bool get _hasUppercase => _newPassController.text.contains(RegExp(r'[A-Z]'));

  int get _strengthScore => [_hasMinLength, _hasNumber, _hasUppercase].where((e) => e).length;

  String get _strengthLabel {
    if (_newPassController.text.isEmpty) return '';
    switch (_strengthScore) {
      case 1: return 'Lemah';
      case 2: return 'Sedang';
      case 3: return 'Kuat';
      default: return '';
    }
  }

  Color get _strengthColor {
    switch (_strengthScore) {
      case 1: return const Color(0xFFE24B4A);
      case 2: return const Color(0xFFEF9F27);
      case 3: return const Color(0xFF1DBFAA);
      default: return const Color(0xFFE0E0E0);
    }
  }

  void _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // simulasi API call
    setState(() => _isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password berhasil diperbarui'),
        backgroundColor: const Color(0xFF0F6E56),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

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
          'Ubah Password',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),

            // ── Info Box ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8FAF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.shield_outlined,
                      color: Color(0xFF1DBFAA), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pastikan password baru minimal 8 karakter dan mengandung kombinasi huruf serta angka.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0F6E56),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Password Saat Ini ──
            _buildSectionLabel('PASSWORD SAAT INI'),
            _buildCard([
              _buildPasswordField(
                label: 'Password Lama',
                controller: _oldPassController,
                hint: 'Masukkan password saat ini',
                visible: _oldPassVisible,
                onToggle: () => setState(() => _oldPassVisible = !_oldPassVisible),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password lama tidak boleh kosong';
                  return null;
                },
              ),
            ]),

            const SizedBox(height: 16),

            // ── Password Baru ──
            _buildSectionLabel('PASSWORD BARU'),
            _buildCard([
              _buildPasswordField(
                label: 'Password Baru',
                controller: _newPassController,
                hint: 'Masukkan password baru',
                visible: _newPassVisible,
                onToggle: () => setState(() => _newPassVisible = !_newPassVisible),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password baru tidak boleh kosong';
                  if (v.length < 8) return 'Password minimal 8 karakter';
                  return null;
                },
              ),

              // Strength bar
              if (_newPassController.text.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kekuatan password',
                            style: TextStyle(fontSize: 11, color: Color(0xFF888780)),
                          ),
                          Text(
                            _strengthLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _strengthColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _strengthScore / 3,
                          minHeight: 4,
                          backgroundColor: const Color(0xFFF0F0F0),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_strengthColor),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDivider(),

                // Syarat checklist
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Column(
                    children: [
                      _buildSyarat(_hasMinLength, 'Minimal 8 karakter'),
                      const SizedBox(height: 6),
                      _buildSyarat(_hasNumber, 'Mengandung angka'),
                      const SizedBox(height: 6),
                      _buildSyarat(_hasUppercase, 'Mengandung huruf kapital'),
                    ],
                  ),
                ),
                _buildDivider(),
              ],

              _buildPasswordField(
                label: 'Konfirmasi Password',
                controller: _confirmPassController,
                hint: 'Ulangi password baru',
                visible: _confirmPassVisible,
                onToggle: () =>
                    setState(() => _confirmPassVisible = !_confirmPassVisible),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Konfirmasi password tidak boleh kosong';
                  if (v != _newPassController.text) return 'Password tidak cocok';
                  return null;
                },
              ),
            ]),

            const SizedBox(height: 24),

            // ── Tombol Simpan ──
            SizedBox(
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
                        'Simpan Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 40),
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
  //  PASSWORD FIELD
  // ─────────────────────────────────────────
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required VoidCallback onToggle,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
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
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: !visible,
                  onChanged: onChanged,
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
              ),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: const Color(0xFFBBBBBB),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  SYARAT CHECKLIST
  // ─────────────────────────────────────────
  Widget _buildSyarat(bool ok, String label) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 16,
          color: ok ? const Color(0xFF1DBFAA) : const Color(0xFFDDDDDD),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: ok ? const Color(0xFF0F6E56) : const Color(0xFFAAAAAA),
            fontWeight: ok ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}