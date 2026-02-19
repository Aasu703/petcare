import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/bookings/presentation/pages/manage_appointments_page.dart';
import 'package:petcare/features/bookings/presentation/pages/earnings_dashboard_page.dart';
import 'package:petcare/features/bookings/presentation/pages/provider_calendar_page.dart';
import 'package:petcare/features/bookings/presentation/view_model/booking_view_model.dart';
import 'package:petcare/features/provider/presentation/screens/provider_messages_screen.dart';
import 'package:petcare/features/provider/domain/utils/provider_access.dart';
import 'package:petcare/features/provider/presentation/widgets/provider_dashboard_components.dart';
import 'package:petcare/features/posts/presentation/pages/posts_screen.dart';
import 'package:petcare/features/health_records/presentation/pages/provider_vaccination_prescriptions_page.dart';
import 'package:petcare/features/provider_service/presentation/pages/apply_provider_service.dart';
import 'package:petcare/features/provider_service/presentation/pages/my_provider_services.dart';
import 'package:petcare/features/provider_service/presentation/view_model/provider_service_view_model.dart';
import 'package:petcare/features/shop/presentation/pages/manage_inventory_page.dart';
import 'package:petcare/features/shop/presentation/view_model/shop_view_model.dart';

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
    Future.microtask(_refreshDashboard);
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

  ProviderDashboardUiKit _uiKitForType(ProviderType providerType) {
    if (isShopProvider(providerType)) {
      return const ProviderDashboardUiKit(
        headerIcon: Icons.storefront_rounded,
        accentColor: Color(0xFF0F766E),
        accentSoft: Color(0xFFD1FAE5),
        headerGradientStart: Color(0xFFCCFBF1),
        headerGradientEnd: Color(0xFFFFEDD5),
        managementTitle: 'Store Operations',
      );
    }

    if (isGroomerProvider(providerType)) {
      return const ProviderDashboardUiKit(
        headerIcon: Icons.content_cut_rounded,
        accentColor: Color(0xFFBE185D),
        accentSoft: Color(0xFFFCE7F3),
        headerGradientStart: Color(0xFFFCE7F3),
        headerGradientEnd: Color(0xFFFFF7ED),
        managementTitle: 'Grooming Operations',
      );
    }

    if (isVetProvider(providerType)) {
      return const ProviderDashboardUiKit(
        headerIcon: Icons.health_and_safety_rounded,
        accentColor: Color(0xFF7C3AED),
        accentSoft: Color(0xFFEDE9FE),
        headerGradientStart: Color(0xFFEDE9FE),
        headerGradientEnd: Color(0xFFE0F2FE),
        managementTitle: 'Clinical Operations',
      );
    }

    return const ProviderDashboardUiKit(
      headerIcon: Icons.business_rounded,
      accentColor: Color(0xFF4F46E5),
      accentSoft: Color(0xFFE0E7FF),
      headerGradientStart: Color(0xFFE0E7FF),
      headerGradientEnd: Color(0xFFE0F2FE),
      managementTitle: 'Business Management',
    );
  }

  Future<void> _refreshDashboard() async {
    final session = ref.read(userSessionServiceProvider);
    final providerType = session.getProviderType();
    final providerId = session.getUserId();
    final futures = <Future<void>>[];

    if (canManageServices(providerType)) {
      futures.add(ref.read(providerServiceProvider.notifier).loadMyServices());
    }

    if (canManageBookings(providerType)) {
      futures.add(ref.read(providerBookingProvider.notifier).loadBookings());
    }

    if (canManageInventory(providerType) &&
        providerId != null &&
        providerId.isNotEmpty) {
      futures.add(
        ref.read(shopProvider.notifier).loadProviderInventory(providerId),
      );
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(userSessionServiceProvider);
    final providerType = session.getProviderType();
    final providerLabel = getProviderTypeLabel(providerType);
    final isShop = isShopProvider(providerType);
    final isVet = canAccessVetFeatures(providerType);
    final uiKit = _uiKitForType(providerType);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final statAspectRatio = screenWidth < 390 ? 1.02 : 1.18;

    final providerServiceState = ref.watch(providerServiceProvider);
    final providerBookingState = ref.watch(providerBookingProvider);
    final shopState = ref.watch(shopProvider);

    final activeServicesCount = providerServiceState.services
        .where(
          (service) => service.verificationStatus.toLowerCase() == 'approved',
        )
        .length;
    final pendingBookingsCount = providerBookingState.bookings
        .where((booking) => booking.status.toLowerCase() == 'pending')
        .length;
    final completedBookingsCount = providerBookingState.bookings
        .where((booking) => booking.status.toLowerCase() == 'completed')
        .length;
    final totalBookingRevenue = providerBookingState.bookings.fold<double>(
      0,
      (sum, booking) => sum + (booking.price ?? 0),
    );
    final inventoryCount = shopState.products.length;
    final lowStockCount = shopState.products
        .where((product) => product.quantity < 5)
        .length;
    final inventoryValue = shopState.products.fold<double>(
      0,
      (sum, product) => sum + ((product.price ?? 0) * product.quantity),
    );

    final dashboardStats = isShop
        ? [
            ProviderDashboardStat(
              label: 'Products',
              value: inventoryCount.toString(),
              icon: Icons.inventory_2_rounded,
              color: ProviderColors.inventory,
            ),
            ProviderDashboardStat(
              label: 'Low Stock Alerts',
              value: lowStockCount.toString(),
              icon: Icons.warning_amber_rounded,
              color: ProviderColors.bookings,
            ),
            ProviderDashboardStat(
              label: 'Inventory Value',
              value: '\$${inventoryValue.toStringAsFixed(0)}',
              icon: Icons.payments_rounded,
              color: ProviderColors.services,
            ),
          ]
        : [
            ProviderDashboardStat(
              label: 'Active Services',
              value: activeServicesCount.toString(),
              icon: Icons.medical_services_rounded,
              color: ProviderColors.services,
            ),
            ProviderDashboardStat(
              label: 'Pending Bookings',
              value: pendingBookingsCount.toString(),
              icon: Icons.schedule_rounded,
              color: ProviderColors.accent,
            ),
            ProviderDashboardStat(
              label: 'Completed Bookings',
              value: completedBookingsCount.toString(),
              icon: Icons.check_circle_rounded,
              color: ProviderColors.inventory,
            ),
            ProviderDashboardStat(
              label: 'Revenue Potential',
              value: '\$${totalBookingRevenue.toStringAsFixed(0)}',
              icon: Icons.attach_money_rounded,
              color: ProviderColors.analytics,
            ),
          ];

    final features = _getFeatureCards(context, providerType);
    final featureWidgets = _buildFeatureWidgets(context, features);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshDashboard,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Modern Header
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: ProviderDashboardHeader(
                      providerLabel: providerLabel,
                      isShop: isShop,
                      isVet: isVet,
                      uiKit: uiKit,
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
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dashboardStats.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: statAspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final stat = dashboardStats[index];
                        return ProviderDashboardStatCard(
                          title: stat.label,
                          value: stat.value,
                          icon: stat.icon,
                          color: stat.color,
                        );
                      },
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
                      uiKit.managementTitle,
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
                    child: Column(children: featureWidgets),
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

  List<ProviderDashboardFeature> _getFeatureCards(
    BuildContext context,
    ProviderType providerType,
  ) {
    final canServices = canManageServices(providerType);
    final canBookings = canManageBookings(providerType);
    final canInventory = canManageInventory(providerType);
    final isVet = canAccessVetFeatures(providerType);

    final cards = <ProviderDashboardFeature>[];

    if (canInventory) {
      cards.add(
        ProviderDashboardFeature(
          title: 'Inventory',
          subtitle: 'Manage products and stock',
          icon: Icons.inventory_2_rounded,
          color: ProviderColors.inventory,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageInventoryPage()),
            );
          },
        ),
      );
    }

    if (canServices) {
      cards.add(
        ProviderDashboardFeature(
          title: isVet ? 'Vet Services' : 'Grooming Services',
          subtitle: 'View and manage your services',
          icon: Icons.medical_services_rounded,
          color: ProviderColors.services,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MyProviderServicesScreen(),
              ),
            );
          },
        ),
      );

      cards.add(
        ProviderDashboardFeature(
          title: 'Apply for Service',
          subtitle: 'Submit a new provider service application',
          icon: Icons.assignment_rounded,
          color: ProviderColors.primary,
          onTap: () {
            final initialServiceType = isVet ? 'vet' : 'groomer';
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ApplyProviderServiceScreen(
                  initialServiceType: initialServiceType,
                  lockServiceType: true,
                ),
              ),
            );
          },
        ),
      );
    }

    if (canBookings) {
      cards.add(
        ProviderDashboardFeature(
          title: isVet ? 'Vet Appointments' : 'Bookings',
          subtitle: isVet
              ? 'Manage pet consultation requests'
              : 'View and manage appointments',
          icon: Icons.event_note_rounded,
          color: ProviderColors.bookings,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageAppointmentsPage()),
            );
          },
        ),
      );

      if (isVet) {
        cards.add(
          ProviderDashboardFeature(
            title: 'Vaccination Prescriptions',
            subtitle: 'See prescribed vaccinations by pet owner',
            icon: Icons.vaccines_rounded,
            color: ProviderColors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProviderVaccinationPrescriptionsPage(),
                ),
              );
            },
          ),
        );
      }

      cards.add(
        ProviderDashboardFeature(
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
      );
    }

    cards.addAll([
      ProviderDashboardFeature(
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
      ProviderDashboardFeature(
        title: 'Analytics',
        subtitle: canInventory
            ? 'Inventory and sales insights'
            : 'Earnings and service insights',
        icon: Icons.analytics_rounded,
        color: ProviderColors.analytics,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EarningsDashboardPage()),
          );
        },
      ),
      ProviderDashboardFeature(
        title: 'Posts',
        subtitle: 'Share blogs and updates',
        icon: Icons.post_add_rounded,
        color: ProviderColors.primary,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostsScreen()),
          );
        },
      ),
    ]);

    return cards;
  }

  List<Widget> _buildFeatureWidgets(
    BuildContext context,
    List<ProviderDashboardFeature> features,
  ) {
    final widgets = <Widget>[];
    for (final feature in features) {
      widgets.add(
        ProviderDashboardFeatureCard(
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
}
