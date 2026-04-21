import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'orders_page.dart';
import 'wishlist_page.dart';
import 'offers_page.dart';
import 'notifications_page.dart';
import 'login_page.dart';
import 'help_support_page.dart';
import 'privacy_policy_page.dart';
import 'Services/auth_service.dart';
import 'Services/firestore_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown     = const Color(0xFF2A1506);
  final Color bgColor       = const Color(0xFFF0E8DF);

  String _name  = '';
  String _email = '';
  String _phone = '';
  String _city  = '';
  String _address = '';
  String _pincode = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }

    final userData = await UserFirestoreService().getUserProfile(uid);
    if (!mounted) return;
    
    setState(() {
      _name = userData?['name'] ?? AuthService().currentUser?.displayName ?? '';
      _email = userData?['email'] ?? AuthService().currentUser?.email ?? '';
      _phone = userData?['phone'] ?? '';
      _city = userData?['city'] ?? '';
      _address = userData?['address'] ?? '';
      _pincode = userData?['pincode'] ?? '';
      _loading = false;
    });
  }

  void _navigate(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  void _editField(String label, String current, Function(String) onSave) async {
    final ctrl = TextEditingController(text: current);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 36, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 18),
              Text('Edit $label',
                  style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                cursorColor: primaryOrange,
                style: TextStyle(color: darkBrown, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Enter $label',
                  filled: true, fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: darkBrown.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final newValue = ctrl.text.trim();
                  final uid = AuthService().currentUser?.uid;
                  if (uid != null) {
                    final fieldMap = {
                      'Full Name': 'name',
                      'Email': 'email',
                      'Phone': 'phone',
                      'City': 'city',
                      'Address': 'address',
                      'Pincode': 'pincode',
                    };
                    await UserFirestoreService().updateUserProfile(uid, {fieldMap[label]!: newValue});
                  }
                  onSave(newValue);
                  if (mounted) Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity, height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryOrange, const Color(0xFFA8481A)],
                      begin: Alignment.centerLeft, end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('Save Changes',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: primaryOrange)),
      );
    }
    
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
                  _profileHeader(),
                  const SizedBox(height: 14),
                  _infoSection(),
                  const SizedBox(height: 14),
                  _menuSection(),
                  const SizedBox(height: 24),
                  _logoutBtn(context),
                  const SizedBox(height: 40),
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
            Text('My Profile', style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w800)),
            const Spacer(),
            GestureDetector(
              onTap: () => _editField('Full Name', _name, (v) => setState(() => _name = v)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: primaryOrange.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Text('Edit', style: TextStyle(color: primaryOrange, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryOrange.withOpacity(0.4), width: 3),
                  boxShadow: [BoxShadow(color: primaryOrange.withOpacity(0.15), blurRadius: 16)],
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: 'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?w=200',
                    fit: BoxFit.cover,
                    placeholder: (c, u) => Container(
                      color: primaryOrange.withOpacity(0.15),
                      child: Icon(Icons.person_rounded, color: primaryOrange, size: 44),
                    ),
                    errorWidget: (c, u, e) => Container(
                      color: primaryOrange.withOpacity(0.15),
                      child: Icon(Icons.person_rounded, color: primaryOrange, size: 44),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('Photo upload coming soon!'),
                          backgroundColor: primaryOrange, duration: const Duration(seconds: 2)));
                  },
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: primaryOrange, shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2)),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _editField('Full Name', _name, (v) => setState(() => _name = v)),
            child: Text(_name, style: TextStyle(color: darkBrown, fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _editField('Email', _email, (v) => setState(() => _email = v)),
            child: Text(_email, style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 13)),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _editField('City', _city, (v) => setState(() => _city = v)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: primaryOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.location_on_rounded, color: primaryOrange, size: 14),
                const SizedBox(width: 4),
                Text(_city, style: TextStyle(color: primaryOrange, fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.edit_rounded, color: primaryOrange, size: 12),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Info', style: TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _infoRow(Icons.person_outline_rounded, 'Full Name', _name,
              onTap: () => _editField('Full Name', _name, (v) => setState(() => _name = v))),
          _divider(),
          _infoRow(Icons.mail_outline_rounded, 'Email', _email,
              onTap: () => _editField('Email', _email, (v) => setState(() => _email = v))),
          _divider(),
          _infoRow(Icons.phone_outlined, 'Phone', _phone,
              onTap: () => _editField('Phone', _phone, (v) => setState(() => _phone = v))),
          _divider(),
          _infoRow(Icons.location_city_rounded, 'City', _city,
              onTap: () => _editField('City', _city, (v) => setState(() => _city = v))),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: primaryOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: primaryOrange, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: darkBrown.withOpacity(0.45), fontSize: 11)),
                Text(value, style: TextStyle(color: darkBrown, fontSize: 13.5, fontWeight: FontWeight.w600)),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: darkBrown.withOpacity(0.3), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(color: darkBrown.withOpacity(0.06), height: 1);

  Widget _menuSection() {
    final items = [
      {'icon': Icons.shopping_bag_outlined,    'label': 'My Orders',      'page': OrdersPage()},
      {'icon': Icons.favorite_outline_rounded, 'label': 'Wishlist',       'page': WishlistPage()},
      {'icon': Icons.local_offer_outlined,     'label': 'Offers & Deals', 'page': OffersPage()},
      {'icon': Icons.notifications_outlined,   'label': 'Notifications',  'page': NotificationsPage()},
      {'icon': Icons.help_outline_rounded,     'label': 'Help & Support', 'page': HelpSupportPage()},
      {'icon': Icons.privacy_tip_outlined,     'label': 'Privacy Policy', 'page': PrivacyPolicyPage()},
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        children: List.generate(items.length, (i) => Column(
          children: [
            GestureDetector(
              onTap: () => _navigate(items[i]['page'] as Widget),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: primaryOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(items[i]['icon'] as IconData, color: primaryOrange, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(items[i]['label'] as String,
                        style: TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded, color: darkBrown.withOpacity(0.3), size: 18),
                  ],
                ),
              ),
            ),
            if (i < items.length - 1)
              Divider(color: darkBrown.withOpacity(0.06), height: 1, indent: 16, endIndent: 16),
          ],
        )),
      ),
    );
  }

  Widget _logoutBtn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Log Out', style: TextStyle(color: darkBrown, fontWeight: FontWeight.w800)),
              content: Text('Are you sure you want to log out?',
                  style: TextStyle(color: darkBrown.withOpacity(0.6))),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: darkBrown.withOpacity(0.5))),
                ),
                GestureDetector(
                  onTap: () async {
                    await AuthService().signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(10)),
                    child: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
        child: Container(
          width: double.infinity, height: 50,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 20),
              const SizedBox(width: 10),
              Text('Log Out',
                  style: TextStyle(color: Colors.red.shade400, fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}