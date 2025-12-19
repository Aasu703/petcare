import 'package:flutter/material.dart';
import 'package:petcare/Screens/service_onboarding_screen.dart';

class VetOnboardingScreen extends StatelessWidget {
  const VetOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EC),
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
                  color: const Color(0xFFFFA84C),
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
                  color: const Color(0xFFFFA84C),
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
                  color: const Color(0xFFFFA84C),
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
                  color: const Color(0xFFFFA84C),
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
                          children: const [
                            Text(
                              'Care',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                                height: 1.1,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            Text(
                              'with',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                                height: 1.1,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            Text(
                              'Passion',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                                height: 1.1,
                                fontFamily: 'Nunito',
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
                              color: Colors.black.withOpacity(0.1),
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
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nunito',
                    ),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),

                          child: Column(
                            children: [
                              Text(
                                'Find your perfect pet companion',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              Row(
                                children: [
                                  Spacer(),
                                  SizedBox(
                                    height: 54,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ServiceOnboardingScreen(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFFFA84C,
                                        ),
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                        ),
                                      ),
                                      icon: const CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.black,
                                        child: Icon(
                                          Icons.pets,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      label: const Text(
                                        'Get Started',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Nunito',
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
                      Positioned(
                        left: 8,
                        top: -200,
                        bottom: 200,
                        child: Opacity(
                          opacity: 0.15,
                          child: Icon(
                            Icons.pets,
                            size: 180,
                            color: const Color(0xFFFFA84C),
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
                            color: const Color(0xFFFFA84C),
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
