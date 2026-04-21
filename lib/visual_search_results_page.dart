import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'Services/visual_search_service.dart';
import 'product_detail_page.dart';
import 'shop_detail_page.dart';
import 'user_dashboard_page.dart';

class VisualSearchResultsPage extends StatefulWidget {
  final VisualSearchResult result;
  final XFile? imageFile;

  const VisualSearchResultsPage({super.key, required this.result, this.imageFile});

  @override
  State<VisualSearchResultsPage> createState() => _VisualSearchResultsPageState();
}

class _VisualSearchResultsPageState extends State<VisualSearchResultsPage> with SingleTickerProviderStateMixin {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown = const Color(0xFF2A1506);
  final Color bgColor = const Color(0xFFF0E8DF);

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        title: const Text('Visual Search Results', style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Captured Image Preview
          _buildImagePreview(),
          
          // Detected Labels
          _buildDetectedLabels(),
          
          // Results Count
          _buildResultsCount(),
          
          // Tabs
          _buildTabs(),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsList(),
                _buildShopsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (widget.imageFile == null) return const SizedBox.shrink();

    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          kIsWeb
              ? FutureBuilder<Uint8List>(
                  future: widget.imageFile!.readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.contain,
                      );
                    }
                    return Center(child: CircularProgressIndicator(color: primaryOrange));
                  },
                )
              : Image.network(
                  widget.imageFile!.path,
                  fit: BoxFit.contain,
                ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text('Captured Image', style: TextStyle(color: Colors.white, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedLabels() {
    if (widget.result.labels.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.label_outline, color: primaryOrange, size: 18),
              const SizedBox(width: 6),
              Text(
                'Detected Items',
                style: TextStyle(
                  color: darkBrown,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.result.labels.take(5).map((label) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryOrange.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.label,
                      style: TextStyle(
                        color: primaryOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(label.confidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: primaryOrange.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: bgColor,
      child: Row(
        children: [
          Icon(Icons.search, color: primaryOrange, size: 20),
          const SizedBox(width: 8),
          Text(
            'Found ${widget.result.totalResults} results',
            style: TextStyle(
              color: darkBrown,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '${widget.result.products.length} products • ${widget.result.shops.length} shops',
            style: TextStyle(
              color: darkBrown.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: primaryOrange,
        unselectedLabelColor: darkBrown.withOpacity(0.5),
        indicatorColor: primaryOrange,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        tabs: [
          Tab(text: 'Products (${widget.result.products.length})'),
          Tab(text: 'Shops (${widget.result.shops.length})'),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (widget.result.products.isEmpty) {
      return _buildEmptyState(
        icon: Icons.shopping_bag_outlined,
        message: 'No matching products found',
        subtitle: 'Try capturing a different image',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.result.products.length,
      itemBuilder: (context, index) {
        final product = widget.result.products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildShopsList() {
    if (widget.result.shops.isEmpty) {
      return _buildEmptyState(
        icon: Icons.store_outlined,
        message: 'No matching shops found',
        subtitle: 'Try capturing a different image',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.result.shops.length,
      itemBuilder: (context, index) {
        final shop = widget.result.shops[index];
        return _buildShopCard(shop);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              name: product['productName'] ?? 'Product',
              price: '₹${product['price']}',
              imageUrl: product['imageUrl'] ?? '',
              shopName: product['shopName'] ?? 'Local Shop',
              category: product['category'] ?? 'Fashion',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: product['imageUrl'] ?? '',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (c, u) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade100,
                  child: Icon(Icons.image_outlined, color: Colors.grey.shade300),
                ),
                errorWidget: (c, u, e) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade100,
                  child: Icon(Icons.image_outlined, color: Colors.grey.shade300),
                ),
              ),
            ),
            
            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['productName'] ?? 'Product',
                      style: TextStyle(
                        color: darkBrown,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.store, size: 12, color: primaryOrange.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product['shopName'] ?? 'Local Shop',
                            style: TextStyle(
                              color: darkBrown.withOpacity(0.6),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '₹${product['price']}',
                          style: TextStyle(
                            color: primaryOrange,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, size: 10, color: Colors.green),
                              const SizedBox(width: 3),
                              Text(
                                '${product['score']}% match',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildShopCard(Map<String, dynamic> shop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.store, color: primaryOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop['shopName'] ?? 'Shop',
                      style: TextStyle(
                        color: darkBrown,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      shop['category'] ?? 'Fashion',
                      style: TextStyle(
                        color: darkBrown.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${shop['score']}% match',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (shop['address'] != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: primaryOrange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${shop['address']}, ${shop['city']}',
                    style: TextStyle(
                      color: darkBrown,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (shop['phone'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: primaryOrange),
                const SizedBox(width: 6),
                Text(
                  shop['phone'],
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (shop['products'] != null && (shop['products'] as List).isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryOrange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shopping_bag, size: 16, color: primaryOrange),
                      const SizedBox(width: 6),
                      Text(
                        'Matching Products (${shop['productCount']})',
                        style: TextStyle(
                          color: primaryOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...(shop['products'] as List).map((product) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            product['name'] ?? '',
                            style: TextStyle(
                              color: darkBrown,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${product['price']}',
                          style: TextStyle(
                            color: primaryOrange,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: darkBrown,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: darkBrown.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
