import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:laporit_app/core/constants/app_colors.dart';
import 'package:laporit_app/core/constants/app_constants.dart';
import 'package:laporit_app/features/user/dashboard_user.dart';
import 'package:laporit_app/features/admin/dashboard_admin.dart';
import 'package:laporit_app/features/operator/dashboard_operator.dart';
import 'package:laporit_app/features/user/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    if (rememberMe) {
      setState(() {
        _rememberMe = true;
        _emailController.text = prefs.getString('saved_email') ?? '';
        _passwordController.text = prefs.getString('saved_password') ?? '';
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_email', _emailController.text);
      await prefs.setString('saved_password', _passwordController.text);
    } else {
      await prefs.remove('remember_me');
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Mohon lengkapi data!', AppColors.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _saveCredentials();

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final role = data['user']['role'];
        final name = data['user']['name'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('role', role);
        await prefs.setString('name', name);

        _showSnackBar('Login berhasil!', AppColors.success);

        if (!mounted) return;

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardAdmin()),
          );
        } else if (role == 'operator') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardOperator()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen ()),
          );
        }
      } else {
        _showSnackBar(data['message'] ?? 'Login gagal', AppColors.error);
      }
    } catch (e) {
      _showSnackBar('Password atau Username Salah', AppColors.error);
    }

    setState(() => _isLoading = false);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Animated Logo
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.laptop_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Lapor IT",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    "Sistem Pelaporan Kerusakan IT",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Card Login
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Email Field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.person_outline,
                                color: AppColors.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock_outline,
                                color: AppColors.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.primary,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Remember Me + Lupa Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() => _rememberMe = value ?? false);
                                    },
                                    activeColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Ingat Saya",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => _showSnackBar(
                                  'Fitur coming soon!', AppColors.accent),
                              child: Text(
                                "Lupa Password?",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Button Login
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: AppColors.primary.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Memproses...'),
                                    ],
                                  )
                                : const Text(
                                    "MASUK",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Support Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Kendala akses? ",
                          style: TextStyle(color: Colors.white70)),
                      GestureDetector(
                        onTap: () => _showSnackBar(
                            'WhatsApp: 0812-3456-7890', AppColors.accent),
                        child: Text(
                          "Hubungi Admin",
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Badan Pusat Statistik Deli Serdang",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}