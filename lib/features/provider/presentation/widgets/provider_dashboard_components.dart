import 'package:flutter/material.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/provider/presentation/screens/provider_notifications_screen.dart';

class ProviderDashboardFeature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ProviderDashboardFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class ProviderDashboardStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const ProviderDashboardStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class ProviderDashboardUiKit {
  final IconData headerIcon;
  final Color accentColor;
  final Color accentSoft;
  final Color headerGradientStart;
  final Color headerGradientEnd;
  final String managementTitle;

  const ProviderDashboardUiKit({
    required this.headerIcon,
    required this.accentColor,
    required this.accentSoft,
    required this.headerGradientStart,
    required this.headerGradientEnd,
    required this.managementTitle,
  });
}

class ProviderDashboardHeader extends StatelessWidget {
  final String providerLabel;
  final bool isShop;
  final bool isVet;
  final ProviderDashboardUiKit uiKit;

  const ProviderDashboardHeader({
    super.key,
    required this.providerLabel,
    required this.isShop,
    required this.isVet,
    required this.uiKit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [uiKit.headerGradientStart, uiKit.headerGradientEnd],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: uiKit.accentColor.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: uiKit.accentSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          uiKit.headerIcon,
                          size: 14,
                          color: uiKit.accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$providerLabel Dashboard',
                          style: TextStyle(
                            color: uiKit.accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome back!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isShop
                        ? 'Manage products and stock visibility'
                        : isVet
                        ? 'Manage vet services and appointments'
                        : 'Manage grooming and care bookings',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _NotificationButton(accentColor: uiKit.accentColor),
          ],
        ),
      ),
    );
  }
}

class ProviderDashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const ProviderDashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: context.textPrimary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ProviderDashboardFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ProviderDashboardFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.16)),
          boxShadow: [
            BoxShadow(
              color: context.textPrimary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final Color accentColor;

  const _NotificationButton({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.textPrimary.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProviderNotificationsScreen(),
            ),
          );
        },
        icon: Icon(Icons.notifications_outlined, color: accentColor),
      ),
    );
  }
}
