import 'package:flutter/material.dart';
import 'package:gen_motion_ai/core/theme/app_theme.dart';
import 'package:gen_motion_ai/core/utils/responsive.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true; // Trạng thái chuyển đổi giữa Login/Register
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Panel - Branding & Showcase
        Expanded(
          flex: 6,
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.surfaceColor,
              // Giả lập background đẹp mắt hoặc dùng ảnh thật
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E1E24), Color(0xFF0F0F10)],
              ),
            ),
            child: Stack(
              children: [
                // Decorative elements
                Positioned(
                  top: -100,
                  left: -100,
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          blurRadius: 100,
                          spreadRadius: 20,
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLogo(),
                      const Spacer(),
                      Text(
                        'Unleash your creativity\nwith AI Video Generation',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Transform your ideas into stunning videos in seconds.\nJoin the next generation of content creators.',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                      const SizedBox(height: 40),
                ],
              ),
                ),
              ],
            ),
          ),
        ),
        // Right Panel - Auth Form
        Expanded(
          flex: 5,
          child: Container(
            color: AppTheme.backgroundColor,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: _buildFormContent(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildLogo(),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: _buildFormContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return GestureDetector(
      onTap: () => context.go('/explore'), // Cho phép quay về trang chủ
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.accentPurple],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Gen Motion AI',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _isLogin ? 'Welcome back' : 'Create an account',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin
              ? 'Please enter your details to sign in.'
              : 'Enter your details to get started with GenMotion.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 32),

        // Email Field
        _buildLabel('Email address'),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'name@example.com',
            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary, size: 20),
          ),
        ),
        const SizedBox(height: 20),

        // Password Field
        _buildLabel('Password'),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: '••••••••',
            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary, size: 20),
            suffixIcon: Icon(Icons.visibility_off_outlined, color: AppTheme.textSecondary, size: 20),
          ),
        ),

        // Forgot Password (Login only)
        if (_isLogin) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 32),

        // Main Action Button
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Mock login success -> go to home
              context.go('/explore');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              _isLogin ? 'Sign In' : 'Create Account',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Divider
        Row(
          children: [
            const Expanded(child: Divider(color: AppTheme.borderColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppTheme.borderColor)),
          ],
        ),

        const SizedBox(height: 24),

        // Social Login Button
        _buildSocialButton(
          label: 'Continue with Google',
          icon: Icons.g_mobiledata,
          onTap: () {},
        ),

        const SizedBox(height: 32),

        // Toggle Login/Register
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLogin ? "Don't have an account? " : "Already have an account? ",
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            GestureDetector(
              onTap: _toggleAuthMode,
              child: Text(
                _isLogin ? 'Sign up' : 'Sign in',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: AppTheme.surfaceColor, // Màu nền tối hơn card một chút
          foregroundColor: AppTheme.textPrimary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
