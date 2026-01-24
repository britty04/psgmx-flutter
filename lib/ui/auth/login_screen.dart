import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../core/theme/app_dimens.dart';
import '../widgets/premium_card.dart';

/// LoginScreen: Sign in with email and password
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validate email format and domain
  bool _validateEmail() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return false;
    }

    if (!email.contains('@')) {
      setState(() => _emailError = 'Enter a valid email');
      return false;
    }

    if (!email.endsWith('@psgtech.ac.in')) {
      setState(() => _emailError = 'Use your college email (@psgtech.ac.in)');
      return false;
    }

    setState(() => _emailError = null);
    return true;
  }

  /// Validate password field
  bool _validatePassword() {
    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return false;
    }

    setState(() => _passwordError = null);
    return true;
  }

  /// Handle sign in
  Future<void> _handleSignIn() async {
    // Clear previous errors
    setState(() => _generalError = null);

    // Validate fields
    final emailValid = _validateEmail();
    final passwordValid = _validatePassword();

    if (!emailValid || !passwordValid) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text;

      debugPrint('[LoginScreen] Signing in user: $email');

      // Sign in via UserProvider
      await Provider.of<UserProvider>(context, listen: false).signIn(
        email: email,
        password: password,
      );

      debugPrint('[LoginScreen] Sign in successful');

      // Navigation is handled by auth state change listener in router
      // User will be redirected to dashboard automatically
    } catch (e) {
      debugPrint('[LoginScreen] Sign in error: $e');
      if (mounted) {
        setState(() {
          _generalError = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine layout mode
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow, // Distinct background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               // Brand / Logo Section
               Column(
                 children: [
                   Container(
                     height: 60, width: 60,
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                         begin: Alignment.topLeft,
                         end: Alignment.bottomRight,
                       ),
                       borderRadius: BorderRadius.circular(16),
                       boxShadow: [
                         BoxShadow(
                           color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                           blurRadius: 15,
                           offset: const Offset(0, 8)
                         )
                       ]
                     ),
                     child: const Icon(Icons.school, color: Colors.white, size: 32),
                   ),
                   const SizedBox(height: AppSpacing.lg),
                   Text(
                     "PSG MCA Prep",
                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                       fontWeight: FontWeight.bold,
                       color: Theme.of(context).colorScheme.onSurface,
                     ),
                   ),
                   const SizedBox(height: AppSpacing.xs),
                   Text(
                     "Sign in to continue your progress",
                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                       color: Theme.of(context).colorScheme.onSurfaceVariant
                     ),
                   )
                 ],
               ),
               
               const SizedBox(height: AppSpacing.xxl),
               
               // The Login Card
               ConstrainedBox(
                 constraints: const BoxConstraints(maxWidth: 400),
                 child: PremiumCard(
                   color: Theme.of(context).colorScheme.surface,
                   padding: const EdgeInsets.all(AppSpacing.xl),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.stretch,
                     children: [
                       
                       // Email Input
                       Text(
                         "College Email", 
                         style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)
                       ),
                       const SizedBox(height: AppSpacing.sm),
                       TextField(
                          controller: _emailController,
                          enabled: !_isLoading,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'john.doe@psgtech.ac.in',
                            prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.outline),
                            errorText: _emailError,
                          ),
                          onChanged: (_) {
                            if (_emailError != null) _validateEmail();
                          },
                        ),
                        
                        const SizedBox(height: AppSpacing.lg),

                       // Password Input
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                            Text(
                              "Password", 
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)
                            ),
                            GestureDetector(
                               onTap: _isLoading ? null : () => context.push('/forgot_password'),
                               child: Text(
                                 "Forgot?",
                                 style: TextStyle(
                                   color: Theme.of(context).colorScheme.primary,
                                   fontWeight: FontWeight.w600,
                                   fontSize: 12,
                                 ),
                               ),
                            )
                         ],
                       ),
                       const SizedBox(height: AppSpacing.sm),
                       TextField(
                          controller: _passwordController,
                          enabled: !_isLoading,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword ? Icons.visibility : Icons.visibility_off,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              onPressed: () => setState(() => _showPassword = !_showPassword),
                            ),
                            errorText: _passwordError,
                          ),
                          onChanged: (_) {
                            if (_passwordError != null) _validatePassword();
                          },
                        ),
                        
                        const SizedBox(height: AppSpacing.xl),

                        /// General Error Message
                        if (_generalError != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: Theme.of(context).colorScheme.errorContainer),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 20),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    _generalError!,
                                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Submit Button
                        FilledButton(
                          onPressed: _isLoading ? null : _handleSignIn,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.all(AppSpacing.md),
                          ),
                          child: _isLoading 
                             ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                             : const Text("Sign In"),
                        ),

                     ],
                   ),
                 ),
               ),
               
               const SizedBox(height: AppSpacing.xxl),
               
               // Footer
               Text(
                 "© 2026 PSG College of Technology",
                 style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
               )
            ],
          ),
        ),
      ),
    );
  }
}
