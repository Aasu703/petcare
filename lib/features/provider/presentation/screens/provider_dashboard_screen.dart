import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/bookings/presentation/pages/manage_appointments_page.dart';
import 'package:petcare/features/bookings/presentation/pages/earnings_dashboard_page.dart';
import 'package:petcare/features/bookings/presentation/pages/provider_calendar_page.dart';
import 'package:petcare/features/provider/presentation/screens/provider_messages_screen.dart';
import 'package:petcare/features/provider/presentation/screens/provider_notifications_screen.dart';
import 'package:petcare/features/posts/presentation/pages/posts_screen.dart';
import 'package:petcare/features/provider_service/presentation/pages/apply_provider_service.dart';
import 'package:petcare/features/provider_service/presentation/pages/my_provider_services.dart';
import 'package:petcare/features/provider_service/presentation/view_model/provider_service_view_model.dart';
import 'package:petcare/features/shop/presentation/pages/manage_inventory_page.dart';

// Modern color palette for Provider Dashboard
class ProviderColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color accent = Color(0xFFF59E0B);
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color services = Color(0xFF10B981);
  static const Color inventory = Color(0xFFF59E0B);
  static const Color bookings = Color(0xFFEF4444);
  static const Color messages = Color(0xFF8B5CF6);
  static const Color analytics = Color(0xFF06B6D4);
  static const Color shadow = Color(0x1A6366F1);
}

