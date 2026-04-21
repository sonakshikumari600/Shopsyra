import 'package:flutter/material.dart';
import 'login_page.dart';
import 'for_users_page.dart';
import 'for_shops_page.dart';
import 'about_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown     = const Color(0xFF2A1506);
  final Color heroBg        = const Color(0xFFEDE8E0);
  final Color darkSection   = const Color(0xFF1C0F04);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 750), vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _showDrawerMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: darkBrown,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            _drawerItem(Icons.person_outline_rounded, "For Users", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ForUsersPage()));
            }),
            _drawerItem(Icons.store_outlined, "For Shops", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ForShopsPage()));
            }),
            _drawerItem(Icons.info_outline_rounded, "About Us", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()));
            }),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: primaryOrange, size: 20),
            ),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 13),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: heroBg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildNavBar(),
            Expanded(flex: 55, child: SlideTransition(position: _slideAnimation, child: _buildHeroSection())),
            Expanded(flex: 45, child: _buildCtaSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        color: heroBg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.checkroom_rounded, color: darkBrown, size: 22),
            const SizedBox(width: 5),
            RichText(
              text: TextSpan(children: [
                TextSpan(text: "Shop",
                    style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                TextSpan(text: "syra",
                    style: TextStyle(color: primaryOrange, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
              ]),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showDrawerMenu(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: darkBrown.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.menu_rounded, color: darkBrown, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/landingpage.jpg"),
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(26, 16, 26, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(color: darkBrown, fontSize: 32, fontWeight: FontWeight.w900, height: 1.18, letterSpacing: -0.5),
              children: [
                const TextSpan(text: "Find Your "),
                TextSpan(text: "Style", style: TextStyle(color: primaryOrange)),
                const TextSpan(text: " —\nRight Around the "),
                TextSpan(text: "Corner", style: TextStyle(color: primaryOrange)),
                const TextSpan(text: "."),
              ],
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: TextStyle(color: darkBrown.withOpacity(0.75), fontSize: 14, height: 1.5),
              children: [
                const TextSpan(text: "Check "),
                TextSpan(text: "real-time", style: TextStyle(color: primaryOrange, fontWeight: FontWeight.w700)),
                const TextSpan(text: " clothing availability at "),
                TextSpan(text: "local shops", style: TextStyle(color: primaryOrange, fontWeight: FontWeight.w700)),
                const TextSpan(text: " before you visit."),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _featureChip(Icons.location_on_rounded, "Nearby\nShops"),
              const SizedBox(width: 18),
              _featureChip(Icons.inventory_2_rounded, "Live\nStock"),
              const SizedBox(width: 18),
              _featureChip(Icons.manage_search_rounded, "Smart\nSearch"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureChip(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: primaryOrange.withOpacity(0.13), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Icon(icon, color: primaryOrange, size: 22),
        ),
        const SizedBox(height: 6),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(color: darkBrown, fontSize: 10, fontWeight: FontWeight.w600, height: 1.3)),
      ],
    );
  }

  Widget _buildCtaSection() {
    return Container(
      width: double.infinity,
      color: darkSection,
      padding: const EdgeInsets.fromLTRB(26, 0, 26, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, height: 1.28, letterSpacing: -0.3),
              children: [
                const TextSpan(text: "Your "),
                TextSpan(text: "nearby", style: TextStyle(color: primaryOrange)),
                const TextSpan(text: " fashion,just a "),
                TextSpan(text: "tap away", style: TextStyle(color: primaryOrange)),
                const TextSpan(text: "."),
              ],
            ),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
            child: Container(
              width: double.infinity, height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryOrange, const Color(0xFFA8481A)],
                  begin: Alignment.centerLeft, end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: primaryOrange.withOpacity(0.45), blurRadius: 22, offset: const Offset(0, 7))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Get Started",
                      style: TextStyle(color: darkBrown, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.2)),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: darkBrown.withOpacity(0.15), shape: BoxShape.circle),
                    child: Icon(Icons.arrow_forward_rounded, color: darkBrown, size: 15),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text("Designed to make local shopping easier.",
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, letterSpacing: 0.1)),
        ],
      ),
    );
  }
}
