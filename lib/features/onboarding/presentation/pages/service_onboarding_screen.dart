import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/routes/route_paths.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/app/l10n/app_localizations.dart';

class ServiceOnboardingScreen extends StatelessWidget {
  const ServiceOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: -60,
              top: 120,
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
              left: -30,
              bottom: 120,
              child: Opacity(
                opacity: 0.12,
                child: Icon(
                  Icons.pets,
                  size: 220,
                  color: AppColors.accentColor,
                ),
              ),
            ),

            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.tr('trusted'),
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.05,
                                    fontSize: 46,
                                  ),
                            ),
                            Text(
                              l10n.tr('care'),
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.05,
                                    fontSize: 46,
                                  ),
                            ),
                            Text(
                              l10n.tr('network'),
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.05,
                                    fontSize: 46,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 96,
                        height: 96,
                        margin: const EdgeInsets.only(left: 18),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: context.textPrimary.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
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
                    l10n.tr('discoverTrustedSitters'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      height: 1.4,
                    ),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: context.textPrimary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.tr('readyToGetStarted'),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.tr('joinCommunity'),
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontSize: 17),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: ElevatedButton(
                            onPressed: () {
                              context.go(RoutePaths.login);
                            },
                            child: Text(l10n.tr('signIn')),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: OutlinedButton(
                            onPressed: () {
                              context.push(RoutePaths.register);
                            },
                            child: Text(l10n.tr('signUp')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
