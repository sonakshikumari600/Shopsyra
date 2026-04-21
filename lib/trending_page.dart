import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrendingItemModel {
  final String id;
  final String name;
  final String price;
  final String category;
  final String imageUrl;
  bool isWishlisted;
  TrendingItemModel({required this.id, required this.name, required this.price, required this.category,
      required this.imageUrl, this.isWishlisted = false});
}

class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});
  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown     = const Color(0xFF2A1506);
  final Color bgColor       = const Color(0xFFF0E8DF);

  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Jackets', 'T-Shirts', 'Jeans', 'Shoes', 'Dresses'];

  List<TrendingItemModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();
      
      if (snapshot.docs.isEmpty) {
        setState(() {
          _items = [
            TrendingItemModel(id: '1', name: 'Casual Jacket',      price: '₹1,599', category: 'Jackets',  imageUrl: 'https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg?w=400'),
            TrendingItemModel(id: '2', name: 'Denim Jacket',       price: '₹1,899', category: 'Jackets',  imageUrl: 'https://images.pexels.com/photos/1124468/pexels-photo-1124468.jpeg?w=400'),
            TrendingItemModel(id: '3', name: 'Graphic T-Shirt',    price: '₹699',   category: 'T-Shirts', imageUrl: 'https://images.pexels.com/photos/1656684/pexels-photo-1656684.jpeg?w=400'),
            TrendingItemModel(id: '4', name: 'Plain White Tee',    price: '₹499',   category: 'T-Shirts', imageUrl: 'https://images.pexels.com/photos/4066293/pexels-photo-4066293.jpeg?w=400'),
            TrendingItemModel(id: '5', name: 'Slim Denim Jeans',   price: '₹1,250', category: 'Jeans',    imageUrl: 'https://images.pexels.com/photos/1082529/pexels-photo-1082529.jpeg?w=400'),
            TrendingItemModel(id: '6', name: 'Black Skinny Jeans', price: '₹1,399', category: 'Jeans',    imageUrl: 'https://images.pexels.com/photos/1598507/pexels-photo-1598507.jpeg?w=400'),
            TrendingItemModel(id: '7', name: 'White Sneakers',     price: '₹1,999', category: 'Shoes', imageUrl: 'https://images.pexels.com/photos/1032110/pexels-photo-1032110.jpeg?w=400'),
            TrendingItemModel(id: '8', name: 'Running Shoes',      price: '₹2,499', category: 'Shoes',    imageUrl: 'https://images.pexels.com/photos/1464625/pexels-photo-1464625.jpeg?w=400'),
            TrendingItemModel(id: '9', name: 'Floral Dress',       price: '₹1,199', category: 'Dresses',  imageUrl: 'https://images.pexels.com/photos/1755428/pexels-photo-1755428.jpeg?w=400'),
            TrendingItemModel(id: '10', name: 'Summer Dress',       price: '₹999', category: 'Dresses', imageUrl: 'https://images.pexels.com/photos/972995/pexels-photo-972995.jpeg?w=400'),
          ];
          _loading = false;
        });
        return;
      }
      
      setState(() {
        _items = snapshot.docs.map((doc) {
          final data = doc.data();
          return TrendingItemModel(
            id: doc.id,
            name: data['productName'] ?? 'Product',
            price: '₹${data['price']?.toString() ?? '0'}',
            category: data['category'] ?? 'All',
            imageUrl: data['imageUrl'] ?? 'https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg?w=400',
          );
        }).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _items = [
          TrendingItemModel(id: '1', name: 'Casual Jacket',      price: '₹1,599', category: 'Jackets',  imageUrl: 'https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg?w=400'),
          TrendingItemModel(id: '2', name: 'Denim Jacket',       price: '₹1,899', category: 'Jackets',  imageUrl: 'https://images.pexels.com/photos/1124468/pexels-photo-1124468.jpeg?w=400'),
          TrendingItemModel(id: '3', name: 'Graphic T-Shirt',    price: '₹699',   category: 'T-Shirts', imageUrl: 'https://images.pexels.com/photos/1656684/pexels-photo-1656684.jpeg?w=400'),
          TrendingItemModel(id: '4', name: 'Plain White Tee',    price: '₹499',   category: 'T-Shirts', imageUrl: 'https://images.pexels.com/photos/4066293/pexels-photo-4066293.jpeg?w=400'),
          TrendingItemModel(id: '5', name: 'Slim Denim Jeans',   price: '₹1,250', category: 'Jeans',    imageUrl: 'https://images.pexels.com/photos/1082529/pexels-photo-1082529.jpeg?w=400'),
          TrendingItemModel(id: '6', name: 'Black Skinny Jeans', price: '₹1,399', category: 'Jeans',    imageUrl: 'https://images.pexels.com/photos/1598507/pexels-photo-1598507.jpeg?w=400'),
          TrendingItemModel(id: '7', name: 'White Sneakers',     price: '₹1,999', category: 'Shoes', imageUrl: 'https://images.pexels.com/photos/1032110/pexels-photo-1032110.jpeg?w=400'),
          TrendingItemModel(id: '8', name: 'Running Shoes',      price: '₹2,499', category: 'Shoes',    imageUrl: 'https://images.pexels.com/photos/1464625/pexels-photo-1464625.jpeg?w=400'),
          TrendingItemModel(id: '9', name: 'Floral Dress',       price: '₹1,199', category: 'Dresses',  imageUrl: 'https://images.pexels.com/photos/1755428/pexels-photo-1755428.jpeg?w=400'),
          TrendingItemModel(id: '10', name: 'Summer Dress',       price: '₹999', category: 'Dresses', imageUrl: 'https://images.pexels.com/photos/972995/pexels-photo-972995.jpeg?w=400'),
        ];
        _loading = false;
      });
    }
  }

  List<TrendingItemModel> get _filtered => _selectedCategory == 'All'
      ? _items
      : _items.where((i) => i.category == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: _loading
          ? Center(child: CircularProgressIndicator(color: primaryOrange, strokeWidth: 2.5))
          : Column(
        children: [
          _navBar(context),
          _categoryChips(),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) => _itemCard(_filtered[i]),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trending Now', style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w800)),
                Text('Latest fashion at local shops', style: TextStyle(color: darkBrown.withOpacity(0.45), fontSize: 12)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: primaryOrange.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Icon(Icons.local_fire_department_rounded, color: primaryOrange, size: 14),
                const SizedBox(width: 4),
                Text('${_items.length} Items', style: TextStyle(color: primaryOrange, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, bottom: 4),
        itemCount: _categories.length,
        itemBuilder: (ctx, i) {
          final active = _selectedCategory == _categories[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _categories[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: active ? primaryOrange : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
              ),
              child: Text(_categories[i],
                  style: TextStyle(color: active ? Colors.white : darkBrown.withOpacity(0.6),
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          );
        },
      ),
    );
  }

  Widget _itemCard(TrendingItemModel item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  height: 120, width: double.infinity, fit: BoxFit.cover,
                  placeholder: (c, u) => Container(height: 120, color: Colors.grey.shade100,
                      child: Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 40)),
                  errorWidget: (c, u, e) => Container(height: 120, color: Colors.grey.shade100,
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
                      color: item.isWishlisted ? Colors.red : Colors.grey.shade400, size: 17,
                    ),
                  ),
                ),
              ),
              
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: TextStyle(color: darkBrown, fontSize: 13, fontWeight: FontWeight.w700),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.price,
                        style: TextStyle(color: primaryOrange, fontSize: 13.5, fontWeight: FontWeight.w800)),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}