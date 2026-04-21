import 'package:flutter/material.dart';
import 'Services/location_service.dart';
import 'Services/payment_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Example page showing how to use all API services
class ApiExamplePage extends StatefulWidget {
  const ApiExamplePage({super.key});

  @override
  State<ApiExamplePage> createState() => _ApiExamplePageState();
}

class _ApiExamplePageState extends State<ApiExamplePage> {
  final LocationService _locationService = LocationService();
  final PaymentService _paymentService = PaymentService();

  Position? _currentPosition;
  String _locationStatus = 'Not fetched';
  String _paymentStatus = 'Not initiated';

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  void _initializePayment() {
    _paymentService.initialize();
    
    _paymentService.onPaymentSuccess = (PaymentSuccessResponse response) {
      setState(() {
        _paymentStatus = 'Success: ${response.paymentId}';
      });
      _showDialog('Payment Successful', 'Payment ID: ${response.paymentId}');
    };

    _paymentService.onPaymentError = (PaymentFailureResponse response) {
      setState(() {
        _paymentStatus = 'Failed: ${response.message}';
      });
      _showDialog('Payment Failed', response.message ?? 'Unknown error');
    };

    _paymentService.onExternalWallet = (ExternalWalletResponse response) {
      setState(() {
        _paymentStatus = 'Wallet: ${response.walletName}';
      });
    };
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCATION EXAMPLES
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _getCurrentLocation() async {
    setState(() => _locationStatus = 'Fetching...');
    
    final position = await _locationService.getCurrentLocation();
    
    if (position != null) {
      setState(() {
        _currentPosition = position;
        _locationStatus = 'Lat: ${position.latitude.toStringAsFixed(4)}, '
                         'Lng: ${position.longitude.toStringAsFixed(4)}';
      });
    } else {
      setState(() => _locationStatus = 'Failed to get location');
    }
  }

  Future<void> _getAddress() async {
    if (_currentPosition == null) {
      _showDialog('Error', 'Get current location first');
      return;
    }

    final address = await _locationService.getAddressFromCoordinates(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    if (address != null) {
      _showDialog('Your Address', address);
    } else {
      _showDialog('Error', 'Could not get address');
    }
  }

  Future<void> _calculateDistance() async {
    if (_currentPosition == null) {
      _showDialog('Error', 'Get current location first');
      return;
    }

    // Example: Calculate distance to a shop
    const shopLat = 28.6139; // Example shop coordinates
    const shopLng = 77.2090;

    final distance = _locationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      shopLat,
      shopLng,
    );

    final formatted = _locationService.formatDistance(distance);
    final walkTime = _locationService.calculateWalkingTime(distance);
    final driveTime = _locationService.calculateDrivingTime(distance);

    _showDialog(
      'Distance to Shop',
      'Distance: $formatted\n'
      'Walking: $walkTime\n'
      'Driving: $driveTime'
    );
  }

  Future<void> _getDistanceMatrix() async {
    if (_currentPosition == null) {
      _showDialog('Error', 'Get current location first');
      return;
    }

    setState(() => _locationStatus = 'Calculating route...');

    const shopLat = 28.6139;
    const shopLng = 77.2090;

    final result = await _locationService.getDistanceMatrix(
      originLat: _currentPosition!.latitude,
      originLng: _currentPosition!.longitude,
      destLat: shopLat,
      destLng: shopLng,
      mode: 'driving',
    );

    if (result != null) {
      _showDialog(
        'Route Information',
        'Distance: ${result['distance']}\n'
        'Duration: ${result['duration']}'
      );
    } else {
      _showDialog('Error', 'Could not calculate route');
    }

    setState(() => _locationStatus = 'Route calculated');
  }

  Future<void> _searchNearbyShops() async {
    if (_currentPosition == null) {
      _showDialog('Error', 'Get current location first');
      return;
    }

    setState(() => _locationStatus = 'Searching nearby...');

    final places = await _locationService.searchNearbyPlaces(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      radius: 5000, // 5 km
      type: 'clothing_store',
    );

    if (places.isNotEmpty) {
      final placesList = places.take(5).map((p) => 
        '${p['name']} - ${p['address']}'
      ).join('\n\n');
      
      _showDialog('Nearby Shops (${places.length})', placesList);
    } else {
      _showDialog('No Results', 'No shops found nearby');
    }

    setState(() => _locationStatus = 'Search complete');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAYMENT EXAMPLES
  // ═══════════════════════════════════════════════════════════════════════════

  void _makePayment() {
    _paymentService.openCheckout(
      amount: 999.00,
      orderId: _paymentService.generateOrderId(),
      name: 'Test User',
      description: 'Blue Jacket Purchase',
      email: 'test@example.com',
      contact: '9876543210',
      notes: {
        'product': 'Blue Jacket',
        'size': 'L',
      },
    );
  }

  void _makeUpiPayment() {
    _paymentService.openUpiPayment(
      amount: 999.00,
      orderId: _paymentService.generateOrderId(),
      name: 'Test User',
      description: 'Blue Jacket Purchase',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UI
  // ═══════════════════════════════════════════════════════════════════════════

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Examples'),
        backgroundColor: const Color(0xFFCC6B2C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Location Section
            _buildSection(
              'Location Services',
              Icons.location_on,
              Colors.blue,
              [
                _buildButton('Get Current Location', _getCurrentLocation),
                _buildButton('Get Address', _getAddress),
                _buildButton('Calculate Distance', _calculateDistance),
                _buildButton('Get Route Info (Distance Matrix)', _getDistanceMatrix),
                _buildButton('Search Nearby Shops', _searchNearbyShops),
              ],
            ),
            
            _buildStatus('Location Status', _locationStatus),
            
            const SizedBox(height: 24),
            
            // Payment Section
            _buildSection(
              'Payment Services',
              Icons.payment,
              Colors.green,
              [
                _buildButton('Make Payment (₹999)', _makePayment),
                _buildButton('UPI Payment (₹999)', _makeUpiPayment),
              ],
            ),
            
            _buildStatus('Payment Status', _paymentStatus),
            
            const SizedBox(height: 24),
            
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Setup Required',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Add Google Maps API key in location_service.dart\n'
                    '2. Add Razorpay keys in payment_service.dart\n'
                    '3. Enable location permissions\n'
                    '4. See API_SETUP_GUIDE.md for details',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCC6B2C),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildStatus(String label, String status) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
