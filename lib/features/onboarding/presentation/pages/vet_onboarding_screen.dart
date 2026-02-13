import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/routes/route_paths.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

class VetOnboardingScreen extends StatelessWidget {
  const VetOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: 140,
              child: Opacity(
                opacity: 0.12,
                child: Icon(
                  Icons.pets,
                  size: 180,
                  color: AppColors.accentColor,
                ),
              ),
            ),

            Positioned(
              right: 140,
              top: 140,
              bottom: 150,
              child: Opacity(
                opacity: 0.12,
                child: Icon(
                  Icons.pets,
                  size: 180,
                  color: AppColors.accentColor,
                ),
              ),
            ),

            Positioned(
              left: 8,
              top: 140,
              bottom: 200,
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  Icons.pets,
                  size: 180,
                  color: AppColors.accentColor,
                ),
              ),
            ),

            Positioned(
              left: 8,
              top: -200,
              bottom: 200,
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  Icons.pets,
                  size: 180,
                  color: AppColors.accentColor,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Care',
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                    fontSize: 48,
                                  ),
                            ),
                            Text(
                              'with',
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                    fontSize: 48,
                                  ),
                            ),
                            Text(
                              'Passion',
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                    fontSize: 48,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(left: 15, top: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: context.textPrimary.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image: const DecorationImage(
                            image: AssetImage('assets/images/pawcare.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Find your perfect pet companion',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontSize: 18),
                  ),
                ),
                SizedBox(
                  height: 420,
                  width: double.infinity,
                  child: Center(
                    child: Image.asset(
                      'assets/images/cat.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 10,
                        child: Container(
                          height: 120,
                          width: 180,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceColor,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: context.textPrimary.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),

                          child: Column(
                            children: [
                              Text(
                                'Find your perfect pet companion',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Row(
                                children: [
                                  Spacer(),
                                  SizedBox(
                                    height: 54,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        context.push(
                                          RoutePaths.onboardingServices,
                                        );
                                      },
                                      icon: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: context.textPrimary,
                                        child: Icon(
                                          Icons.pets,
                                          color: AppColors.buttonTextColor,
                                          size: 18,
                                        ),
                                      ),
                                      label: const Text('Get Started'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: -200,
                        bottom: 200,
                        child: Opacity(
                          opacity: 0.15,
                          child: Icon(
                            Icons.pets,
                            size: 180,
                            color: AppColors.accentColor,
                          ),
                        ),
                      ),

                      Positioned(
                        left: 8,
                        top: -200,
                        bottom: 200,
                        child: Opacity(
                          opacity: 0.15,
                          child: Icon(
                            Icons.pets,
                            size: 180,
                            color: AppColors.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
