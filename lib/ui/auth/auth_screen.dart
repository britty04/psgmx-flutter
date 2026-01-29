import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/user_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSubmit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.endsWith('@psgtech.ac.in')) {
      setState(() => _error = 'Please enter a valid @psgtech.ac.in email');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await context.read<UserProvider>().requestOtp(email: email);
      if (success) {
        setState(() {
          _isOtpSent = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleOtpSubmit() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _error = 'Please enter valid 6-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await context.read<UserProvider>().verifyOtp(
        email: _emailController.text.trim(),
        otp: otp,
      );
      // Main navigation is handled by auth state listener in Router or Main
      // But we can also force it here if using GoRouter
      // However, usually UserProvider auth state change triggers router refresh.
      // If manually handling:
      // context.go('/');
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _isOtpSent = false;
      _otpController.clear();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   // Logo or Icon
                  Icon(
                    Icons.school_rounded,
                    size: 64,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'PSG MX',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isOtpSent 
                        ? 'Enter the code sent to your email' 
                        : 'Sign in with your college email',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 48),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isOtpSent ? _buildOtpForm(theme) : _buildEmailForm(theme),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (_isOtpSent) ...[
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: _isLoading ? null : _reset,
                      child: Text(
                        'Wrong email? Go back',
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm(ThemeData theme) {
    return Column(
      key: const ValueKey('email_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.inter(),
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'rollno@psgtech.ac.in',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.primaryColor, width: 2),
            ),
          ),
          onSubmitted: (_) => _handleEmailSubmit(),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleEmailSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text('Get OTP', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildOtpForm(ThemeData theme) {
    return Column(
      key: const ValueKey('otp_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: '000000',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.primaryColor, width: 2),
            ),
          ),
           onSubmitted: (_) => _handleOtpSubmit(),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleOtpSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text('Verify & Sign In', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
