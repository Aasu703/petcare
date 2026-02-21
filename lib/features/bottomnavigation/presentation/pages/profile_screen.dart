import 'package:petcare/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/routes/route_paths.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/auth/presentation/view_model/profile_view_model.dart';
import 'package:petcare/features/auth/presentation/view_model/session_notifier.dart';
import 'package:petcare/app/theme/theme_provider.dart';
import 'package:petcare/features/bottomnavigation/presentation/pages/edit_profile_screen.dart';
import 'package:petcare/features/pet/presentation/pages/my_pet.dart';
import 'package:petcare/features/posts/presentation/pages/posts_screen.dart';
import 'package:petcare/features/provider_service/presentation/pages/apply_provider_service.dart';
import 'package:petcare/features/provider_service/presentation/pages/my_provider_services.dart';

// Modern color palette - Theme Aware
class ProfileColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B85FF);
  static const Color primaryDark = Color(0xFF5046E5);
  static const Color accent = Color(0xFFFF6584);

  // Light theme colors
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF2D3142);
  static const Color textSecondaryLight = Color(0xFF9CA3AF);

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Colors.white70;

  static const Color editProfile = Color(0xFF4ECFFF);
  static const Color myPets = Color(0xFFFF6B9D);
  static const Color notifications = Color(0xFF9D6BFF);
  static const Color theme = Color(0xFFFFB84D);
  static const Color help = Color(0xFF00D4FF);
  static const Color logout = Color(0xFFFF4757);

  // Theme-aware getters
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceDark
        : surfaceLight;
  }

  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimaryDark
        : textPrimaryLight;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textSecondaryDark
        : textSecondaryLight;
  }
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _avatarScale;

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
      duration: isInTest ? Duration.zero : const Duration(milliseconds: 800),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: isInTest ? Duration.zero : const Duration(milliseconds: 1000),
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _headerController,
            curve: Curves.easeOutCubic,
          ),
        );

    _avatarScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.elasticOut),
    );

    Future.microtask(
      () => ref.read(profileViewModelProvider.notifier).loadProfile(),
    );

    _headerController.forward();
    Future.delayed(
      const Duration(milliseconds: 300),
      () => _contentController.forward(),
    );
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(userSessionServiceProvider);
    final profileState = ref.watch(profileViewModelProvider);
    final themeMode = ref.watch(themeModeProvider);

    final avatar = profileState.user?.avatar;
    final resolvedAvatarUrl = (avatar != null && avatar.isNotEmpty)
        ? ApiEndpoints.resolveMediaUrl(avatar)
        : null;
    final hasAvatarImage = resolvedAvatarUrl != null;
    final displayName = session.getFirstName() ?? 'User';
    final displayEmail = session.getEmail() ?? '';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Modern Header with Glassmorphism Effect
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                          spreadRadius: -10,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative circles
                        Positioned(
                          right: -50,
                          top: -30,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -30,
                          bottom: 60,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 40, 24, 50),
                          child: Column(
                            children: [
                              // Avatar with animated scale
                              ScaleTransition(
                                scale: _avatarScale,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                        spreadRadius: -5,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 55,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.2,
                                    ),
                                    child: hasAvatarImage
                                        ? ClipOval(
                                            child: Image.network(
                                              resolvedAvatarUrl,
                                              width: 110,
                                              height: 110,
                                              fit: BoxFit.cover,
                                              loadingBuilder:
                                                  (
                                                    context,
                                                    child,
                                                    loadingProgress,
                                                  ) => loadingProgress == null
                                                  ? child
                                                  : Center(
                                                      child: SizedBox(
                                                        width: 22,
                                                        height: 22,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      ),
                                                    ),
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.person_rounded,
                                                    size: 55,
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.person_rounded,
                                            size: 55,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Name
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Email
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      size: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      displayEmail,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Body Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 28),

                    // Modern Stats Section
                    _buildModernStatsSection(),

                    const SizedBox(height: 36),

                    // Account Section
                    _buildModernMenuSection(
                      'Account',
                      Icons.person_outline_rounded,
                      [
                        _MenuItem(
                          icon: Icons.edit_rounded,
                          title: 'Edit Profile',
                          subtitle: 'Update your personal information',
                          color: ProfileColors.editProfile,
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );

                            if (updated == true) {
                              await ref
                                  .read(profileViewModelProvider.notifier)
                                  .loadProfile();
                            }
                          },
                        ),
                        _MenuItem(
                          icon: Icons.pets_rounded,
                          title: 'My Pets',
                          subtitle: 'Manage your pets & their health',
                          color: ProfileColors.myPets,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MyPet()),
                            );
                          },
                        ),
                        _MenuItem(
                          icon: Icons.storefront_rounded,
                          title: 'My Services',
                          subtitle: 'View your provider service applications',
                          color: ProfileColors.myPets,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const MyProviderServicesScreen(),
                              ),
                            );
                          },
                        ),
                        _MenuItem(
                          icon: Icons.post_add_rounded,
                          title: 'Posts',
                          subtitle: 'View and create posts',
                          color: ProfileColors.myPets,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PostsScreen(),
                              ),
                            );
                          },
                        ),
                        _MenuItem(
                          icon: Icons.work_outline_rounded,
                          title: 'Apply as Provider',
                          subtitle: 'Submit documents to offer services',
                          color: ProfileColors.editProfile,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ApplyProviderServiceScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                      delay: 0,
                    ),

                    const SizedBox(height: 28),

                    // Preferences Section
                    _buildModernMenuSection('Preferences', Icons.tune_rounded, [
                      _MenuItem(
                        icon: Icons.notifications_rounded,
                        title: 'Notifications',
                        subtitle: 'Alerts, reminders & updates',
                        color: ProfileColors.notifications,
                        trailing: _buildToggleSwitch(true),
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.dark_mode_rounded,
                        title: 'Dark Mode',
                        subtitle: 'Switch app appearance',
                        color: ProfileColors.theme,
                        trailing: _buildToggleSwitch(
                          themeMode == ThemeMode.dark,
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (themeMode == ThemeMode.dark) {
                            ref.read(themeModeProvider.notifier).setLight();
                          } else {
                            ref.read(themeModeProvider.notifier).setDark();
                          }
                        },
                      ),
                    ], delay: 100),

                    const SizedBox(height: 28),

                    // Support Section
                    _buildModernMenuSection(
                      'Support',
                      Icons.help_outline_rounded,
                      [
                        _MenuItem(
                          icon: Icons.help_center_rounded,
                          title: 'Help Center',
                          subtitle: 'FAQs and support articles',
                          color: ProfileColors.help,
                          onTap: () {
                            HapticFeedback.lightImpact();
                          },
                        ),
                        _MenuItem(
                          icon: Icons.chat_bubble_rounded,
                          title: 'Contact Us',
                          subtitle: 'Get in touch with our team',
                          color: AppColors.primaryColor,
                          onTap: () {
                            HapticFeedback.lightImpact();
                          },
                        ),
                      ],
                      delay: 200,
                    ),

                    const SizedBox(height: 36),

                    // Modern Logout Button
                    _buildModernLogoutButton(),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Stats Section
  Widget _buildModernStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildModernStatCard(
            icon: Icons.pets_rounded,
            value: '3',
            label: 'My Pets',
            gradientColors: const [Color(0xFFFF6B9D), Color(0xFFFF8FB0)],
            delay: 0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildModernStatCard(
            icon: Icons.calendar_month_rounded,
            value: '5',
            label: 'Visits',
            gradientColors: const [Color(0xFF4ECFFF), Color(0xFF7DDBFF)],
            delay: 100,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildModernStatCard(
            icon: Icons.favorite_rounded,
            value: '12',
            label: 'Likes',
            gradientColors: const [Color(0xFFFF6584), Color(0xFFFF8AA3)],
            delay: 200,
          ),
        ),
      ],
    );
  }

  Widget _buildModernStatCard({
    required IconData icon,
    required String value,
    required String label,
    required List<Color> gradientColors,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: isInTest ? Duration.zero : Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutBack,
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: animationValue,
          child: Opacity(
            opacity: animationValue,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: gradientColors[0].withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                          spreadRadius: -3,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: ProfileColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ProfileColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Modern Menu Section
  Widget _buildModernMenuSection(
    String title,
    IconData sectionIcon,
    List<_MenuItem> items, {
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: isInTest ? Duration.zero : Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        sectionIcon,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: ProfileColors.textSecondary(context),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Menu Items Container
                Container(
                  decoration: BoxDecoration(
                    color: ProfileColors.surface(context),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isLast = index == items.length - 1;
                      return _buildModernMenuItem(item, isLast);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernMenuItem(_MenuItem item, bool isLast) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.vertical(
          top: isLast ? Radius.zero : const Radius.circular(24),
          bottom: isLast ? const Radius.circular(24) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            border: !isLast
                ? Border(
                    bottom: BorderSide(color: Colors.grey.shade100, width: 1),
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      item.color.withOpacity(0.2),
                      item.color.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ProfileColors.textPrimary(context),
                      ),
                    ),
                    if (item.subtitle != null) const SizedBox(height: 3),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: ProfileColors.textSecondary(context),
                        ),
                      ),
                  ],
                ),
              ),
              item.trailing ??
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: ProfileColors.surface(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: ProfileColors.textSecondary(context),
                      size: 14,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(bool isActive) {
    return Container(
      width: 48,
      height: 26,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryColor
            : ProfileColors.surface(context),
        borderRadius: BorderRadius.circular(13),
        border: isActive
            ? null
            : Border.all(
                color: ProfileColors.textSecondary(context).withOpacity(0.2),
              ),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: ProfileColors.surface(context),
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modern Logout Button
  Widget _buildModernLogoutButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: isInTest ? Duration.zero : const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ProfileColors.logout.withOpacity(0.1),
                    ProfileColors.logout.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ProfileColors.logout.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _showLogoutDialog();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ProfileColors.logout.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: ProfileColors.logout,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: ProfileColors.logout,
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
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: ProfileColors.logout.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: ProfileColors.logout,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Log Out?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: ProfileColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to log out of your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: ProfileColors.textSecondary(context),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ProfileColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await ref
                            .read(userSessionNotifierProvider.notifier)
                            .clearSession();
                        if (!context.mounted) return;
                        context.go(RoutePaths.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProfileColors.logout,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Menu Item Model
class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
    this.trailing,
  });
}
