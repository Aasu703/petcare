import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/providers/session_providers.dart';
import 'package:petcare/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:petcare/core/services/session/session_service.dart';
import 'package:petcare/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:petcare/app/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    // 3-second animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
    );

    _scale = Tween<double>(
      begin: 0.85,
      end: 1.10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Start animation
    _controller.forward();

    // Navigate when animation finishes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _goToNext();
      }
    });

    // Safety timeout in case of edge cases (optional)
    Timer(const Duration(seconds: 4), () {
      if (mounted) _goToNext();
    });
  }

  Future<void> _goToNext() async {
    final container = ProviderScope.containerOf(context);
    final session = container.read(sessionServiceProvider);

    final loggedIn = session.isLoggedIn();
    if (!mounted) return;
    if (loggedIn) {
      final firstName = await session.getFirstName() ?? 'User';
      final email = await session.getEmail() ?? '';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Dashboard(firstName: firstName, email: email),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Onbording()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 240, 126),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Replace with your asset path or logo widget
                Image.asset(
                  'assets/images/pawcare.png',
                  width: size.width * 0.45,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  'PawCare',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
