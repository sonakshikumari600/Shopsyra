import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'shop_detail_page.dart';
import 'user_dashboard_page.dart';
import 'visual_search_camera_page.dart';

class SearchClothingItem {
  final String name;
  final String price;
  final String category;
  final String imageUrl;
  final String shopName;
  SearchClothingItem({required this.name, required this.price, required this.category,
      required this.imageUrl, required this.shopName});
}

class SearchRepository {
  static final List<SearchClothingItem> allClothes = [
    SearchClothingItem(name: 'Casual Jacket',     price: '₹1,599', category: 'Jackets',  shopName: 'Vogue Boutique',   imageUrl: 'https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg?w=400'),
    SearchClothingItem(name: 'Denim Jacket',      price: '₹1,899', category: 'Jackets',  shopName: 'Fashion Hub',      imageUrl: 'https://images.pexels.com/photos/1124468/pexels-photo-1124468.jpeg?w=400'),
    SearchClothingItem(name: 'Graphic T-Shirt',   price: '₹699',   category: 'T-Shirts', shopName: 'Urban Style',      imageUrl: 'https://images.pexels.com/photos/1656684/pexels-photo-1656684.jpeg?w=400'),
    SearchClothingItem(name: 'Plain White Tee',   price: '₹499',   category: 'T-Shirts', shopName: 'Lifestyle Attire', imageUrl: 'https://images.pexels.com/photos/4066293/pexels-photo-4066293.jpeg?w=400'),
    SearchClothingItem(name: 'Slim Denim Jeans',  price: '₹1,250', category: 'Jeans',    shopName: 'Fashion Hub',      imageUrl: 'https://images.pexels.com/photos/1082529/pexels-photo-1082529.jpeg?w=400'),
    SearchClothingItem(name: 'Black Skinny Jeans',price: '₹1,399', category: 'Jeans',    shopName: 'Vogue Boutique',   imageUrl: 'https://images.pexels.com/photos/1598507/pexels-photo-1598507.jpeg?w=400'),
    SearchClothingItem(name: 'White Sneakers',    price: '₹1,999', category: 'Shoes',    shopName: 'Urban Style',      imageUrl: 'https://images.pexels.com/photos/1032110/pexels-photo-1032110.jpeg?w=400'),
    SearchClothingItem(name: 'Running Shoes',     price: '₹2,499', category: 'Shoes',    shopName: 'Lifestyle Attire', imageUrl: 'https://images.pexels.com/photos/1464625/pexels-photo-1464625.jpeg?w=400'),
    SearchClothingItem(name: 'Floral Dress',      price: '₹1,199', category: 'Dresses',  shopName: 'Vogue Boutique',   imageUrl: 'https://images.pexels.com/photos/1755428/pexels-photo-1755428.jpeg?w=400'),
    SearchClothingItem(name: 'Summer Dress',      price: '₹999',   category: 'Dresses',  shopName: 'Fashion Hub',      imageUrl: 'https://images.pexels.com/photos/972995/pexels-photo-972995.jpeg?w=400'),
  ];

  static final List<NearbyShop> allShops = [
    NearbyShop(name: 'Vogue Boutique',   distanceKm: 0.5, itemCount: 120, rating: 5.0, imageAsset: 'https://images.pexels.com/photos/1488463/pexels-photo-1488463.jpeg?w=400'),
    NearbyShop(name: 'Fashion Hub',      distanceKm: 0.7, itemCount: 95,  rating: 4.5, imageAsset: 'https://images.pexels.com/photos/3965545/pexels-photo-3965545.jpeg?w=400'),
    NearbyShop(name: 'Urban Style',      distanceKm: 1.2, itemCount: 110, rating: 5.0, imageAsset: 'https://images.pexels.com/photos/1884581/pexels-photo-1884581.jpeg?w=400'),
    NearbyShop(name: 'Lifestyle Attire', distanceKm: 1.5, itemCount: 85,  rating: 4.0, imageAsset: 'https://images.pexels.com/photos/934070/pexels-photo-934070.jpeg?w=400'),
  ];
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown     = const Color(0xFF2A1506);
  final Color bgColor       = const Color(0xFFF0E8DF);

  final _searchCtrl = TextEditingController();
  String _query = '';
  late TabController _tabCtrl;

  List<SearchClothingItem> get _filteredClothes => _query.isEmpty ? [] :
      SearchRepository.allClothes.where((c) =>
          c.name.toLowerCase().contains(_query.toLowerCase()) ||
          c.category.toLowerCase().contains(_query.toLowerCase()) ||
          c.shopName.toLowerCase().contains(_query.toLowerCase())).toList();

  List<NearbyShop> get _filteredShops => _query.isEmpty ? [] :
      SearchRepository.allShops.where((s) =>
          s.name.toLowerCase().contains(_query.toLowerCase())).toList();

