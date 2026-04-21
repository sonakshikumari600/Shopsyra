import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  late Razorpay _razorpay;
  
  // Razorpay API Keys - REPLACE WITH YOUR KEYS
  static const String _keyId = 'YOUR_RAZORPAY_KEY_ID';
  static const String _keySecret = 'YOUR_RAZORPAY_KEY_SECRET';

  // Callbacks
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(ExternalWalletResponse)? onExternalWallet;

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  void initialize() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    debugPrint('✅ Razorpay initialized');
  }

  void dispose() {
    _razorpay.clear();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAYMENT HANDLERS
  // ═══════════════════════════════════════════════════════════════════════════

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('✅ Payment Success: ${response.paymentId}');
    debugPrint('   Order ID: ${response.orderId}');
    debugPrint('   Signature: ${response.signature}');
    
    if (onPaymentSuccess != null) {
      onPaymentSuccess!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌ Payment Error: ${response.code} - ${response.message}');
    
    if (onPaymentError != null) {
      onPaymentError!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('💳 External Wallet: ${response.walletName}');
    
    if (onExternalWallet != null) {
      onExternalWallet!(response);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OPEN CHECKOUT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Open Razorpay checkout
  void openCheckout({
    required double amount, // in rupees
    required String orderId,
    required String name,
    required String description,
    String? email,
    String? contact,
    Map<String, dynamic>? notes,
  }) {
    try {
      var options = {
        'key': _keyId,
        'amount': (amount * 100).toInt(), // amount in paise
        'name': 'Shopsyra',
        'description': description,
        'order_id': orderId,
        'prefill': {
          'contact': contact ?? '',
          'email': email ?? '',
          'name': name,
        },
        'theme': {
          'color': '#CC6B2C',
        },
        'notes': notes ?? {},
        'retry': {
          'enabled': true,
          'max_count': 3,
        },
        'send_sms_hash': true,
        'remember_customer': true,
        'modal': {
          'ondismiss': () {
            debugPrint('⚠️ Payment cancelled by user');
          }
        }
      };

      _razorpay.open(options);
      debugPrint('🔓 Razorpay checkout opened for ₹$amount');
    } catch (e) {
      debugPrint('❌ Error opening checkout: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UPI PAYMENT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Open UPI payment directly
  void openUpiPayment({
    required double amount,
    required String orderId,
    required String name,
    required String description,
    String? upiId,
  }) {
    try {
      var options = {
        'key': _keyId,
        'amount': (amount * 100).toInt(),
        'name': 'Shopsyra',
        'description': description,
        'order_id': orderId,
        'method': 'upi',
        'prefill': {
          'name': name,
        },
        'theme': {
          'color': '#CC6B2C',
        },
      };

      if (upiId != null) {
        options['vpa'] = upiId;
      }

      _razorpay.open(options);
      debugPrint('🔓 UPI payment opened for ₹$amount');
    } catch (e) {
      debugPrint('❌ Error opening UPI payment: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAYMENT VERIFICATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Verify payment signature (should be done on server)
  /// This is a client-side example - DO NOT use in production
  bool verifySignature({
    required String orderId,
    required String paymentId,
    required String signature,
  }) {
    // In production, verify this on your backend server
    // using Razorpay's signature verification
    debugPrint('⚠️ Payment signature verification should be done on server');
    return true;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Format amount for display
  String formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  /// Generate order ID (simple version - use backend in production)
  String generateOrderId() {
    return 'ORD_${DateTime.now().millisecondsSinceEpoch}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAYMENT MODELS
// ═══════════════════════════════════════════════════════════════════════════

class PaymentResult {
  final bool success;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? errorMessage;

  PaymentResult({
    required this.success,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorMessage,
  });

  factory PaymentResult.success({
    required String paymentId,
    required String orderId,
    required String signature,
  }) {
    return PaymentResult(
      success: true,
      paymentId: paymentId,
      orderId: orderId,
      signature: signature,
    );
  }

  factory PaymentResult.failure(String errorMessage) {
    return PaymentResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}
