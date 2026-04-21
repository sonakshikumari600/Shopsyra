import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shop_detail_page.dart';
import 'user_dashboard_page.dart';

class NearbyShopsPage extends StatefulWidget {
  const NearbyShopsPage({super.key});
  @override
  State<NearbyShopsPage> createState() => _NearbyShopsPageState();
}

class _NearbyShopsPageState extends State<NearbyShopsPage> {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown     = const Color(0xFF2A1506);
  final Color bgColor       = const Color(0xFFF0E8DF);

  final _searchCtrl = TextEditingController();
  String _filter = 'All';
  final List<String> _filters = ['All', 'Nearest', 'Top Rated', 'Most Items'];

  List<NearbyShop> _shops = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      debugPrint('🔍 Fetching shops from Firestore...');
      
      final snapshot = await FirebaseFirestore.instance
          .collection('shopkeepers')
          .get();
      
      debugPrint('🏪 Found ${snapshot.docs.length} shops in database');
      
      if (snapshot.docs.isEmpty) {
        final data = await DashboardRepository.fetchNearbyShops();
        if (!mounted) return;
        setState(() { _shops = data; _loading = false; });
        return;
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
        
        // Generate random distance for now
        final distance = 0.5 + (shopkeeperId.hashCode % 20) / 10.0;
        
        final shopName = data['shopName'] ?? data['name'] ?? 'Shop';
        debugPrint('🏪 Shop: $shopName - $itemCount items');
        
        return NearbyShop(
          name: shopName,
          distanceKm: distance,
          itemCount: itemCount,
          rating: 4.5,
          imageAsset: 'https://images.pexels.com/photos/1488463/pexels-photo-1488463.jpeg?w=400',
        );
      }).toList();
      
      if (!mounted) return;
      setState(() { _shops = shops; _loading = false; });
    } catch (e) {
      debugPrint('❌ Error fetching shops: $e');
      final data = await DashboardRepository.fetchNearbyShops();
      if (!mounted) return;
      setState(() { _shops = data; _loading = false; });
    }
  }

  List<NearbyShop> get _filtered {
    List<NearbyShop> list = List.from(_shops);
    if (_filter == 'Nearest')    list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    if (_filter == 'Top Rated')  list.sort((a, b) => b.rating.compareTo(a.rating));
    if (_filter == 'Most Items') list.sort((a, b) => b.itemCount.compareTo(a.itemCount));
    return list;
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _navBar(context),
          _searchBar(),
          _filterChips(),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: primaryOrange, strokeWidth: 2.5))
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) => _shopCard(_filtered[i]),
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
            Text('Nearby Shops', style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w800)),
            const Spacer(),
            Icon(Icons.location_on_rounded, color: primaryOrange, size: 20),
            const SizedBox(width: 4),
            Text('Mumbai', style: TextStyle(color: primaryOrange, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: TextStyle(color: darkBrown, fontSize: 14),
                cursorColor: primaryOrange,
                decoration: InputDecoration(
                  hintText: 'Search shops...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: InputBorder.none, isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: _filters.length,
        itemBuilder: (ctx, i) {
          final active = _filter == _filters[i];
          return GestureDetector(
            onTap: () => setState(() => _filter = _filters[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: active ? primaryOrange : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
              ),
              child: Text(_filters[i],
                  style: TextStyle(color: active ? Colors.white : darkBrown.withOpacity(0.6),
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          );
        },
      ),
    );
  }

  Widget _shopCard(NearbyShop shop) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShopDetailPage(shop: shop))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, top: 6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4))]),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                  child: CachedNetworkImage(
                    imageUrl: shop.imageAsset,
                    width: 110, height: 110, fit: BoxFit.cover,
                    placeholder: (c, u) => Container(
                      width: 110, height: 110, color: Colors.grey.shade100,
                      child: Icon(Icons.store_outlined, color: Colors.grey.shade300, size: 36)),
                    errorWidget: (c, u, e) => Container(
                      width: 110, height: 110, color: Colors.grey.shade100,
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
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shop.name, style: TextStyle(color: darkBrown, fontSize: 14.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text('${shop.distanceLabel} | ${shop.itemCount}+ items',
                        style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(children: [
                      ...List.generate(5, (i) => Icon(
                        i < shop.rating.floor() ? Icons.star_rounded :
                        (shop.rating - i >= 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded),
                        color: primaryOrange, size: 14,
                      )),
                      const SizedBox(width: 5),
                      Text(shop.rating.toString(),
                          style: TextStyle(color: darkBrown.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(8)),
                      child: const Text('View Shop', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}