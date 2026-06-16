import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/custom_text_field.dart';
import '../models/auth_request.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final request = LoginRequest(username: _usernameController.text, password: _passwordController.text);
    final result = await _authService.login(request);
    setState(() => _isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? (result['success'] ? 'Đăng nhập thành công' : 'Thất bại'))));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Hero Section: Blue with 3xl rounded bottom
            Container(
              height: size.height * 0.35,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24), // 3xl
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.medical_services, color: Colors.white, size: 64),
                    SizedBox(height: 12),
                    Text(
                      "MedAlert",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Login Form Card
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.28, left: 20, right: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(12), // xl
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Đăng nhập", 
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: "Tên đăng nhập",
                        hint: "Nhập username",
                        controller: _usernameController,
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: "Mật khẩu",
                        hint: "Nhập mật khẩu",
                        controller: _passwordController,
                        prefixIcon: Icons.lock_outline,
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text("Quên mật khẩu?", style: TextStyle(color: AppColors.primary)),
                        ),
                      ),

                      const SizedBox(height: 24),
                      
                      PrimaryButton(
                        label: "Đăng nhập",
                        isLoading: _isLoading,
                        onPressed: _handleLogin,
                      ),
                      
                      const SizedBox(height: 24),
                      const Center(child: Text("Hoặc đăng nhập với", style: TextStyle(color: AppColors.textMuted, fontSize: 14))),
                      const SizedBox(height: 16),
                      
                      // Social Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialButton("Google"),
                          const SizedBox(width: 16),
                          _socialButton("Facebook"),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(String label) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(label, style: const TextStyle(color: AppColors.textDark)),
    );
  }
}