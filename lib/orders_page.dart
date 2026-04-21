import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'Services/auth_service.dart';
import 'Services/firestore_service.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

enum OrderStatus { pending, confirmed, ready, completed, cancelled }

class OrderModel {
  final String id;
  final String shopName;
  final String item;
  final String price;
  final String imageAsset;
  final OrderStatus status;
  final String date;
  OrderModel({required this.id, required this.shopName, required this.item,
      required this.price, required this.imageAsset, required this.status, required this.date});
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown     = const Color(0xFF2A1506);
  final Color bgColor       = const Color(0xFFF0E8DF);

  late TabController _tabCtrl;
  List<OrderModel> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }

    UserFirestoreService().streamUserOrders().listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _orders = snapshot.docs.map((doc) {
          final data = doc.data();
          OrderStatus status = OrderStatus.pending;
          switch (data['status']) {
            case 'confirmed': status = OrderStatus.confirmed; break;
            case 'ready': status = OrderStatus.ready; break;
            case 'completed': status = OrderStatus.completed; break;
            case 'cancelled': status = OrderStatus.cancelled; break;
          }
          return OrderModel(
            id: '#${doc.id.substring(0, 4)}',
            shopName: data['productName'] ?? 'Shop',
            item: data['productName'] ?? 'Item',
            price: '₹${data['totalAmount'] ?? 0}',
            imageAsset: 'https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg?w=200',
            status: status,
            date: 'Recent',
          );
        }).toList();
        _loading = false;
      });
    });
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  List<OrderModel> _byStatus(List<OrderStatus> statuses) =>
      _orders.where((o) => statuses.contains(o.status)).toList();

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
          SafeArea(
            bottom: false,
            child: Container(
              color: bgColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(width: 38, height: 38,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8)]),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 16)),
                ),
                const SizedBox(width: 14),
                Text('My Orders', style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w800)),
              ]),
            ),
          ),
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
              tabs: const [Tab(text: 'Active'), Tab(text: 'Completed'), Tab(text: 'Cancelled')],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _orderList(_byStatus([OrderStatus.pending, OrderStatus.confirmed, OrderStatus.ready])),
                _orderList(_byStatus([OrderStatus.completed])),
                _orderList(_byStatus([OrderStatus.cancelled])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 80, height: 80,
            decoration: BoxDecoration(color: primaryOrange.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.shopping_bag_outlined, color: primaryOrange, size: 38)),
        const SizedBox(height: 16),
        Text('No Orders Here', style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w800)),
      ]));
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: orders.length,
      itemBuilder: (ctx, i) => _orderCard(orders[i]),
    );
  }

  Widget _orderCard(OrderModel order) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (order.status) {
      case OrderStatus.pending:   statusColor = Colors.orange; statusLabel = 'Pending';          statusIcon = Icons.access_time_rounded; break;
      case OrderStatus.confirmed: statusColor = Colors.blue;   statusLabel = 'Confirmed';        statusIcon = Icons.check_circle_outline_rounded; break;
      case OrderStatus.ready:     statusColor = Colors.green;  statusLabel = 'Ready for Pickup'; statusIcon = Icons.store_rounded; break;
      case OrderStatus.completed: statusColor = Colors.grey;   statusLabel = 'Completed';        statusIcon = Icons.done_all_rounded; break;
      case OrderStatus.cancelled: statusColor = Colors.red;    statusLabel = 'Cancelled';        statusIcon = Icons.cancel_outlined; break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: order.imageAsset,
                width: 56, height: 56, fit: BoxFit.cover,
                placeholder: (c, u) => Container(width: 56, height: 56, color: Colors.grey.shade100,
                    child: Icon(Icons.image_outlined, color: Colors.grey.shade300)),
                errorWidget: (c, u, e) => Container(width: 56, height: 56, color: Colors.grey.shade100,
                    child: Icon(Icons.image_outlined, color: Colors.grey.shade300)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(order.item, style: TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(order.shopName, style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 12)),
              const SizedBox(height: 2),
              Text(order.price, style: TextStyle(color: primaryOrange, fontSize: 14, fontWeight: FontWeight.w800)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(order.id, style: TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(statusIcon, color: statusColor, size: 12),
                  const SizedBox(width: 4),
                  Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 10.5, fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
          ]),
          const SizedBox(height: 10),
          Divider(color: darkBrown.withOpacity(0.08), height: 1),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.access_time_rounded, color: darkBrown.withOpacity(0.4), size: 14),
            const SizedBox(width: 4),
            Text(order.date, style: TextStyle(color: darkBrown.withOpacity(0.45), fontSize: 12)),
            const Spacer(),
            if (order.status == OrderStatus.ready)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(8)),
                child: const Text('Get Directions', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
          ]),
        ]),
      ),
    );
  }
}