  final List<String> _recentSearches = ['Jackets', 'Denim Jeans', 'Vogue Boutique', 'Sneakers'];
  final List<String> _trending = ['T-Shirts', 'Dresses', 'Fashion Hub', 'Casual Jacket', 'Shoes'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _navBar(context),
          _query.isEmpty ? _emptyState() : _searchResults(),
        ],
      ),
    );
  }

  Widget _navBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: bgColor,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
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
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10)]),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        cursorColor: primaryOrange,
                        style: TextStyle(color: darkBrown, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search clothes or shops...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          border: InputBorder.none, isDense: true,
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GestureDetector(
                        onTap: () => _searchCtrl.clear(),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(Icons.close_rounded, color: Colors.grey.shade400, size: 18),
                        ),
                      ),
                    // Gallery Icon
                    GestureDetector(
                      onTap: () async {
                        final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (image != null && mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VisualSearchCameraPage(preSelectedImage: image),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.photo_library_outlined,
                          color: primaryOrange,
                          size: 20,
                        ),
                      ),
                    ),
                    // Camera Icon
                    GestureDetector(
                      onTap: () async {
                        if (kIsWeb) {
                          // On web, navigate to camera page which will handle it better
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VisualSearchCameraPage(),
                            ),
                          );
                        } else {
                          // On mobile, directly open camera
                          final image = await ImagePicker().pickImage(
                            source: ImageSource.camera,
                            preferredCameraDevice: CameraDevice.rear,
                          );
                          if (image != null && mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VisualSearchCameraPage(preSelectedImage: image),
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: primaryOrange,
                          size: 22,
                        ),
                      ),
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

  Widget _emptyState() {
    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_recentSearches.isNotEmpty) ...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Recent Searches', style: TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w800)),
                GestureDetector(
                  onTap: () => setState(() => _recentSearches.clear()),
                  child: Text('Clear', style: TextStyle(color: primaryOrange, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _recentSearches.map((s) => GestureDetector(
                  onTap: () => _searchCtrl.text = s,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.history_rounded, color: darkBrown.withOpacity(0.4), size: 14),
                      const SizedBox(width: 6),
                      Text(s, style: TextStyle(color: darkBrown, fontSize: 13, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 22),
            ],
            Text('Trending', style: TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _trending.map((s) => GestureDetector(
                onTap: () => _searchCtrl.text = s,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryOrange.withOpacity(0.2)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.local_fire_department_rounded, color: primaryOrange, size: 14),
                    const SizedBox(width: 6),
                    Text(s, style: TextStyle(color: primaryOrange, fontSize: 13, fontWeight: FontWeight.w600)),
                  ]),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchResults() {
    return Expanded(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
            child: TabBar(
              controller: _tabCtrl,
              labelColor: primaryOrange,
              unselectedLabelColor: darkBrown.withOpacity(0.4),
              indicatorColor: primaryOrange,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: 'Clothes (${_filteredClothes.length})'),
                Tab(text: 'Shops (${_filteredShops.length})'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [_clothesList(), _shopsList()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _clothesList() {
    if (_filteredClothes.isEmpty) return _noResults('No clothes found for "$_query"');
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: 215),
      itemCount: _filteredClothes.length,
      itemBuilder: (ctx, i) {
        final item = _filteredClothes[i];
        return Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  height: 120, width: double.infinity, fit: BoxFit.cover,
                  placeholder: (c, u) => Container(height: 120, color: Colors.grey.shade100,
                      child: Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 36)),
                  errorWidget: (c, u, e) => Container(height: 120, color: Colors.grey.shade100,
                      child: Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 36)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.name, style: TextStyle(color: darkBrown, fontSize: 12.5, fontWeight: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(item.shopName, style: TextStyle(color: darkBrown.withOpacity(0.45), fontSize: 11)),
                  const SizedBox(height: 3),
                  Text(item.price, style: TextStyle(color: primaryOrange, fontSize: 13, fontWeight: FontWeight.w800)),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shopsList() {
    if (_filteredShops.isEmpty) return _noResults('No shops found for "$_query"');
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: _filteredShops.length,
      itemBuilder: (ctx, i) {
        final shop = _filteredShops[i];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShopDetailPage(shop: shop))),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: shop.imageAsset,
                    width: 90, height: 90, fit: BoxFit.cover,
                    placeholder: (c, u) => Container(width: 90, height: 90, color: Colors.grey.shade100,
                        child: Icon(Icons.store_outlined, color: Colors.grey.shade300, size: 30)),
                    errorWidget: (c, u, e) => Container(width: 90, height: 90, color: Colors.grey.shade100,
                        child: Icon(Icons.store_outlined, color: Colors.grey.shade300, size: 30)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(shop.name, style: TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text('${shop.distanceLabel} | ${shop.itemCount}+ items',
                          style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 12)),
                      const SizedBox(height: 5),
                      Row(children: [
                        ...List.generate(5, (j) => Icon(
                          j < shop.rating.floor() ? Icons.star_rounded :
                          (shop.rating - j >= 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded),
                          color: primaryOrange, size: 13)),
                        const SizedBox(width: 4),
                        Text(shop.rating.toString(),
                            style: TextStyle(color: darkBrown.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w600)),
                      ]),
                    ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.chevron_right_rounded, color: darkBrown.withOpacity(0.3), size: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _noResults(String msg) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 80, height: 80,
            decoration: BoxDecoration(color: primaryOrange.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.search_off_rounded, color: primaryOrange, size: 38)),
        const SizedBox(height: 16),
        Text('No Results', style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(msg, style: TextStyle(color: darkBrown.withOpacity(0.45), fontSize: 13), textAlign: TextAlign.center),
      ]),
    );
  }
}