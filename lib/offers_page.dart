import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OfferModel {
  final String title;
  final String shopName;
  final String discount;
  final String description;
  final String validTill;
  final String imageAsset;
  final Color tagColor;
  OfferModel({required this.title, required this.shopName, required this.discount,
      required this.description, required this.validTill, required this.imageAsset, required this.tagColor});
}

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});
  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown     = const Color(0xFF2A1506);
  final Color bgColor       = const Color(0xFFF0E8DF);

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Today', 'This Week', 'Clearance'];

  final List<OfferModel> _offers = [
    OfferModel(title: 'Flat 30% Off on Jackets', shopName: 'Vogue Boutique',
        discount: '30% OFF', description: 'Get flat 30% off on all jacket collections. Limited stock available!',
        validTill: 'Today only', imageAsset: 'https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg?w=400', tagColor: const Color(0xFFCC6B2C)),
    OfferModel(title: 'Buy 2 Get 1 Free', shopName: 'Urban Style',
        discount: 'B2G1', description: 'Buy any 2 T-shirts and get 1 absolutely free. All sizes available.',
        validTill: 'Valid till Sunday', imageAsset: 'https://images.pexels.com/photos/1656684/pexels-photo-1656684.jpeg?w=400', tagColor: Colors.green),
    OfferModel(title: 'Upto 50% Off on Jeans', shopName: 'Fashion Hub',
        discount: '50% OFF', description: 'Season end sale on denim collection. Grab before stock runs out!',
        validTill: 'Valid till Friday', imageAsset: 'https://images.pexels.com/photos/1082529/pexels-photo-1082529.jpeg?w=400', tagColor: Colors.blue),
    OfferModel(title: 'Sneakers at ₹999', shopName: 'Lifestyle Attire',
        discount: '₹999 FLAT', description: 'Special price on premium sneakers. Only while stocks last.',
        validTill: 'This week only', imageAsset: 'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg?w=400', tagColor: Colors.purple),
    OfferModel(title: 'New Arrivals — 20% Off', shopName: 'Vogue Boutique',
        discount: '20% OFF', description: 'Get 20% off on all new arrivals. Fresh styles every week!',
        validTill: 'Ongoing', imageAsset: 'https://images.pexels.com/photos/1488463/pexels-photo-1488463.jpeg?w=400', tagColor: const Color(0xFFCC6B2C)),
    OfferModel(title: 'Clearance Sale — 70% Off', shopName: 'Fashion Hub',
        discount: '70% OFF', description: 'End of season clearance. Massive discounts on selected items.',
        validTill: 'Last 2 days!', imageAsset: 'https://images.pexels.com/photos/3965545/pexels-photo-3965545.jpeg?w=400', tagColor: Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _navBar(context),
          _filterChips(),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _offers.length,
              itemBuilder: (ctx, i) => _offerCard(_offers[i]),
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
                Text('Offers & Deals', style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w800)),
                Text('Nearby shops special offers', style: TextStyle(color: darkBrown.withOpacity(0.45), fontSize: 12)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: primaryOrange.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Icon(Icons.local_offer_rounded, color: primaryOrange, size: 14),
                const SizedBox(width: 4),
                Text('${_offers.length} Offers', style: TextStyle(color: primaryOrange, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, bottom: 4),
        itemCount: _filters.length,
        itemBuilder: (ctx, i) {
          final active = _selectedFilter == _filters[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = _filters[i]),
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

  Widget _offerCard(OfferModel offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
                  imageUrl: offer.imageAsset,
                  height: 140, width: double.infinity, fit: BoxFit.cover,
                  placeholder: (c, u) => Container(height: 140, color: Colors.grey.shade100,
                      child: Icon(Icons.local_offer_outlined, color: Colors.grey.shade300, size: 48)),
                  errorWidget: (c, u, e) => Container(height: 140, color: Colors.grey.shade100,
                      child: Icon(Icons.local_offer_outlined, color: Colors.grey.shade300, size: 48)),
                ),
              ),
              Positioned(
                top: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: offer.tagColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: offer.tagColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Text(offer.discount,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                ),
              ),
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
                  child: Text(offer.validTill,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer.title, style: TextStyle(color: darkBrown, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.store_outlined, color: primaryOrange, size: 14),
                  const SizedBox(width: 4),
                  Text(offer.shopName, style: TextStyle(color: primaryOrange, fontSize: 12.5, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 6),
                Text(offer.description,
                    style: TextStyle(color: darkBrown.withOpacity(0.55), fontSize: 12.5, height: 1.4),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primaryOrange, const Color(0xFFA8481A)],
                            begin: Alignment.centerLeft, end: Alignment.centerRight),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: primaryOrange.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: const Center(child: Text('Grab This Deal',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: primaryOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.bookmark_outline_rounded, color: primaryOrange, size: 20),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}