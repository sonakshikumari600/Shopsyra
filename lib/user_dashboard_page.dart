import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notifications_page.dart';
import 'nearby_shops_page.dart';
import 'wishlist_page.dart';
import 'orders_page.dart';
import 'shop_detail_page.dart';
import 'offers_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'trending_page.dart';
import 'search_page.dart';
import 'booking_page.dart';
import 'product_detail_page.dart';
import 'Services/auth_service.dart';
import 'Services/firestore_service.dart';
class UserModel {
  final String name;
  final String avatarAsset;
  final String city;
  UserModel({required this.name, required this.avatarAsset, required this.city});
}

class TrendingItem {
  final String name;
  final String price;
  final String imageAsset;
  final String shopName;
  bool isWishlisted;
  TrendingItem({
    required this.name, 
    required this.price, 
    required this.imageAsset, 
    this.shopName = 'Local Shop',
    this.isWishlisted = false
  });
}

class NearbyShop {
  final String name;
  final double distanceKm;
  final int itemCount;
  final double rating;
  final String imageAsset;
  NearbyShop({required this.name, required this.distanceKm, required this.itemCount, required this.rating, required this.imageAsset});
  String get distanceLabel => '${distanceKm.toStringAsFixed(1)} km';
String get walkMins => '${(distanceKm / 0.08).round()} min';
}

