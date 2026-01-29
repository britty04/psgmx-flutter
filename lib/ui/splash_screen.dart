import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern Minimal Splash Screen for PSGMX
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Logo with Clean Animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Hero(
                        tag: 'psgmx_logo',
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(90),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.15),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(90),
                            child: Image.asset(
                              'assets/images/psgmx_logo_transparent.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        colorScheme.primary,
                                        colorScheme.secondary,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(90),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'P',
                                      style: GoogleFonts.poppins(
                                        fontSize: 72,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Brand Name - Clean Typography
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'PSGMX',
                      style: GoogleFonts.poppins(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: 3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tagline
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Placement Excellence',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Minimal Loading Indicator
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                        backgroundColor: colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
