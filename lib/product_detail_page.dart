import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'booking_page.dart';

class ProductDetailPage extends StatefulWidget {
  final String name;
  final String price;
  final String imageUrl;
  final String shopName;
  final String category;

  const ProductDetailPage({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.shopName,
    required this.category,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown     = const Color(0xFF2A1506);
  final Color bgColor       = const Color(0xFFF0E8DF);

  bool _isWishlisted = false;
  String _selectedSize = 'M';
  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Image ──
                  Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        height: 380,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (c, u) => Container(height: 380, color: Colors.grey.shade100,
                            child: Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 60)),
                        errorWidget: (c, u, e) => Container(height: 380, color: Colors.grey.shade100,
                            child: Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 60)),
                      ),
                      // Back button
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                                  ),
                                  child: Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 16),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _isWishlisted = !_isWishlisted),
                                child: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                                  ),
                                  child: Icon(
                                    _isWishlisted ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                    color: _isWishlisted ? Colors.red : darkBrown, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Category badge
                      Positioned(
                        bottom: 16, left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryOrange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(widget.category,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),

                  // ── Product Info ──
                  Container(
                    color: bgColor,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(widget.name,
                                  style: TextStyle(color: darkBrown, fontSize: 24, fontWeight: FontWeight.w900, height: 1.2)),
                            ),
                            const SizedBox(width: 12),
                            Text(widget.price,
                                style: TextStyle(color: primaryOrange, fontSize: 22, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Shop name
                        GestureDetector(
                          child: Row(children: [
                            Icon(Icons.store_rounded, color: primaryOrange, size: 16),
                            const SizedBox(width: 6),
                            Text('Available at ${widget.shopName}',
                                style: TextStyle(color: primaryOrange, fontSize: 13.5, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right_rounded, color: primaryOrange, size: 16),
                          ]),
                        ),
                        const SizedBox(height: 20),

                        // Size selector
                        Text('Select Size',
                            style: TextStyle(color: darkBrown, fontSize: 15, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10, runSpacing: 10,
                          children: _sizes.map((size) => GestureDetector(
                            onTap: () => setState(() => _selectedSize = size),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: _selectedSize == size ? primaryOrange : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedSize == size ? primaryOrange : darkBrown.withOpacity(0.15),
                                  width: 1.5,
                                ),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                              ),
                              child: Center(
                                child: Text(size,
                                    style: TextStyle(
                                      color: _selectedSize == size ? Colors.white : darkBrown,
                                      fontSize: 13, fontWeight: FontWeight.w700,
                                    )),
                              ),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Product description
                        Text('About this Item',
                            style: TextStyle(color: darkBrown, fontSize: 15, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text(
                          'A premium quality ${widget.name.toLowerCase()} available at ${widget.shopName}. '
                          'Visit the shop to try it on before purchasing. '
                          'Book your visit to ensure the item is reserved for you.',
                          style: TextStyle(color: darkBrown.withOpacity(0.6), fontSize: 13.5, height: 1.6),
                        ),
                        const SizedBox(height: 20),

                        // Features
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                          ),
                          child: Column(children: [
                            _featureRow(Icons.verified_rounded, 'Quality Assured', 'Premium quality product'),
                            const SizedBox(height: 12),
                            _featureRow(Icons.location_on_rounded, 'Local Shop', '${widget.shopName} • Nearby'),
                            const SizedBox(height: 12),
                            _featureRow(Icons.bookmark_add_rounded, 'Book & Visit', 'Reserve before you visit'),
                          ]),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4))],
            ),
            child: Row(children: [
              // Add to Wishlist
              GestureDetector(
                onTap: () => setState(() => _isWishlisted = !_isWishlisted),
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: _isWishlisted ? Colors.red.withOpacity(0.1) : bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isWishlisted ? Colors.red.shade300 : darkBrown.withOpacity(0.15),
                    ),
                  ),
                  child: Icon(
                    _isWishlisted ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    color: _isWishlisted ? Colors.red : darkBrown.withOpacity(0.5), size: 22),
                ),
              ),
              const SizedBox(width: 12),
              // Book Now
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => BookingPage(
                          preSelectedShop: widget.shopName,
                          preSelectedItem: '${widget.name} ${widget.price}'))),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryOrange, const Color(0xFFA8481A)],
                        begin: Alignment.centerLeft, end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: primaryOrange.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 5))],
                    ),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.bookmark_add_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text('Book Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _featureRow(IconData icon, String title, String subtitle) {
    return Row(children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: primaryOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: primaryOrange, size: 18),
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: darkBrown, fontSize: 13, fontWeight: FontWeight.w700)),
        Text(subtitle, style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 12)),
      ]),
    ]);
  }
}