import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BahasaScreen extends StatefulWidget {
  const BahasaScreen({super.key});

  @override
  State<BahasaScreen> createState() => _BahasaScreenState();
}

class _BahasaScreenState extends State<BahasaScreen> {
  String _selectedLang = 'id';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLang();
  }

  Future<void> _loadSavedLang() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLang = prefs.getString('language') ?? 'id';
    });
  }

  Future<void> _pilihBahasa(String lang) async {
    if (_selectedLang == lang) return;

    setState(() {
      _selectedLang = lang;
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);

    setState(() => _isLoading = false);

    if (!mounted) return;
    final label = lang == 'id' ? 'Bahasa Indonesia' : 'English';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bahasa diubah ke $label'),
        backgroundColor: const Color(0xFF0F6E56),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
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
          'Bahasa',
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
          _buildSectionLabel('PILIH BAHASA'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEAEAEA), width: 0.5),
            ),
            child: Column(
              children: [
                _buildLangItem(
                  lang: 'id',
                  flag: '🇮🇩',
                  name: 'Bahasa Indonesia',
                  native: 'Indonesia',
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 68),
                  child: Divider(
                      height: 0.5, thickness: 0.5, color: Colors.grey.shade100),
                ),
                _buildLangItem(
                  lang: 'en',
                  flag: '🇬🇧',
                  name: 'English',
                  native: 'Inggris',
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
  //  LANGUAGE ITEM
  // ─────────────────────────────────────────
  Widget _buildLangItem({
    required String lang,
    required String flag,
    required String name,
    required String native,
  }) {
    final selected = _selectedLang == lang;

    return InkWell(
      onTap: _isLoading ? null : () => _pilihBahasa(lang),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Flag
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            // Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected
                          ? const Color(0xFF1A2744)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    native,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888780),
                    ),
                  ),
                ],
              ),
            ),
            // Radio button
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF1DBFAA)
                      : const Color(0xFFDDDDDD),
                  width: 2,
                ),
                color: selected ? const Color(0xFF1DBFAA) : Colors.white,
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}