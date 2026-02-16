import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/routes/route_paths.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/auth/presentation/view_model/session_notifier.dart';
import 'package:petcare/features/provider/presentation/screens/provider_business_profile_screen.dart';
import 'package:petcare/features/provider/presentation/screens/provider_documents_screen.dart';
import 'package:petcare/features/provider/presentation/screens/provider_help_screen.dart';
import 'package:petcare/features/provider/presentation/screens/provider_notifications_screen.dart';
import 'package:petcare/features/provider/presentation/screens/provider_payment_settings_screen.dart';
import 'package:petcare/features/provider/presentation/screens/provider_privacy_policy_screen.dart';

// Modern color palette for Provider Profile
class ProviderProfileColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color accent = Color(0xFFF59E0B);
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color editProfile = Color(0xFF4ECFFF);
  static const Color business = Color(0xFF10B981);
  static const Color settings = Color(0xFF9D6BFF);
  static const Color help = Color(0xFF00D4FF);
  static const Color logout = Color(0xFFFF4757);
}

class ProviderProfileScreen extends ConsumerStatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  ConsumerState<ProviderProfileScreen> createState() =>
      _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends ConsumerState<ProviderProfileScreen>
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
      duration: isInTest ? Duration.zero : Duration(milliseconds: 800),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: isInTest ? Duration.zero : Duration(milliseconds: 1000),
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerSlide = Tween<Offset>(begin: Offset(0, -0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _headerController,
            curve: Curves.easeOutCubic,
          ),
        );

    _avatarScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.elasticOut),
    );

    _headerController.forward();
    Future.delayed(
      Duration(milliseconds: 300),
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
    return Scaffold(
      backgroundColor: ProviderProfileColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            // Modern Header with Avatar
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ProviderProfileColors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.business_rounded,
                                          size: 14,
                                          color: ProviderProfileColors.primary,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Provider Profile',
                                          style: TextStyle(
                                            color:
                                                ProviderProfileColors.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Your Business Profile',
                                    style: TextStyle(
                                      color: ProviderProfileColors.textPrimary,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      height: 1.1,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Manage your business information',
                                    style: TextStyle(
                                      color:
                                          ProviderProfileColors.textSecondary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            ScaleTransition(
                              scale: _avatarScale,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      ProviderProfileColors.primary,
                                      ProviderProfileColors.primaryDark,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ProviderProfileColors.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.business_rounded,
                                  color: context.textPrimary,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Profile Options
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _headerFade,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Business Information',
                        style: TextStyle(
                          color: ProviderProfileColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildProfileOption(
                        'Edit Business Profile',
                        'Update your business details',
                        Icons.business_rounded,
                        ProviderProfileColors.editProfile,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ProviderBusinessProfileScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 12),
                      _buildProfileOption(
                        'Business Documents',
                        'Manage licenses & certificates',
                        Icons.description_rounded,
                        ProviderProfileColors.business,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProviderDocumentsScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 12),
                      _buildProfileOption(
                        'Payment Settings',
                        'Manage payment methods',
                        Icons.payment_rounded,
                        ProviderProfileColors.accent,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ProviderPaymentSettingsScreen(),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 32),
                      Text(
                        'Account Settings',
                        style: TextStyle(
                          color: ProviderProfileColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildProfileOption(
                        'Notifications',
                        'Manage notification preferences',
                        Icons.notifications_rounded,
                        ProviderProfileColors.settings,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ProviderNotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 12),
                      _buildProfileOption(
                        'Help & Support',
                        'Get help and contact support',
                        Icons.help_rounded,
                        ProviderProfileColors.help,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProviderHelpScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 12),
                      _buildProfileOption(
                        'Privacy Policy',
                        'Read our privacy policy',
                        Icons.privacy_tip_rounded,
                        ProviderProfileColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ProviderPrivacyPolicyScreen(),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 32),
                      _buildLogoutButton(),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: ProviderProfileColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF6366F1).withValues(alpha: 0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: ProviderProfileColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: ProviderProfileColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: ProviderProfileColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: () {
        _showLogoutDialog();
      },
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: ProviderProfileColors.logout.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ProviderProfileColors.logout.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: ProviderProfileColors.logout,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  color: ProviderProfileColors.logout,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: ProviderProfileColors.logout.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: ProviderProfileColors.logout,
                  size: 32,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Log Out?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: ProviderProfileColors.textPrimary,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Are you sure you want to log out of your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: ProviderProfileColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ProviderProfileColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await ref
                            .read(userSessionNotifierProvider.notifier)
                            .clearSession();
                        if (!mounted) return;
                        context.go(RoutePaths.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProviderProfileColors.logout,
                        foregroundColor: context.textPrimary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
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
