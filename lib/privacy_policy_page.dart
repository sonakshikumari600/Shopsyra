import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const Color primaryOrange = Color(0xFFCC6B2C);
  static const Color darkBrown     = Color(0xFF2A1506);
  static const Color bgColor       = Color(0xFFF0E8DF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _navBar(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
              child: Column(
                children: [
                  _header(),
                  const SizedBox(height: 16),
                  _section('1. Information We Collect',
                      'We collect information you provide directly to us, such as your name, email address, phone number, and location when you register for an account or use our services.\n\nWe also collect information automatically when you use Shopsyra, including your device information, IP address, and usage data.'),
                  _section('2. How We Use Your Information',
                      'We use the information we collect to:\n• Provide, maintain, and improve our services\n• Show you nearby shops and clothing availability\n• Send you notifications about orders and offers\n• Personalize your shopping experience\n• Communicate with you about products and services'),
                  _section('3. Information Sharing',
                      'We do not sell, trade, or rent your personal information to third parties. We may share your information with:\n• Shops you interact with on our platform\n• Service providers who assist our operations\n• Law enforcement when required by law'),
                  _section('4. Location Data',
                      'Shopsyra uses your location to show nearby shops and provide accurate distance information. You can disable location access in your device settings, but this may limit some features of the app.'),
                  _section('5. Data Security',
                      'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.'),
                  _section('6. Your Rights',
                      'You have the right to:\n• Access your personal information\n• Correct inaccurate data\n• Request deletion of your data\n• Opt out of marketing communications\n• Data portability'),
                  _section('7. Cookies',
                      'We use cookies and similar tracking technologies to track activity on our service and hold certain information. You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent.'),
                  _section('8. Changes to This Policy',
                      'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.'),
                  _section('9. Contact Us',
                      'If you have any questions about this Privacy Policy, please contact us at:\n\nEmail: privacy@shopsyra.com\nPhone: +91 1800-123-4567\nAddress: Shopsyra Technologies, Mumbai, India'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: primaryOrange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryOrange.withOpacity(0.2)),
                    ),
                    child: Row(children: [
                      Icon(Icons.info_outline_rounded, color: primaryOrange, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Last Updated: March 2025',
                          style: TextStyle(color: darkBrown.withOpacity(0.6), fontSize: 12.5, fontWeight: FontWeight.w500))),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8)]),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 16),
              ),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Privacy Policy', style: const TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w800)),
              Text('Your data, your rights', style: TextStyle(color: darkBrown.withOpacity(0.45), fontSize: 12)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryOrange, const Color(0xFFA8481A)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: primaryOrange.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.privacy_tip_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 14),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Privacy Policy', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
          SizedBox(height: 3),
          Text('We value and protect your privacy', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
        ])),
      ]),
    );
  }

  Widget _section(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(content, style: TextStyle(color: darkBrown.withOpacity(0.65), fontSize: 13, height: 1.6)),
      ]),
    );
  }
}