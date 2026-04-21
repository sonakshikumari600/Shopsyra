import 'package:flutter/material.dart';

class ForShopsPage extends StatelessWidget {
  const ForShopsPage({super.key});

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
                child: const Icon(Icons.storefront_outlined,
                    color: Colors.white, size: 38),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text('For Shops',
                  style: TextStyle(
                      color: darkBrown,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Grow your local business with Shopsyra',
                style: TextStyle(
                    color: darkBrown.withOpacity(0.6), fontSize: 14),
              ),
            ),
            const SizedBox(height: 28),
            _featureCard(
              icon: Icons.storefront_outlined,
              title: 'Register Your Shop',
              body:
                  'Create your shop profile in minutes. Add your location, working hours, contact info, and start getting discovered by nearby customers.',
            ),
            const SizedBox(height: 14),
            _featureCard(
              icon: Icons.playlist_add_check_outlined,
              title: 'Manage Your Inventory',
              body:
                  'List your clothing items with photos, sizes, colors, and prices. Update stock in real-time so customers always have accurate information.',
            ),
            const SizedBox(height: 14),
            _featureCard(
              icon: Icons.people_alt_outlined,
              title: 'Attract Local Customers',
              body:
                  'Reach shoppers who are actively looking for fashion near them. Shopsyra connects you with high-intent local buyers.',
            ),
            const SizedBox(height: 14),
            _featureCard(
              icon: Icons.bar_chart_outlined,
              title: 'Analytics Dashboard',
              body:
                  'Track your shop\'s views, popular items, and customer engagement. Use insights to optimize your inventory and grow sales.',
            ),
            const SizedBox(height: 14),
            _featureCard(
              icon: Icons.notifications_outlined,
              title: 'Instant Notifications',
              body:
                  'Get notified when customers express interest in your items. Never miss an opportunity to make a sale.',
            ),
            const SizedBox(height: 32),
            // Stats row
            Row(
              children: [
                Expanded(
                    child: _statCard('Local\nShoppers', Icons.person_outline)),
                const SizedBox(width: 12),
                Expanded(
                    child: _statCard('Live\nStock', Icons.inventory_outlined)),
                const SizedBox(width: 12),
                Expanded(
                    child:
                        _statCard('Smart\nReach', Icons.near_me_outlined)),
              ],
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
                  const Icon(Icons.store_outlined,
                      color: Colors.white, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'List your shop today.\nReach customers around the corner.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: primaryOrange,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Free to get started. No hidden fees.',
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

  Widget _statCard(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryOrange.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryOrange, size: 24),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: darkBrown,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
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