class DashboardRepository {
  static Future<UserModel> fetchUser() async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) {
      return UserModel(
        name: 'Guest',
        avatarAsset: 'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?w=200',
        city: 'Mumbai',
      );
    }
    
    final userData = await UserFirestoreService().getUserProfile(uid);
    return UserModel(
      name: userData?['name'] ?? AuthService().currentUser?.displayName ?? 'User',
      avatarAsset: 'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?w=200',
      city: userData?['city'] ?? 'Mumbai',
    );
  }

  static Future<List<TrendingItem>> fetchTrending() async {
    try {
      debugPrint('🔍 Fetching products from Firestore...');
      
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();
      
      debugPrint('📦 Found ${snapshot.docs.length} products in database');
      
      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ No products found, showing dummy data');
        return [
          TrendingItem(name: 'Casual Jackets', price: '₹1,599', imageAsset: 'https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg?w=400', shopName: 'Sample Shop'),
          TrendingItem(name: 'T-Shirts',       price: '₹699',   imageAsset: 'https://images.pexels.com/photos/1656684/pexels-photo-1656684.jpeg?w=400', shopName: 'Sample Shop'),
          TrendingItem(name: 'Denim Jeans',    price: '₹1,250', imageAsset: 'https://images.pexels.com/photos/1082529/pexels-photo-1082529.jpeg?w=400', shopName: 'Sample Shop'),
          TrendingItem(name: 'Sneakers',       price: '₹1,999', imageAsset: 'https://images.pexels.com/photos/1032110/pexels-photo-1032110.jpeg?w=400', shopName: 'Sample Shop'),
        ];
      }
      
      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        final shopName = data['shopName'] ?? 'Local Shop';
        debugPrint('📝 Product: ${data['productName']} - ₹${data['price']} from $shopName');
        return TrendingItem(
          name: data['productName'] ?? 'Product',
          price: '₹${data['price']?.toString() ?? '0'}',
          imageAsset: data['imageUrl'] ?? 'https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg?w=400',
          shopName: shopName,
        );
      }).toList();
      
      debugPrint('✅ Successfully loaded ${products.length} products');
      return products;
    } catch (e) {
      debugPrint('❌ Error fetching products: $e');
      return [
        TrendingItem(name: 'Casual Jackets', price: '₹1,599', imageAsset: 'https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg?w=400', shopName: 'Sample Shop'),
        TrendingItem(name: 'T-Shirts',       price: '₹699',   imageAsset: 'https://images.pexels.com/photos/1656684/pexels-photo-1656684.jpeg?w=400', shopName: 'Sample Shop'),
        TrendingItem(name: 'Denim Jeans',    price: '₹1,250', imageAsset: 'https://images.pexels.com/photos/1082529/pexels-photo-1082529.jpeg?w=400', shopName: 'Sample Shop'),
        TrendingItem(name: 'Sneakers',       price: '₹1,999', imageAsset: 'https://images.pexels.com/photos/1032110/pexels-photo-1032110.jpeg?w=400', shopName: 'Sample Shop'),
      ];
    }
  }

  static Future<List<NearbyShop>> fetchNearbyShops() async {
    try {
      debugPrint('🔍 Fetching shops from Firestore...');
      
      final snapshot = await FirebaseFirestore.instance
          .collection('shopkeepers')
          .get();
      
      debugPrint('🏪 Found ${snapshot.docs.length} shops in database');
      
      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ No shops found, showing dummy data');
        return [
          NearbyShop(name: 'Vogue Boutique',   distanceKm: 0.5, itemCount: 120, rating: 5.0, imageAsset: 'https://images.pexels.com/photos/1488463/pexels-photo-1488463.jpeg?w=400'),
          NearbyShop(name: 'Fashion Hub',      distanceKm: 0.7, itemCount: 95,  rating: 4.5, imageAsset: 'https://images.pexels.com/photos/3965545/pexels-photo-3965545.jpeg?w=400'),
          NearbyShop(name: 'Urban Style',      distanceKm: 1.2, itemCount: 110, rating: 5.0, imageAsset: 'https://images.pexels.com/photos/1884581/pexels-photo-1884581.jpeg?w=400'),
          NearbyShop(name: 'Lifestyle Attire', distanceKm: 1.5, itemCount: 85,  rating: 4.0, imageAsset: 'https://images.pexels.com/photos/934070/pexels-photo-934070.jpeg?w=400'),
        ];
      }
      
      // Get product counts for each shop
      final productsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();
      
      // Count products per shopkeeper
      final Map<String, int> productCounts = {};
      for (var doc in productsSnapshot.docs) {
        final shopkeeperId = doc.data()['shopkeeperId'] as String?;
        if (shopkeeperId != null) {
          productCounts[shopkeeperId] = (productCounts[shopkeeperId] ?? 0) + 1;
        }
      }
      
      final shops = snapshot.docs.map((doc) {
        final data = doc.data();
        final shopkeeperId = doc.id;
        final itemCount = productCounts[shopkeeperId] ?? 0;
        
        // Generate random distance for now (you can add real location later)
        final distance = 0.5 + (shopkeeperId.hashCode % 20) / 10.0;
        
        final shopName = data['shopName'] ?? data['name'] ?? 'Shop';
        debugPrint('🏪 Shop: $shopName - $itemCount items');
        
        return NearbyShop(
          name: shopName,
          distanceKm: distance,
          itemCount: itemCount,
          rating: 4.5, // Default rating (you can add reviews later)
          imageAsset: 'https://images.pexels.com/photos/1488463/pexels-photo-1488463.jpeg?w=400',
        );
      }).toList();
      
      // Sort by distance
      shops.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      
      debugPrint('✅ Successfully loaded ${shops.length} shops');
      return shops;
    } catch (e) {
      debugPrint('❌ Error fetching shops: $e');
      return [
        NearbyShop(name: 'Vogue Boutique',   distanceKm: 0.5, itemCount: 120, rating: 5.0, imageAsset: 'https://images.pexels.com/photos/1488463/pexels-photo-1488463.jpeg?w=400'),
        NearbyShop(name: 'Fashion Hub',      distanceKm: 0.7, itemCount: 95,  rating: 4.5, imageAsset: 'https://images.pexels.com/photos/3965545/pexels-photo-3965545.jpeg?w=400'),
        NearbyShop(name: 'Urban Style',      distanceKm: 1.2, itemCount: 110, rating: 5.0, imageAsset: 'https://images.pexels.com/photos/1884581/pexels-photo-1884581.jpeg?w=400'),
        NearbyShop(name: 'Lifestyle Attire', distanceKm: 1.5, itemCount: 85,  rating: 4.0, imageAsset: 'https://images.pexels.com/photos/934070/pexels-photo-934070.jpeg?w=400'),
      ];
    }
  }
}

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});
  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> with TickerProviderStateMixin {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown     = const Color(0xFF2A1506);
  final Color bgColor       = const Color(0xFFF0E8DF);

  UserModel?         _user;
  List<TrendingItem> _trending = [];
  List<NearbyShop>   _shops    = [];
  bool _loading = true;
  int  _tab     = 0;
  final _searchCtrl = TextEditingController();

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  final List<String> _cities = [
    'Mumbai', 'Delhi', 'Bangalore', 'Hyderabad',
    'Chennai', 'Pune', 'Kolkata', 'Ahmedabad',
    'Jaipur', 'Lucknow', 'Surat', 'Noida',
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _loadAll();
  }

  Future<void> _loadAll() async {
    final r = await Future.wait([
      DashboardRepository.fetchUser(),
      DashboardRepository.fetchTrending(),
      DashboardRepository.fetchNearbyShops(),
    ]);
    if (!mounted) return;
    setState(() {
      _user     = r[0] as UserModel;
      _trending = r[1] as List<TrendingItem>;
      _shops    = r[2] as List<NearbyShop>;
      _loading  = false;
    });
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _navigate(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  // ── Trending item detail bottom sheet ──
  void _showTrendingDetail(TrendingItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 36, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: item.imageAsset,
                    height: 220, width: double.infinity, fit: BoxFit.cover,
                    placeholder: (c, u) => Container(height: 220, color: Colors.grey.shade100,
                        child: Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 48)),
                    errorWidget: (c, u, e) => Container(height: 220, color: Colors.grey.shade100,
                        child: Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 48)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text(item.name,
                          style: TextStyle(color: darkBrown, fontSize: 20, fontWeight: FontWeight.w800))),
                      GestureDetector(
                        onTap: () {
                          setState(() => item.isWishlisted = !item.isWishlisted);
                          setModalState(() {});
                        },
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
                          child: Icon(
                            item.isWishlisted ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                            color: item.isWishlisted ? Colors.red : Colors.grey.shade400, size: 20),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text(item.price,
                        style: TextStyle(color: primaryOrange, fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('Available at ${item.shopName}',
                        style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 13)),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _navigate(BookingPage(preSelectedItem: item.name));
                      },
                      child: Container(
                        width: double.infinity, height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryOrange, const Color(0xFFA8481A)],
                            begin: Alignment.centerLeft, end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: primaryOrange.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 5))],
                        ),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.bookmark_add_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text('Book Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 18),
            Row(children: [
              Icon(Icons.location_city_rounded, color: primaryOrange, size: 22),
              const SizedBox(width: 8),
              Text('Select Your City',
                  style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 6),
            Text('Shops will be shown based on your city',
                style: TextStyle(color: darkBrown.withOpacity(0.45), fontSize: 12.5)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10, runSpacing: 10,
              children: _cities.map((city) {
                final selected = _user!.city == city;
                return GestureDetector(
                  onTap: () {
                    setState(() => _user = UserModel(
                      name: _user!.name,
                      avatarAsset: _user!.avatarAsset,
                      city: city,
                    ));
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? primaryOrange : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
                      border: selected ? null : Border.all(color: darkBrown.withOpacity(0.08)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.location_on_rounded,
                          color: selected ? Colors.white : primaryOrange, size: 14),
                      const SizedBox(width: 5),
                      Text(city, style: TextStyle(
                          color: selected ? Colors.white : darkBrown,
                          fontSize: 13, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: _loading
          ? Center(child: CircularProgressIndicator(color: primaryOrange, strokeWidth: 2.5))
          : FadeTransition(
              opacity: _fadeAnim,
              child: Stack(
                children: [
                  Positioned(
                    right: -60, top: 100,
                    child: Container(
                      width: 260, height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [primaryOrange.withOpacity(0.18), Colors.transparent]),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -40, bottom: 200,
                    child: Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [primaryOrange.withOpacity(0.10), Colors.transparent]),
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: RefreshIndicator(
                      color: primaryOrange,
                      onRefresh: () async {
                        setState(() => _loading = true);
                        _fadeCtrl.reset();
                        await _loadAll();
                      },
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(child: _header()),
                          SliverToBoxAdapter(child: _searchBar()),
                          SliverToBoxAdapter(child: _quickActions()),
                          SliverToBoxAdapter(child: _sectionHeader('Trend On Local Shops',
                              onViewAll: () => _navigate(TrendingPage()))),
                          SliverToBoxAdapter(child: _trendingRow()),
                          SliverToBoxAdapter(child: _sectionHeader('Smart Search Nearby Shops',
                              onViewAll: () => _navigate(NearbyShopsPage()))),
                          SliverToBoxAdapter(child: _shopsList()),
                          const SliverToBoxAdapter(child: SizedBox(height: 90)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _navigate(const ProfilePage()),
            child: Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryOrange.withOpacity(0.4), width: 2.5),
                boxShadow: [BoxShadow(color: primaryOrange.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: _user!.avatarAsset,
                  fit: BoxFit.cover,
                  placeholder: (c, u) => Container(color: primaryOrange.withOpacity(0.1),
                      child: Icon(Icons.person_rounded, color: primaryOrange, size: 30)),
                  errorWidget: (c, u, e) => Container(color: primaryOrange.withOpacity(0.15),
                      child: Icon(Icons.person_rounded, color: primaryOrange, size: 30)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: () => _navigate(const ProfilePage()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(_user!.name,
                        style: TextStyle(color: darkBrown, fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: -0.3)),
                    const SizedBox(width: 4),
                    Icon(Icons.auto_awesome_rounded, color: primaryOrange, size: 16),
                  ]),
                  const SizedBox(height: 2),
                  Text('Welcome back!\nReady to explore nearby shops?',
                      style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 12.5, height: 1.45)),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _navigate(NotificationsPage()),
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Icon(Icons.notifications_outlined, color: darkBrown.withOpacity(0.7), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _navigate(const SearchPage()),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(color: darkBrown, fontSize: 14),
                    cursorColor: primaryOrange,
                    decoration: InputDecoration(
                      hintText: 'Search clothes or shops...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      border: InputBorder.none, isDense: true,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: _showCityPicker,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  Text(_user!.city, style: TextStyle(color: darkBrown, fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 3),
                  Icon(Icons.chevron_right_rounded, color: darkBrown.withOpacity(0.5), size: 16),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActions() {
    final actions = [
      {'emoji': '🛍️', 'label': 'Orders',   'page': OrdersPage()},
      {'emoji': '❤️',  'label': 'Wishlist', 'page': WishlistPage()},
      {'emoji': '🕐',  'label': 'Recent',   'page': NearbyShopsPage()},
      {'emoji': '🏷️', 'label': 'Offers',   'page': OffersPage()},
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((a) {
          return GestureDetector(
            onTap: () => _navigate(a['page'] as Widget),
            child: Container(
              width: 76,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Column(children: [
                Text(a['emoji']! as String, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Text(a['label']! as String,
                    style: TextStyle(color: darkBrown, fontSize: 11.5, fontWeight: FontWeight.w600)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionHeader(String title, {required VoidCallback onViewAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: darkBrown, fontSize: 16, fontWeight: FontWeight.w800)),
          GestureDetector(
            onTap: onViewAll,
            child: Row(children: [
              Text('View All', style: TextStyle(color: primaryOrange, fontSize: 13, fontWeight: FontWeight.w600)),
              Icon(Icons.chevron_right_rounded, color: primaryOrange, size: 16),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _trendingRow() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: _trending.length,
        itemBuilder: (ctx, i) {
          final item = _trending[i];
          return GestureDetector(
            onTap: () => _navigate(ProductDetailPage(
    name: item.name,
    price: item.price,
    imageUrl: item.imageAsset,
    shopName: item.shopName,
    category: 'Trending',
)),
            child: Container(
              width: 155,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      child: CachedNetworkImage(
                        imageUrl: item.imageAsset,
                        height: 130, width: double.infinity, fit: BoxFit.cover,
                        placeholder: (c, u) => Container(height: 130, color: Colors.grey.shade100,
                            child: Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 40)),
                        errorWidget: (c, u, e) => Container(height: 130, color: Colors.grey.shade100,
                            child: Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 40)),
                      ),
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => item.isWishlisted = !item.isWishlisted),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)]),
                          child: Icon(
                            item.isWishlisted ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                            color: item.isWishlisted ? Colors.red : Colors.grey.shade400, size: 17),
                        ),
                      ),
                    ),
                  ]),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.name, style: TextStyle(color: darkBrown, fontSize: 13, fontWeight: FontWeight.w700),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Row(children: [
                        Icon(Icons.store, size: 10, color: primaryOrange.withOpacity(0.7)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(item.shopName, 
                            style: TextStyle(color: darkBrown.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w500),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                      const SizedBox(height: 3),
                      Text(item.price, style: TextStyle(color: primaryOrange, fontSize: 13.5, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _shopsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(_shops.length, (i) {
          if (i >= 4) return const SizedBox.shrink();
          return _shopCard(_shops[i]);
        }),
      ),
    );
  }

  Widget _shopCard(NearbyShop shop) {
    return GestureDetector(
      onTap: () => _navigate(ShopDetailPage(shop: shop)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
              child: CachedNetworkImage(
                imageUrl: shop.imageAsset,
                width: 110, height: 110, fit: BoxFit.cover,
                placeholder: (c, u) => Container(width: 110, height: 110, color: Colors.grey.shade100,
                    child: Icon(Icons.store_outlined, color: Colors.grey.shade300, size: 36)),
                errorWidget: (c, u, e) => Container(width: 110, height: 110, color: Colors.grey.shade100,
                    child: Icon(Icons.store_outlined, color: Colors.grey.shade300, size: 36)),
              ),
            ),
            Positioned(
              bottom: 6, left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  Icon(Icons.location_on_rounded, color: Colors.white, size: 11),
                  const SizedBox(width: 2),
                  Text(shop.distanceLabel, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ]),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(shop.name, style: TextStyle(color: darkBrown, fontSize: 14.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text('${shop.distanceLabel} | ${shop.itemCount}+ items',
                    style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 12)),
                const SizedBox(height: 6),
                Row(children: [
                  ...List.generate(5, (i) => Icon(
                    i < shop.rating.floor() ? Icons.star_rounded :
                    (shop.rating - i >= 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded),
                    color: primaryOrange, size: 14)),
                  const SizedBox(width: 5),
                  Text(shop.rating.toString(),
                      style: TextStyle(color: darkBrown.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 4),
                Text('${shop.itemCount}+ items',
                    style: TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 11.5)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _bottomNav() {
    final items = [
      {'icon': Icons.home_rounded,          'label': 'Home'},
      {'icon': Icons.location_on_rounded,   'label': 'Nearby'},
      {'icon': Icons.favorite_rounded,      'label': 'Wishlist'},
      {'icon': Icons.shopping_cart_rounded, 'label': 'Cart'},
      {'icon': Icons.person_rounded,        'label': 'Profile'},
    ];
    final pages = [
      null,
      NearbyShopsPage(),
      WishlistPage(),
      CartPage(),
      ProfilePage(),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = _tab == i;
              return GestureDetector(
                onTap: () {
                  if (i == 0) { setState(() => _tab = 0); return; }
                  setState(() => _tab = i);
                  _navigate(pages[i]!);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? primaryOrange.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(items[i]['icon'] as IconData,
                        color: active ? primaryOrange : Colors.grey.shade400, size: 23),
                    const SizedBox(height: 3),
                    Text(items[i]['label'] as String,
                        style: TextStyle(
                            color: active ? primaryOrange : Colors.grey.shade400,
                            fontSize: 10.5,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
                  ]),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}