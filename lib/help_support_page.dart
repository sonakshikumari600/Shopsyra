import 'package:flutter/material.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});
  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown     = const Color(0xFF2A1506);
  final Color bgColor       = const Color(0xFFF0E8DF);

  int? _openFaq;

  final List<Map<String, String>> _faqs = [
    {'q': 'How do I find nearby shops?', 'a': 'Use the search bar on the dashboard and tap the city selector to choose your location. Nearby shops will appear automatically based on your city.'},
    {'q': 'How do I add items to wishlist?', 'a': 'Tap the heart icon on any clothing item card to add it to your wishlist. You can view all wishlisted items from the Wishlist tab.'},
    {'q': 'How do I place an order?', 'a': 'Browse items, add them to cart, and tap "Proceed to Checkout". Visit the shop to collect your reserved items.'},
    {'q': 'How do I track my order?', 'a': 'Go to My Orders from the dashboard or profile. You can see the status of all your orders — Pending, Confirmed, Ready for Pickup, or Completed.'},
    {'q': 'How do I change my city?', 'a': 'Tap the city name (e.g. "Mumbai") in the search bar on the dashboard. A city picker will appear where you can select your city.'},
    {'q': 'How do I update my profile?', 'a': 'Go to Profile → tap Edit or tap any field in Personal Info to update your name, email, phone, or city.'},
    {'q': 'How do I get offers and deals?', 'a': 'Tap the Offers button on the dashboard to see all current deals from nearby shops. Filter by Today, This Week, or Clearance.'},
  ];

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
              child: Column(
                children: [
                  _contactSection(),
                  const SizedBox(height: 16),
                  _faqSection(),
                  const SizedBox(height: 30),
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
              Text('Help & Support', style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w800)),
              Text('We\'re here to help you', style: TextStyle(color: darkBrown.withOpacity(0.45), fontSize: 12)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _contactSection() {
    final contacts = [
      {'icon': Icons.email_outlined,    'label': 'Email Us',      'value': 'support@shopsyra.com',  'color': Colors.blue},
      {'icon': Icons.phone_outlined,    'label': 'Call Us',       'value': '+91 1800-123-4567',      'color': Colors.green},
      {'icon': Icons.chat_outlined,     'label': 'Live Chat',     'value': 'Chat with us 24/7',      'color': primaryOrange},
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Us', style: TextStyle(color: darkBrown, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          ...contacts.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {},
              child: Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: (c['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(c['icon'] as IconData, color: c['color'] as Color, size: 20),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c['label'] as String, style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 11)),
                  Text(c['value'] as String, style: TextStyle(color: darkBrown, fontSize: 13.5, fontWeight: FontWeight.w600)),
                ]),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: darkBrown.withOpacity(0.3), size: 18),
              ]),
            ),
          )),
        ],
      ),
    );
  }

  Widget _faqSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Frequently Asked Questions',
                style: TextStyle(color: darkBrown, fontSize: 15, fontWeight: FontWeight.w800)),
          ),
          ...List.generate(_faqs.length, (i) => Column(children: [
            GestureDetector(
              onTap: () => setState(() => _openFaq = _openFaq == i ? null : i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  Expanded(child: Text(_faqs[i]['q']!,
                      style: TextStyle(color: darkBrown, fontSize: 13.5,
                          fontWeight: _openFaq == i ? FontWeight.w700 : FontWeight.w600))),
                  Icon(_openFaq == i ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: primaryOrange, size: 22),
                ]),
              ),
            ),
            if (_openFaq == i)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_faqs[i]['a']!,
                      style: TextStyle(color: darkBrown.withOpacity(0.7), fontSize: 13, height: 1.5)),
                ),
              ),
            if (i < _faqs.length - 1)
              Divider(color: darkBrown.withOpacity(0.06), height: 1, indent: 16, endIndent: 16),
          ])),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}