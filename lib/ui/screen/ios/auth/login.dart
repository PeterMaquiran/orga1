import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// --- SCREEN 1: LOGIN ---
class OrgaLoginScreen extends StatelessWidget {
  const OrgaLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF), Color(0xFFDEE2E6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                'Orga',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                  color: Colors.black,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Text(
                  'Welcome back! Build, Track, and Achieve Together',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black54, height: 1.4),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    GlassButton(
                      text: 'Sign in with Apple',
                      icon: Icons.apple,
                      color: Color(0xFF0B0D10),
                      textColor: Colors.white,
                      onPressed: () => context.go('/home'),
                    ),
                    const SizedBox(height: 16),
                    GlassButton(
                      text: 'Continue with Google',
                      icon: Icons.g_mobiledata_rounded,
                      color: Colors.white.withOpacity(0.7),
                      textColor: Colors.black87,
                      onPressed: () => context.go('/home'),
                    ),
                    const SizedBox(height: 16),
                    GlassButton(
                      text: 'Continue with Email',
                      icon: Icons.email_outlined,
                        color: const Color(0xFF19C37D).withOpacity(0.9),
                      textColor: Colors.white,
                      onPressed: () => context.go('/confirm-email'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

// --- REUSABLE iOS 26 GLASS BUTTON WIDGET ---
class GlassButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const GlassButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  double _scale = 1.0;
  double _opacity = 1.0;

  void _handleTapDown(TapDownDetails details) {
    HapticFeedback.lightImpact(); // Tactile feedback
    setState(() {
      _scale = 0.96; // Shrink effect
      _opacity = 0.8; // Dimming effect
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
      _opacity = 1.0;
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: () => setState(() { _scale = 1.0; _opacity = 1.0; }),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 100),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                height: 64,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: widget.textColor, size: 26),
                    const SizedBox(width: 12),
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}