class ProviderDashboardScreen extends ConsumerStatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  ConsumerState<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState
    extends ConsumerState<ProviderDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _statsController;
  late AnimationController _servicesController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _statsScale;
  late Animation<double> _servicesFade;

  bool isInTest = false;

  @override
  void initState() {
    super.initState();

    assert(() {
      isInTest = true;
      return true;
    }());

    _headerController = AnimationController(
      vsync: this,
      duration: isInTest ? Duration.zero : const Duration(milliseconds: 600),
    );

    _statsController = AnimationController(
      vsync: this,
      duration: isInTest ? Duration.zero : const Duration(milliseconds: 800),
    );

    _servicesController = AnimationController(
      vsync: this,
      duration: isInTest ? Duration.zero : const Duration(milliseconds: 1000),
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _headerController,
            curve: Curves.easeOutCubic,
          ),
        );

    _statsScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.elasticOut),
    );

    _servicesFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _servicesController, curve: Curves.easeOut),
    );

    _headerController.forward();
    Future.microtask(
      () => ref.read(providerServiceProvider.notifier).loadMyServices(),
    );
    Future.delayed(
      const Duration(milliseconds: 200),
      () => _statsController.forward(),
    );
    Future.delayed(
      const Duration(milliseconds: 400),
      () => _servicesController.forward(),
    );
  }

  @override
  void dispose() {
    _headerController.dispose();
    _statsController.dispose();
    _servicesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(userSessionServiceProvider);
    final providerType = (session.getProviderType() ?? '').toLowerCase();
    final providerLabel = _providerTypeLabel(providerType);

    final providerServiceState = ref.watch(providerServiceProvider);
    final activeServicesCount = providerServiceState.services
        .where(
          (service) => service.verificationStatus.toLowerCase() == 'approved',
        )
        .length;
    final pendingServicesCount = providerServiceState.services
        .where(
          (service) => service.verificationStatus.toLowerCase() == 'pending',
        )
        .length;

    final features = _getFeatureCards(context, providerType);
    final featureWidgets = _buildFeatureWidgets(context, features);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(providerServiceProvider.notifier).loadMyServices(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Modern Header
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.iconPrimaryColor.withValues(alpha: 0.16),
                              context.accentColor.withValues(alpha: 0.12),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: context.iconPrimaryColor.withValues(
                              alpha: 0.18,
                            ),
                          ),
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
                                      color: context.iconPrimaryColor
                                          .withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.business_rounded,
                                          size: 14,
                                          color: context.iconPrimaryColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '$providerLabel Dashboard',
                                          style: TextStyle(
                                            color: context.iconPrimaryColor,
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: context.textPrimary,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.4,
                                          height: 1.1,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Manage your pet care business',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: context.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            _buildNotificationButton(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Statistics Cards
              SliverToBoxAdapter(
                child: ScaleTransition(
                  scale: _statsScale,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Today\'s Bookings',
                            '12',
                            Icons.event_available_rounded,
                            ProviderColors.services,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Revenue',
                            '\$2,450',
                            Icons.attach_money_rounded,
                            ProviderColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              SliverToBoxAdapter(
                child: ScaleTransition(
                  scale: _statsScale,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Active Services',
                            activeServicesCount.toString(),
                            Icons.medical_services_rounded,
                            ProviderColors.inventory,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Pending Reviews',
                            pendingServicesCount.toString(),
                            Icons.chat_bubble_rounded,
                            ProviderColors.messages,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // Services Section
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _servicesFade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Business Management',
                      style: TextStyle(
                        color: ProviderColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _servicesFade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: featureWidgets,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  String _providerTypeLabel(String providerType) {
    switch (providerType) {
      case 'vet':
        return 'Veterinary';
      case 'shop':
        return 'Shop';
      case 'babysitter':
        return 'Groomer';
      default:
        return 'Business';
    }
  }

  List<_FeatureCard> _getFeatureCards(
    BuildContext context,
    String providerType,
  ) {
    final isShop = providerType == 'shop';
    final servicesTitle = isShop ? 'Shop Services' : 'Services';
    final servicesSubtitle = isShop
        ? 'View your shop service listings'
        : 'View and manage your provider services';

    return [
      if (isShop)
        _FeatureCard(
          title: 'Inventory',
          subtitle: 'Manage products & stock',
          icon: Icons.inventory_2,
          color: ProviderColors.inventory,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageInventoryPage()),
            );
          },
        ),
      _FeatureCard(
        title: servicesTitle,
        subtitle: servicesSubtitle,
        icon: Icons.medical_services_rounded,
        color: ProviderColors.services,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyProviderServicesScreen()),
          );
        },
      ),
      _FeatureCard(
        title: 'Apply for Service',
        subtitle: 'Submit a new provider service application',
        icon: Icons.assignment_rounded,
        color: ProviderColors.inventory,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ApplyProviderServiceScreen()),
          );
        },
      ),
      _FeatureCard(
        title: 'Bookings',
        subtitle: 'View & manage appointments',
        icon: Icons.event_note_rounded,
        color: ProviderColors.bookings,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManageAppointmentsPage()),
          );
        },
      ),
      _FeatureCard(
        title: 'Messages',
        subtitle: 'Chat with pet owners',
        icon: Icons.chat_bubble_rounded,
        color: ProviderColors.messages,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProviderMessagesScreen()),
          );
        },
      ),
      _FeatureCard(
        title: 'Calendar',
        subtitle: 'View booking calendar',
        icon: Icons.calendar_month_rounded,
        color: ProviderColors.messages,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProviderCalendarPage()),
          );
        },
      ),
      _FeatureCard(
        title: 'Analytics',
        subtitle: 'Earnings & business insights',
        icon: Icons.analytics_rounded,
        color: ProviderColors.analytics,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EarningsDashboardPage()),
          );
        },
      ),
      _FeatureCard(
        title: 'Posts',
        subtitle: 'Share blogs & updates',
        icon: Icons.post_add_rounded,
        color: ProviderColors.primary,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostsScreen()),
          );
        },
      ),
    ];
  }

  List<Widget> _buildFeatureWidgets(
    BuildContext context,
    List<_FeatureCard> features,
  ) {
    final widgets = <Widget>[];
    for (final feature in features) {
      widgets.add(
        _buildModernServiceCard(
          context,
          title: feature.title,
          subtitle: feature.subtitle,
          icon: feature.icon,
          color: feature.color,
          onTap: feature.onTap,
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    if (widgets.isNotEmpty) {
      widgets.removeLast();
    }
    return widgets;
  }

  Widget _buildNotificationButton(BuildContext context) {
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
        icon: Icon(Icons.notifications_outlined, color: context.textPrimary),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernServiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(24),
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
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: context.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
