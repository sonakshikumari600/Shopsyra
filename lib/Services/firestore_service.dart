import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserFirestoreService {
  static final UserFirestoreService _instance = UserFirestoreService._internal();
  factory UserFirestoreService() => _instance;
  UserFirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // USER CRUD OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String pincode,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'city': city,
        'pincode': pincode,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      return false;
    }
  }

  Future<String?> saveUserData({
    required String uid,
    required String name,
    required String phone,
    required String address,
    required String city,
    required String pincode,
    String email = '',
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'city': city,
        'pincode': pincode,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      debugPrint('Error saving user data: $e');
      return 'Failed to save user data: $e';
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    return getUserProfile(uid);
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) return doc.data();
      return null;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Future<bool> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // IMAGE UPLOAD OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<String?> uploadImageBytes(Uint8List bytes, String fileName) async {
    try {
      debugPrint('Image upload not yet implemented — returning empty URL');
      return '';
    } catch (e) {
      debugPrint('Error uploading image bytes: $e');
      return null;
    }
  }

  Future<String?> uploadImageFile(File file) async {
    try {
      debugPrint('Image upload not yet implemented — returning empty URL');
      return '';
    } catch (e) {
      debugPrint('Error uploading image file: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BOOKING OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<String?> placeBooking({
    String? uid,
    required String shopId,
    required String shopName,
    required String serviceName,
    required double price,
    required DateTime bookingDateTime,
    String status = 'pending',
  }) async {
    try {
      final userId = uid ?? _auth.currentUser?.uid;
      if (userId == null) return 'User not authenticated';

      await _firestore.collection('bookings').add({
        'userId': userId,
        'shopId': shopId,
        'shopName': shopName,
        'serviceName': serviceName,
        'price': price,
        'bookingDateTime': Timestamp.fromDate(bookingDateTime),
        'status': status, // pending / confirmed / cancelled / completed
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Booking placed successfully');
      return null;
    } catch (e) {
      debugPrint('Error placing booking: $e');
      return 'Failed to place booking: $e';
    }
  }

  // Backward compatibility ke liye — orders_page.dart use karta hai
Stream<QuerySnapshot<Map<String, dynamic>>> streamUserOrders() {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return const Stream.empty();

  return _firestore
      .collection('orders')
      .where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots();
}

// Alias
Stream<QuerySnapshot<Map<String, dynamic>>> getOrdersByUser() {
  return streamUserOrders();
}

  Future<String?> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
      return 'Failed to cancel booking: $e';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// User ki saari notifications real-time stream (latest pehle)
  Stream<QuerySnapshot<Map<String, dynamic>>> streamNotifications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Single notification ko read mark karo
  Future<void> markNotificationRead(String notifId) async {
    try {
      await _firestore.collection('notifications').doc(notifId).update({
        'isRead': true,
      });
    } catch (e) {
      debugPrint('Error marking notification read: $e');
    }
  }

  /// Sabhi notifications ek saath read mark karo
  Future<void> markAllNotificationsRead() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .get();

      // Batch write for better performance
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      debugPrint('All notifications marked as read');
    } catch (e) {
      debugPrint('Error marking all notifications read: $e');
    }
  }

  /// Single notification delete karo
  Future<void> deleteNotification(String notifId) async {
    try {
      await _firestore.collection('notifications').doc(notifId).delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  /// Unread notifications ki count (for bell badge)
  Stream<int> streamUnreadNotificationCount() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRODUCT BROWSE OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAllProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamProductsByCategory(
      String category) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots();
  }

  Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) return {'id': doc.id, ...?doc.data()};
      return null;
    } catch (e) {
      debugPrint('Error fetching product: $e');
      return null;
    }
  }
}