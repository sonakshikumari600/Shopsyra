import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});
  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistItem {
  final String name;
  final String price;
  final String shop;
  final String imageAsset;
  bool available;
  _WishlistItem({required this.name, required this.price, required this.shop, required this.imageAsset, this.available = true});
}

class _WishlistPageState extends State<WishlistPage> {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown     = const Color(0xFF2A1506);
  final Color bgColor       = const Color(0xFFF0E8DF);

  final List<_WishlistItem> _items = [
    _WishlistItem(name: 'Casual Jacket',   price: '₹1,599', shop: 'Vogue Boutique',    imageAsset: 'https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg?w=400'),
    _WishlistItem(name: 'Denim Jeans',     price: '₹1,250', shop: 'Lifestyle Attire',  imageAsset: 'https://images.pexels.com/photos/1082529/pexels-photo-1082529.jpeg?w=400'),
    _WishlistItem(name: 'White Sneakers',  price: '₹1,999', shop: 'Fashion Hub',       imageAsset: 'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg?w=400', available: false),
    _WishlistItem(name: 'Graphic T-Shirt', price: '₹699',   shop: 'Urban Style',       imageAsset: 'https://images.pexels.com/photos/1656684/pexels-photo-1656684.jpeg?w=400'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          SafeArea(
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
                  Text('My Wishlist', style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text('${_items.length} items', style: TextStyle(color: primaryOrange, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 80, height: 80,
                          decoration: BoxDecoration(color: primaryOrange.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(Icons.favorite_outline_rounded, color: primaryOrange, size: 38)),
                      const SizedBox(height: 16),
                      Text('Wishlist is Empty', style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text('Save items you love!', style: TextStyle(color: darkBrown.withOpacity(0.45), fontSize: 13.5)),
                    ]),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _items.length,
                    itemBuilder: (ctx, i) => _wishCard(_items[i], i),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _wishCard(_WishlistItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: item.imageAsset,
                  width: 100, height: 100, fit: BoxFit.cover,
                  placeholder: (c, u) => Container(width: 100, height: 100, color: Colors.grey.shade100,
                      child: Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 32)),
                  errorWidget: (c, u, e) => Container(width: 100, height: 100, color: Colors.grey.shade100,
                      child: Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 32)),
                ),
                if (!item.available)
                  Container(width: 100, height: 100, color: Colors.black.withOpacity(0.4),
                      child: Center(child: Text('Out of\nStock', textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)))),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(item.shop, style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(item.price, style: TextStyle(color: primaryOrange, fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: item.available ? primaryOrange : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(item.available ? 'Visit Shop' : 'Notify Me',
                                style: TextStyle(color: item.available ? darkBrown : Colors.grey.shade600,
                                    fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _items.removeAt(index)),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}