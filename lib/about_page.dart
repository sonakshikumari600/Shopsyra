import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  final Color primaryOrange = const Color(0xFFD2691E);
  final Color darkBrown = const Color(0xFF3B1F0A);
  final Color lightBg = const Color(0xFFF5F0EB);
  final Color cardBg = const Color(0xFFFAF7F4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: lightBg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: darkBrown.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back_ios_new, color: darkBrown, size: 18),
          ),
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: 'Shop',
                  style: TextStyle(
                      color: darkBrown,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              TextSpan(
                  text: 'syra',
                  style: TextStyle(
                      color: primaryOrange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon banner
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [primaryOrange, const Color(0xFFB8540A)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: primaryOrange.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: const Icon(Icons.info_outline_rounded,
                    color: Colors.white, size: 38),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text('About Us',
                  style: TextStyle(
                      color: darkBrown,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 28),
            _card(
              icon: Icons.track_changes_rounded,
              title: 'Our Mission',
              body:
                  'Shopsyra bridges the gap between local fashion stores and nearby shoppers. We believe great style shouldn\'t require long commutes or online waiting times.',
            ),
            const SizedBox(height: 16),
            _card(
              icon: Icons.visibility_outlined,
              title: 'Our Vision',
              body:
                  'A world where every local shop is discoverable, every outfit is just around the corner, and community commerce thrives through technology.',
            ),
            const SizedBox(height: 16),
            _card(
              icon: Icons.people_outline_rounded,
              title: 'Who We Are',
              body:
                  'We are a passionate team of developers and designers committed to empowering local businesses and making fashion discovery effortless for shoppers everywhere.',
            ),
            const SizedBox(height: 16),
            _card(
              icon: Icons.star_outline_rounded,
              title: 'Why Shopsyra?',
              body:
                  '• Real-time inventory from nearby stores\n• Smart search to find exactly what you need\n• Support for local shopkeepers\n• Designed to make local shopping easier',
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: darkBrown,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    '"Find Your Style —\nRight Around the Corner."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: primaryOrange,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        height: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Text('— The Shopsyra Team',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(
      {required IconData icon,
      required String title,
      required String body}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryOrange, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: darkBrown,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 6),
                Text(body,
                    style: TextStyle(
                        color: darkBrown.withOpacity(0.7),
                        fontSize: 13,
                        height: 1.55)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}