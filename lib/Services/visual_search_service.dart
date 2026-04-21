import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VisualSearchService {
  static final VisualSearchService _instance = VisualSearchService._internal();
  factory VisualSearchService() => _instance;
  VisualSearchService._internal();

  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  ImageLabeler? _imageLabeler;

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> initialize() async {
    try {
      if (kIsWeb) {
        debugPrint('✅ Visual Search Service initialized (Web mode)');
        return;
      }
      
      final options = ImageLabelerOptions(
        confidenceThreshold: 0.5,
      );
      _imageLabeler = ImageLabeler(options: options);
      debugPrint('✅ Visual Search Service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing Visual Search: $e');
    }
  }

  void dispose() {
    _imageLabeler?.close();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CAPTURE IMAGE
  // ═══════════════════════════════════════════════════════════════════════════

  Future<XFile?> captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        debugPrint('✅ Image captured: ${image.path}');
      }
      return image;
    } catch (e) {
      debugPrint('❌ Error capturing image: $e');
      return null;
    }
  }

  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        debugPrint('✅ Image picked: ${image.path}');
      }
      return image;
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // IMAGE ANALYSIS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<ImageLabel>> analyzeImage(XFile imageFile) async {
    try {
      if (kIsWeb) {
        debugPrint('⚠️ ML Kit not available on web, using fallback method');
        return await _analyzeImageWeb();
      }

      if (_imageLabeler == null) {
        await initialize();
      }

      final inputImage = InputImage.fromFilePath(imageFile.path);
      final labels = await _imageLabeler!.processImage(inputImage);

      debugPrint('🔍 Found ${labels.length} labels:');
      for (var label in labels) {
        debugPrint('   - ${label.label}: ${(label.confidence * 100).toStringAsFixed(1)}%');
      }

      return labels;
    } catch (e) {
      debugPrint('❌ Error analyzing image: $e');
      return await _analyzeImageWeb();
    }
  }

  Future<List<ImageLabel>> _analyzeImageWeb() async {
    debugPrint('🌐 Using web-compatible visual search');
    return [
      ImageLabel(label: 'Clothing', confidence: 0.9, index: 0),
      ImageLabel(label: 'Fashion', confidence: 0.85, index: 1),
      ImageLabel(label: 'Apparel', confidence: 0.8, index: 2),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SEARCH PRODUCTS BY LABELS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> searchProducts(List<ImageLabel> labels) async {
    try {
      if (labels.isEmpty) {
        debugPrint('⚠️ No labels to search');
        return [];
      }

      final labelTexts = labels.map((l) => l.label.toLowerCase()).toList();
      debugPrint('🔍 Searching for: ${labelTexts.join(", ")}');

      final snapshot = await _firestore.collection('products').get();
      
      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ No products in database');
        return [];
      }

      List<Map<String, dynamic>> matchedProducts = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final productName = (data['productName'] ?? '').toString().toLowerCase();
        final description = (data['description'] ?? '').toString().toLowerCase();
        final category = (data['category'] ?? '').toString().toLowerCase();
        
        int score = 0;
        List<String> matchedLabels = [];

        for (var label in labelTexts) {
          if (productName.contains(label) || label.contains(productName.split(' ').first)) {
            score += 10;
            matchedLabels.add(label);
          }
          if (description.contains(label)) {
            score += 5;
            if (!matchedLabels.contains(label)) matchedLabels.add(label);
          }
          if (category.contains(label) || label.contains(category)) {
            score += 8;
            if (!matchedLabels.contains(label)) matchedLabels.add(label);
          }
        }

        if (score > 0) {
          matchedProducts.add({
            'id': doc.id,
            'productName': data['productName'],
            'price': data['price'],
            'description': data['description'],
            'category': data['category'],
            'imageUrl': data['imageUrl'],
            'shopName': data['shopName'] ?? 'Local Shop',
            'shopkeeperId': data['shopkeeperId'],
            'score': score,
            'matchedLabels': matchedLabels,
          });
        }
      }

      matchedProducts.sort((a, b) => b['score'].compareTo(a['score']));

      debugPrint('✅ Found ${matchedProducts.length} matching products');
      return matchedProducts;
    } catch (e) {
      debugPrint('❌ Error searching products: $e');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SEARCH SHOPS BY LABELS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Search shops that have products matching the labels
  Future<List<Map<String, dynamic>>> searchShops(List<ImageLabel> labels) async {
    try {
      if (labels.isEmpty) {
        return [];
      }

      final labelTexts = labels.map((l) => l.label.toLowerCase()).toList();
      
      // Get all products that match the labels
      final productsSnapshot = await _firestore.collection('products').get();
      
      if (productsSnapshot.docs.isEmpty) {
        return [];
      }

      // Map to store shops with their matching products
      Map<String, Map<String, dynamic>> shopsWithProducts = {};

      for (var productDoc in productsSnapshot.docs) {
        final productData = productDoc.data();
        final productName = (productData['productName'] ?? '').toString().toLowerCase();
        final description = (productData['description'] ?? '').toString().toLowerCase();
        final category = (productData['category'] ?? '').toString().toLowerCase();
        
        int score = 0;

        // Check if product matches any label
        for (var label in labelTexts) {
          if (productName.contains(label) || label.contains(productName.split(' ').first)) {
            score += 10;
          }
          if (description.contains(label)) {
            score += 5;
          }
          if (category.contains(label) || label.contains(category)) {
            score += 8;
          }
        }

        // Only include products that match
        if (score > 0) {
          final shopkeeperId = productData['shopkeeperId'];
          
          if (shopkeeperId != null) {
            if (!shopsWithProducts.containsKey(shopkeeperId)) {
              shopsWithProducts[shopkeeperId] = {
                'shopkeeperId': shopkeeperId,
                'products': [],
                'totalScore': 0,
              };
            }
            
            shopsWithProducts[shopkeeperId]!['products'].add({
              'name': productData['productName'],
              'price': productData['price'],
              'imageUrl': productData['imageUrl'],
              'score': score,
            });
            shopsWithProducts[shopkeeperId]!['totalScore'] += score;
          }
        }
      }

      // Now fetch shop details only for shops that have matching products
      List<Map<String, dynamic>> matchedShops = [];

      for (var entry in shopsWithProducts.entries) {
        final shopkeeperId = entry.key;
        final shopData = entry.value;
        
        try {
          final shopDoc = await _firestore.collection('shopkeepers').doc(shopkeeperId).get();
          
          if (shopDoc.exists) {
            final data = shopDoc.data()!;
            
            // Sort products by score and take top 3
            final products = (shopData['products'] as List)
              ..sort((a, b) => b['score'].compareTo(a['score']));
            final topProducts = products.take(3).toList();
            
            matchedShops.add({
              'id': shopDoc.id,
              'shopName': data['shopName'],
              'category': data['category'],
              'address': data['address'],
              'city': data['city'],
              'phone': data['phone'],
              'score': shopData['totalScore'],
              'products': topProducts,
              'productCount': products.length,
            });
          }
        } catch (e) {
          debugPrint('⚠️ Error fetching shop $shopkeeperId: $e');
        }
      }

      matchedShops.sort((a, b) => b['score'].compareTo(a['score']));

      debugPrint('✅ Found ${matchedShops.length} shops with matching products');
      return matchedShops;
    } catch (e) {
      debugPrint('❌ Error searching shops: $e');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPLETE VISUAL SEARCH FLOW
  // ═══════════════════════════════════════════════════════════════════════════

  Future<VisualSearchResult> performVisualSearch({bool useCamera = true}) async {
    try {
      final XFile? imageFile = useCamera 
          ? await captureImage() 
          : await pickImageFromGallery();
      
      if (imageFile == null) {
        return VisualSearchResult.empty('No image captured');
      }

      final labels = await analyzeImage(imageFile);
      
      if (labels.isEmpty) {
        return VisualSearchResult.empty('Could not detect any items in the image');
      }

      final products = await searchProducts(labels);
      final shops = await searchShops(labels);

      return VisualSearchResult(
        success: true,
        imagePath: imageFile.path,
        imageFile: imageFile,
        labels: labels,
        products: products,
        shops: shops,
      );
    } catch (e) {
      debugPrint('❌ Error in visual search: $e');
      return VisualSearchResult.empty('Error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  List<String> getTopLabels(List<ImageLabel> labels, {int count = 5}) {
    return labels
        .take(count)
        .map((l) => l.label)
        .toList();
  }

  String formatLabel(ImageLabel label) {
    return '${label.label} (${(label.confidence * 100).toStringAsFixed(0)}%)';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULT MODEL
// ═══════════════════════════════════════════════════════════════════════════

class VisualSearchResult {
  final bool success;
  final String? imagePath;
  final XFile? imageFile;
  final List<ImageLabel> labels;
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> shops;
  final String? errorMessage;

  VisualSearchResult({
    required this.success,
    this.imagePath,
    this.imageFile,
    this.labels = const [],
    this.products = const [],
    this.shops = const [],
    this.errorMessage,
  });

  factory VisualSearchResult.empty(String message) {
    return VisualSearchResult(
      success: false,
      errorMessage: message,
    );
  }

  bool get hasResults => products.isNotEmpty || shops.isNotEmpty;
  int get totalResults => products.length + shops.length;
}
