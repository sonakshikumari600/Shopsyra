import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartItem {
  final String name;
  final String shop;
  final String price;
  final int priceNum;
  final String imageAsset;
  int quantity;
  CartItem({required this.name, required this.shop, required this.price,
      required this.priceNum, required this.imageAsset, this.quantity = 1});
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown     = const Color(0xFF2A1506);
  final Color bgColor       = const Color(0xFFF0E8DF);

  final List<CartItem> _items = [
    CartItem(name: 'Casual Jacket',  shop: 'Vogue Boutique', price: '₹1,599', priceNum: 1599, imageAsset: 'https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg?w=400'),
    CartItem(name: 'Denim Jeans',    shop: 'Fashion Hub',    price: '₹1,250', priceNum: 1250, imageAsset: 'https://images.pexels.com/photos/1082529/pexels-photo-1082529.jpeg?w=400'),
    CartItem(name: 'White Sneakers', shop: 'Urban Style',    price: '₹1,999', priceNum: 1999, imageAsset: 'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg?w=400'),
  ];

  int get _subtotal => _items.fold(0, (sum, item) => sum + item.priceNum * item.quantity);
  int get _delivery => _subtotal > 2000 ? 0 : 49;
  int get _total => _subtotal + _delivery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _navBar(context),
          Expanded(child: _items.isEmpty ? _emptyCart() : _cartContent()),
          if (_items.isNotEmpty) _checkoutBar(),
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
              child: Container(width: 38, height: 38,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8)]),
                  child: Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 16)),
            ),
            const SizedBox(width: 14),
            Text('My Cart', style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w800)),
            const Spacer(),
            if (_items.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() => _items.clear()),
                child: Text('Clear All', style: TextStyle(color: Colors.red.shade400, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cartContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            itemCount: _items.length,
            itemBuilder: (ctx, i) => _cartCard(_items[i], i),
          ),
          const SizedBox(height: 14),
          _orderSummary(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _cartCard(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: item.imageAsset,
              width: 90, height: 90, fit: BoxFit.cover,
              placeholder: (c, u) => Container(width: 90, height: 90, color: Colors.grey.shade100,
                  child: Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 30)),
              errorWidget: (c, u, e) => Container(width: 90, height: 90, color: Colors.grey.shade100,
                  child: Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 30)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(item.name,
                        style: TextStyle(color: darkBrown, fontSize: 13.5, fontWeight: FontWeight.w800),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                    GestureDetector(
                      onTap: () => setState(() => _items.removeAt(index)),
                      child: Icon(Icons.close_rounded, color: Colors.grey.shade400, size: 18),
                    ),
                  ]),
                  const SizedBox(height: 2),
                  Text(item.shop, style: TextStyle(color: darkBrown.withOpacity(0.45), fontSize: 11.5)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Text(item.price, style: TextStyle(color: primaryOrange, fontSize: 14, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: darkBrown.withOpacity(0.1))),
                      child: Row(children: [
                        GestureDetector(
                          onTap: () {
                            if (item.quantity > 1) setState(() => item.quantity--);
                            else setState(() => _items.removeAt(index));
                          },
                          child: SizedBox(width: 28, height: 28,
                              child: Icon(Icons.remove_rounded, color: darkBrown, size: 16)),
                        ),
                        Text('${item.quantity}',
                            style: TextStyle(color: darkBrown, fontSize: 13, fontWeight: FontWeight.w700)),
                        GestureDetector(
                          onTap: () => setState(() => item.quantity++),
                          child: SizedBox(width: 28, height: 28,
                              child: Icon(Icons.add_rounded, color: primaryOrange, size: 16)),
                        ),
                      ]),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary', style: TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _summaryRow('Subtotal (${_items.length} items)', '₹$_subtotal'),
          const SizedBox(height: 8),
          _summaryRow('Delivery', _delivery == 0 ? 'FREE' : '₹$_delivery',
              valueColor: _delivery == 0 ? Colors.green : null),
          if (_delivery > 0) ...[
            const SizedBox(height: 6),
            Text('Add ₹${2000 - _subtotal} more for free delivery',
                style: TextStyle(color: primaryOrange, fontSize: 11.5, fontWeight: FontWeight.w500)),
          ],
          Divider(color: darkBrown.withOpacity(0.08), height: 20),
          _summaryRow('Total', '₹$_total', bold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false, Color? valueColor}) {
    return Row(children: [
      Text(label, style: TextStyle(color: darkBrown.withOpacity(bold ? 0.9 : 0.55),
          fontSize: bold ? 14 : 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
      const Spacer(),
      Text(value, style: TextStyle(
          color: valueColor ?? (bold ? darkBrown : darkBrown.withOpacity(0.7)),
          fontSize: bold ? 15 : 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
    ]);
  }

  Widget _checkoutBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4))]),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryOrange, const Color(0xFFA8481A)],
                begin: Alignment.centerLeft, end: Alignment.centerRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: primaryOrange.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Proceed to Checkout', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
          ]),
        ),
      ),
    );
  }

  Widget _emptyCart() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 90, height: 90,
            decoration: BoxDecoration(color: primaryOrange.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.shopping_cart_outlined, color: primaryOrange, size: 42)),
        const SizedBox(height: 20),
        Text('Cart is Empty', style: TextStyle(color: darkBrown, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Add items to your cart!', style: TextStyle(color: darkBrown.withOpacity(0.45), fontSize: 13.5)),
      ]),
    );
  }
}