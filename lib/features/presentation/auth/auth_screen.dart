import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/network/api_providers.dart';
import 'package:gen_motion_ai/core/data/network/auth/dto/login.dto.dart';
import 'package:gen_motion_ai/core/data/network/auth/dto/register.dto.dart';
import 'package:gen_motion_ai/core/theme/app_theme.dart';
import 'package:gen_motion_ai/core/utils/responsive.dart';
import 'package:gen_motion_ai/features/presentation/auth/auth_provider.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true; // Trạng thái chuyển đổi giữa Login/Register
  bool _isLoading = false;
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

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authApi = ref.read(authApiProvider);

      if (_isLogin) {
        final response = await authApi.login(
          LoginDto(email: email, password: password),
        );
        await ref.read(authProvider.notifier).login(response);
        if (mounted) context.go('/explore');
      } else {
        final response = await authApi.register(
          RegisterDto(email: email, password: password),
        );
        await ref.read(authProvider.notifier).login(response);
        if (mounted) context.go('/explore');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final colors = context.appColors;
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(child: _buildThemeToggle(mode)),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final colors = context.appColors;
    return Row(
      children: [
        // Left Panel - Branding & Showcase
        Expanded(
          flex: 6,
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.heroStart, colors.heroEnd],
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
                      color: colors.heroGlow.withOpacity(0.08),
                      boxShadow: [
                        BoxShadow(
                          color: colors.heroGlow.withOpacity(0.18),
                          blurRadius: 100,
                          spreadRadius: 20,
                        ),
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
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Transform your ideas into stunning videos in seconds.\nJoin the next generation of content creators.',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.textSecondary,
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
            color: colors.background,
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
    final colors = context.appColors;
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
                  color: colors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
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
    final colors = context.appColors;
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
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Gen Motion AI',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    final colors = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _isLogin ? 'Welcome back' : 'Create an account',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin
              ? 'Please enter your details to sign in.'
              : 'Enter your details to get started with GenMotion.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 32),

        // Email Field
        _buildLabel('Email address'),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'name@example.com',
            prefixIcon: Icon(
              Icons.email_outlined,
              color: colors.textSecondary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Password Field
        _buildLabel('Password'),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: Icon(
              Icons.lock_outline,
              color: colors.textSecondary,
              size: 20,
            ),
            suffixIcon: Icon(
              Icons.visibility_off_outlined,
              color: colors.textSecondary,
              size: 20,
            ),
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
            onPressed: _isLoading ? null : _handleAuth,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
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
            Expanded(child: Divider(color: colors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: colors.textSecondary.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(child: Divider(color: colors.border)),
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
              _isLogin
                  ? "Don't have an account? "
                  : "Already have an account? ",
              style: TextStyle(color: colors.textSecondary),
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
    final colors = context.appColors;
    return Text(
      text,
      style: TextStyle(
        color: colors.textPrimary,
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
    final colors = context.appColors;
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: colors.surface,
          foregroundColor: colors.textPrimary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(ThemeMode mode) {
    final isDark = mode == ThemeMode.dark;
    final colors = context.appColors;

    return Material(
      color: colors.card.withOpacity(0.9),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => ref.read(themeModeProvider.notifier).toggle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(isDark ? 'Light mode' : 'Dark mode'),
            ],
          ),
        ),
      ),
    );
  }
}
