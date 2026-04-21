import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'user_dashboard_page.dart';
import 'booking_page.dart';
import 'product_detail_page.dart';
class ShopDetailPage extends StatefulWidget {
  final NearbyShop shop;
  const ShopDetailPage({super.key, required this.shop});
  @override
  State<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailItem {
  final String name;
  final String price;
  final String imageAsset;
  bool isWishlisted;
  _ShopDetailItem({required this.name, required this.price, required this.imageAsset, this.isWishlisted = false});
}

class _ShopDetailPageState extends State<ShopDetailPage> with SingleTickerProviderStateMixin {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown     = const Color(0xFF2A1506);
  final Color bgColor       = const Color(0xFFF0E8DF);

  late TabController _tabCtrl;

  final List<_ShopDetailItem> _items = [
    _ShopDetailItem(name: 'Casual Jacket',    price: '₹1,599', imageAsset: 'https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg?w=400'),
    _ShopDetailItem(name: 'Graphic T-Shirt',  price: '₹699',   imageAsset: 'https://images.pexels.com/photos/1656684/pexels-photo-1656684.jpeg?w=400'),
    _ShopDetailItem(name: 'Slim Denim Jeans', price: '₹1,250', imageAsset: 'https://images.pexels.com/photos/1082529/pexels-photo-1082529.jpeg?w=400'),
    _ShopDetailItem(name: 'White Sneakers',   price: '₹1,999', imageAsset: 'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg?w=400'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: primaryOrange,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 16),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.shop.imageAsset,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => Container(color: primaryOrange.withOpacity(0.3),
                        child: Icon(Icons.store_rounded, color: Colors.white, size: 60)),
                    errorWidget: (c, u, e) => Container(color: primaryOrange.withOpacity(0.3),
                        child: Icon(Icons.store_rounded, color: Colors.white, size: 60)),
                  ),
                  Container(decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.6)]))),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              color: bgColor,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(widget.shop.name,
                        style: TextStyle(color: darkBrown, fontSize: 22, fontWeight: FontWeight.w900))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        Container(width: 7, height: 7, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        const Text('Open', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    ...List.generate(5, (i) => Icon(
                      i < widget.shop.rating.floor() ? Icons.star_rounded :
                      (widget.shop.rating - i >= 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded),
                      color: primaryOrange, size: 16,
                    )),
                    const SizedBox(width: 6),
                    Text(widget.shop.rating.toString(),
                        style: TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    Text('(${widget.shop.itemCount}+ reviews)',
                        style: TextStyle(color: darkBrown.withOpacity(0.45), fontSize: 12)),
                  ]),
                  const SizedBox(height: 14),
                  Wrap(
  spacing: 8, runSpacing: 8,
  children: [
    _infoChip(Icons.location_on_rounded, widget.shop.distanceLabel),
    _infoChip(Icons.directions_walk_rounded, '${widget.shop.walkMins} walk'),
    _infoChip(Icons.inventory_2_outlined, '${widget.shop.itemCount}+ items'),
  ],
),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                    child: Row(children: [
                      Icon(Icons.access_time_rounded, color: primaryOrange, size: 18),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Working Hours', style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 11)),
                        const SizedBox(height: 2),
                        Text('Mon–Sat: 10:00 AM – 9:00 PM',
                            style: TextStyle(color: darkBrown, fontSize: 13, fontWeight: FontWeight.w600)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  // Call + Directions buttons
                  Row(children: [
                    Expanded(child: _actionBtn(Icons.call_rounded, 'Call Shop', primaryOrange, Colors.white)),
                    const SizedBox(width: 10),
                    Expanded(child: _actionBtn(Icons.directions_rounded, 'Directions', Colors.white, primaryOrange, outlined: true)),
                  ]),
                  const SizedBox(height: 10),
                  // Book a Visit button
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => BookingPage(preSelectedShop: widget.shop.name))),
                    child: Container(
                      width: double.infinity, height: 44,
                      decoration: BoxDecoration(
                        color: primaryOrange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryOrange, width: 1.5),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.bookmark_add_rounded, color: primaryOrange, size: 18),
                        const SizedBox(width: 8),
                        Text('Book a Visit',
                            style: TextStyle(color: primaryOrange, fontSize: 13, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                    child: TabBar(
                      controller: _tabCtrl,
                      labelColor: primaryOrange,
                      unselectedLabelColor: darkBrown.withOpacity(0.4),
                      indicatorColor: primaryOrange,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      tabs: const [Tab(text: 'Products'), Tab(text: 'Reviews')],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverFillRemaining(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.8),
                  itemCount: _items.length,
                  itemBuilder: (ctx, i) {
                    final item = _items[i];
                    return GestureDetector(
                     onTap: () => Navigator.push(context, MaterialPageRoute(
    builder: (_) => ProductDetailPage(
        name: item.name,
        price: item.price,
        imageUrl: item.imageAsset,
        shopName: widget.shop.name,
        category: 'Fashion',
    ))),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: CachedNetworkImage(
                                  imageUrl: item.imageAsset,
                                  height: 110, width: double.infinity, fit: BoxFit.cover,
                                  placeholder: (c, u) => Container(height: 110, color: Colors.grey.shade100,
                                      child: Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 36)),
                                  errorWidget: (c, u, e) => Container(height: 110, color: Colors.grey.shade100,
                                      child: Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 36)),
                                ),
                              ),
                              Positioned(top: 6, right: 6,
                                child: GestureDetector(
                                  onTap: () => setState(() => item.isWishlisted = !item.isWishlisted),
                                  child: Container(width: 28, height: 28,
                                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)]),
                                      child: Icon(
                                        item.isWishlisted ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                        color: item.isWishlisted ? Colors.red : Colors.grey.shade400, size: 15)),
                                ),
                              ),
                            ]),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(item.name, style: TextStyle(color: darkBrown, fontSize: 12.5, fontWeight: FontWeight.w700),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 3),
                                Text(item.price, style: TextStyle(color: primaryOrange, fontSize: 13, fontWeight: FontWeight.w800)),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _reviewCard('Priya S.', 5, 'Amazing collection! Found exactly what I was looking for. Staff is very helpful.', '2 days ago'),
                    _reviewCard('Rahul M.', 4, 'Good variety of clothes. Prices are reasonable. Will visit again!', '1 week ago'),
                    _reviewCard('Sneha K.', 5, 'Best boutique in the area. Quality is top-notch!', '2 weeks ago'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDetail(_ShopDetailItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0E8DF),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 36, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            // Product image
            ClipRRect(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(item.name,
                        style: TextStyle(color: darkBrown, fontSize: 20, fontWeight: FontWeight.w800))),
                    GestureDetector(
                      onTap: () => setState(() => item.isWishlisted = !item.isWishlisted),
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
                  Text('Available at ${widget.shop.name}',
                      style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 13)),
                  const SizedBox(height: 20),
                  // Book Now button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => BookingPage(
                              preSelectedShop: widget.shop.name,
                              preSelectedItem: '\${item.name} \${item.price}')));
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
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: primaryOrange, size: 14),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: darkBrown, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color bg, Color fg, {bool outlined = false}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: outlined ? Border.all(color: primaryOrange, width: 1.5) : null,
        boxShadow: outlined ? [] : [BoxShadow(color: primaryOrange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: fg, size: 18),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _reviewCard(String name, int rating, String review, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36,
              decoration: BoxDecoration(color: primaryOrange.withOpacity(0.15), shape: BoxShape.circle),
              child: Center(child: Text(name[0],
                  style: TextStyle(color: primaryOrange, fontSize: 16, fontWeight: FontWeight.w800)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(color: darkBrown, fontSize: 13, fontWeight: FontWeight.w700)),
            Row(children: List.generate(5, (i) => Icon(
                i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: primaryOrange, size: 13))),
          ])),
          Text(time, style: TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 11)),
        ]),
        const SizedBox(height: 8),
        Text(review, style: TextStyle(color: darkBrown.withOpacity(0.65), fontSize: 12.5, height: 1.4)),
      ]),
    );
  }
}