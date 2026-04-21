import 'package:flutter/material.dart';

class ForUsersPage extends StatelessWidget {
  const ForUsersPage({super.key});

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
                child: const Icon(Icons.person_outline_rounded,
                    color: Colors.white, size: 38),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text('For Users',
                  style: TextStyle(
                      color: darkBrown,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Discover fashion around you',
                style: TextStyle(
                    color: darkBrown.withOpacity(0.6), fontSize: 14),
              ),
            ),
            const SizedBox(height: 28),
            _featureCard(
              icon: Icons.location_on_outlined,
              title: 'Nearby Shops',
              body:
                  'Instantly discover clothing stores around you on an interactive map. No more guessing — see what\'s open near you right now.',
            ),
            const SizedBox(height: 14),
            _featureCard(
              icon: Icons.inventory_2_outlined,
              title: 'Live Stock',
              body:
                  'Check real-time availability of clothing items before stepping out. Know if your size is in stock before you visit.',
            ),
            const SizedBox(height: 14),
            _featureCard(
              icon: Icons.manage_search_outlined,
              title: 'Smart Search',
              body:
                  'Search by style, color, category, or price range. Our smart filters help you find exactly what you\'re looking for in seconds.',
            ),
            const SizedBox(height: 14),
            _featureCard(
              icon: Icons.favorite_outline_rounded,
              title: 'Save Favourites',
              body:
                  'Bookmark your favourite stores and items. Get notified when something you love is back in stock.',
            ),
            const SizedBox(height: 14),
            _featureCard(
              icon: Icons.directions_walk_outlined,
              title: 'Walk-in Ready',
              body:
                  'Plan your shopping trip with confidence. View store hours, directions, and contact info all in one place.',
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [darkBrown, const Color(0xFF5C3A1E)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.style_outlined,
                      color: Colors.white, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'Your nearby fashion,\njust a tap away.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: primaryOrange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Download Shopsyra and explore today.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(
      {required IconData icon,
      required String title,
      required String body}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
                const SizedBox(height: 5),
                Text(body,
                    style: TextStyle(
                        color: darkBrown.withOpacity(0.7),
                        fontSize: 13,
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}