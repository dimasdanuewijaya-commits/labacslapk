import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:labtrack_pro/theme/app_theme.dart';
import 'package:labtrack_pro/widgets/glass_card.dart';
import 'package:labtrack_pro/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remembered_email');
    final savedPassword = prefs.getString('remembered_password');
    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final _authService = AuthService();

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan isi Email dan Password Anda.')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmailPassword(email, password);
      
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('remembered_email', email);
        await prefs.setString('remembered_password', password);
      } else {
        await prefs.remove('remembered_email');
        await prefs.remove('remembered_password');
      }

      if (mounted) {
        if (email.toLowerCase() == 'admin@lab.com' || email.toLowerCase() == 'admin@lab.acsl.com') {
          Navigator.of(context).pushReplacementNamed('/admin_main');
        } else {
          Navigator.of(context).pushReplacementNamed('/main');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          // Atmospheric animated background
          _buildBackground(),
          // Login content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.containerPadding),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBranding(),
                      const SizedBox(height: 16),
                      _buildLoginCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Top-right blue blob
            Positioned(
              top: -MediaQuery.of(context).size.height * 0.1,
              right: -MediaQuery.of(context).size.width * 0.1,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, _) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary.withValues(alpha: 0.1),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Bottom-left teal blob
            Positioned(
              bottom: -MediaQuery.of(context).size.height * 0.1,
              left: -MediaQuery.of(context).size.width * 0.1,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.tertiary.withValues(alpha: 0.1),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/logo_acsl.jpeg',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'ACSL',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            height: 44 / 36,
            letterSpacing: -0.8,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ADVANCED COMPUTER SYSTEM LABORATORY',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            height: 14 / 10,
            letterSpacing: 0.5,
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email field
            _buildTextField(
              controller: _emailController,
              icon: Icons.alternate_email,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            // Password field
            _buildPasswordField(),
            const SizedBox(height: 16),
            // Remember & Forgot
            _buildRememberForgot(),
            const SizedBox(height: 20),
            // Login button
            _buildLoginButton(),
            // Footer
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppTheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '© 2026 ACSL. ALL RIGHTS RESERVED.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: AppTheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 16, color: AppTheme.onSurface),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(icon, size: 20, color: AppTheme.outline),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 28),
        labelText: label,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        floatingLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: GoogleFonts.inter(fontSize: 16, color: AppTheme.onSurface),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(Icons.lock_open, size: 20, color: AppTheme.outline),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 28),
        labelText: 'Password',
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        floatingLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppTheme.primary,
        ),
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            size: 18,
            color: AppTheme.outlineVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _rememberMe ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _rememberMe
                        ? AppTheme.primary
                        : AppTheme.outlineVariant,
                    width: 2,
                  ),
                ),
                child: _rememberMe
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                'Remember Me',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            'Forgot Password?',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: AppTheme.touchTarget,
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: AppTheme.primary.withValues(alpha: 0.2),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation(AppTheme.onPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Processing...',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Login',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
      ),
    );
  }
}

// Helper AnimatedBuilder that works with Animation<double>
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
