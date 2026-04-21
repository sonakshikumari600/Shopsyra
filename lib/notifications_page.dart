import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:user_shopsyra/Services/firestore_service.dart';

// ─────────────────────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────────────────────

enum NotifType { offer, deal, booking, shop, system }

class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final NotifType type;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.type,
    this.isRead = false,
  });

  String get timeAgo => timeago.format(createdAt);

  /// Firestore document se NotificationModel banana
  factory NotificationModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    // type string ko enum mein convert karo
    NotifType type;
    switch ((data['type'] as String? ?? 'system').toLowerCase()) {
      case 'offer':   type = NotifType.offer;   break;
      case 'deal':    type = NotifType.deal;     break;
      case 'booking': type = NotifType.booking;  break;
      case 'shop':    type = NotifType.shop;     break;
      default:        type = NotifType.system;
    }

    return NotificationModel(
      id:        doc.id,
      title:     data['title']    as String? ?? '',
      subtitle:  data['subtitle'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type:      type,
      isRead:    data['isRead']   as bool? ?? false,
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PAGE
// ─────────────────────────────────────────────────────────────

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown     = const Color(0xFF2A1506);
  final Color bgColor       = const Color(0xFFF0E8DF);

  final _service = UserFirestoreService();

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _markAllRead(List<NotificationModel> notifications) async {
    await _service.markAllNotificationsRead();
  }

  Future<void> _markOneRead(NotificationModel notif) async {
    if (!notif.isRead) {
      await _service.markNotificationRead(notif.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // StreamBuilder sirf unread count ke liye (nav bar)
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _service.streamNotifications(),
            builder: (context, snap) {
              final notifications = snap.hasData
                  ? snap.data!.docs
                      .map((d) => NotificationModel.fromDoc(d))
                      .toList()
                  : <NotificationModel>[];
              final unread = notifications.where((n) => !n.isRead).length;
              return _buildNavBar(context, unread, notifications);
            },
          ),

          // Main list
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _service.streamNotifications(),
              builder: (context, snap) {
                // Loading
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                        color: primaryOrange, strokeWidth: 2.5),
                  );
                }

                // Error
               if (snap.hasError) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(
            color: primaryOrange.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.notifications_none_rounded,
              color: primaryOrange.withOpacity(0.5), size: 42),
        ),
        const SizedBox(height: 20),
        Text('No Notifications Yet',
            style: TextStyle(
                color: darkBrown,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(
          'You\'re all caught up!\nWe\'ll notify you when something\narrives for you.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: darkBrown.withOpacity(0.45),
              fontSize: 13.5,
              height: 1.6),
        ),
      ],
    ),
  );
}

                final notifications = snap.hasData
                    ? snap.data!.docs
                        .map((d) => NotificationModel.fromDoc(d))
                        .toList()
                    : <NotificationModel>[];

                // Pehli baar aane par fade in
                if (!_fadeCtrl.isAnimating && _fadeCtrl.value == 0) {
                  _fadeCtrl.forward();
                }

                if (notifications.isEmpty) return _emptyState();

                return FadeTransition(
                  opacity: _fadeAnim,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: notifications.length,
                    itemBuilder: (ctx, i) => _notifCard(notifications[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── NAV BAR ──
  Widget _buildNavBar(BuildContext context, int unreadCount,
      List<NotificationModel> notifications) {
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.07), blurRadius: 8)
                  ],
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: darkBrown, size: 16),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notifications',
                      style: TextStyle(
                          color: darkBrown,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  if (unreadCount > 0)
                    Text('$unreadCount unread',
                        style: TextStyle(
                            color: primaryOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (unreadCount > 0)
              GestureDetector(
                onTap: () => _markAllRead(notifications),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Mark all read',
                      style: TextStyle(
                          color: primaryOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── NOTIFICATION CARD ──
  Widget _notifCard(NotificationModel notif) {
    Color iconBg;
    IconData iconData;
    Color iconColor;

    switch (notif.type) {
      case NotifType.offer:
        iconBg = const Color(0xFFFFE8D6);
        iconData = Icons.local_offer_rounded;
        iconColor = primaryOrange;
        break;
      case NotifType.deal:
        iconBg = const Color(0xFFFFF3CD);
        iconData = Icons.flash_on_rounded;
        iconColor = Colors.amber.shade700;
        break;
      case NotifType.booking:
        iconBg = const Color(0xFFD6E4FF);
        iconData = Icons.calendar_today_rounded;
        iconColor = Colors.blue.shade600;
        break;
      case NotifType.shop:
        iconBg = const Color(0xFFD6EAD6);
        iconData = Icons.store_rounded;
        iconColor = Colors.green.shade600;
        break;
      case NotifType.system:
        iconBg = const Color(0xFFE8E8E8);
        iconData = Icons.info_rounded;
        iconColor = Colors.grey.shade600;
        break;
    }

    return GestureDetector(
      onTap: () => _markOneRead(notif),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color:
              notif.isRead ? Colors.white : primaryOrange.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead
                ? Colors.transparent
                : primaryOrange.withOpacity(0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(iconData, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(notif.title,
                              style: TextStyle(
                                  color: darkBrown,
                                  fontSize: 13.5,
                                  fontWeight: notif.isRead
                                      ? FontWeight.w600
                                      : FontWeight.w800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                                color: primaryOrange,
                                shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notif.subtitle,
                        style: TextStyle(
                            color: darkBrown.withOpacity(0.55),
                            fontSize: 12.5,
                            height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    // Real timestamp from Firestore
                    Text(notif.timeAgo,
                        style: TextStyle(
                            color: darkBrown.withOpacity(0.35),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── EMPTY STATE ──
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.1),
                shape: BoxShape.circle),
            child: Icon(Icons.notifications_off_outlined,
                color: primaryOrange, size: 42),
          ),
          const SizedBox(height: 20),
          Text('No Notifications',
              style: TextStyle(
                  color: darkBrown,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
              'You\'re all caught up!\nNew notifications will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: darkBrown.withOpacity(0.45),
                  fontSize: 13.5,
                  height: 1.5)),
        ],
      ),
    );
  }
}