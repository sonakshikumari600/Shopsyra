import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'Services/visual_search_service.dart';
import 'visual_search_results_page.dart';

class VisualSearchCameraPage extends StatefulWidget {
  final XFile? preSelectedImage;
  
  const VisualSearchCameraPage({super.key, this.preSelectedImage});

  @override
  State<VisualSearchCameraPage> createState() => _VisualSearchCameraPageState();
}

class _VisualSearchCameraPageState extends State<VisualSearchCameraPage> {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown = const Color(0xFF2A1506);
  final Color bgColor = const Color(0xFFF0E8DF);

  final VisualSearchService _visualSearchService = VisualSearchService();
  XFile? _capturedImage;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _visualSearchService.initialize();
    
    // If image was pre-selected, use it
    if (widget.preSelectedImage != null) {
      _capturedImage = widget.preSelectedImage;
      // Auto-search after a brief delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _searchProduct();
      });
    }
  }

  @override
  void dispose() {
    _visualSearchService.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    try {
      if (kIsWeb) {
        // On web, show a message that camera needs to be accessed through file picker
        _showMessage('On web, please use "Choose from Gallery" to upload an image');
        return;
      }
      
      final image = await _visualSearchService.captureImage();
      if (image != null) {
        setState(() => _capturedImage = image);
      }
    } catch (e) {
      _showMessage('Error opening camera: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final image = await _visualSearchService.pickImageFromGallery();
      if (image != null) {
        setState(() => _capturedImage = image);
      }
    } catch (e) {
      _showMessage('Error picking image: $e');
    }
  }

  Future<void> _searchProduct() async {
    if (_capturedImage == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final labels = await _visualSearchService.analyzeImage(_capturedImage!);

      if (labels.isEmpty) {
        _showMessage('Could not detect any items in the image');
        setState(() => _isAnalyzing = false);
        return;
      }

      final products = await _visualSearchService.searchProducts(labels);
      final shops = await _visualSearchService.searchShops(labels);

      final result = VisualSearchResult(
        success: true,
        imagePath: _capturedImage!.path,
        imageFile: _capturedImage,
        labels: labels,
        products: products,
        shops: shops,
      );

      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      if (result.hasResults) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VisualSearchResultsPage(
              result: result,
              imageFile: _capturedImage,
            ),
          ),
        );
      } else {
        _showMessage('No matching products found');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      _showMessage('Error: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        title: const Text('Visual Search', style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: _capturedImage == null ? _buildInitialState() : _buildImagePreview(),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: 70,
                color: primaryOrange,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Search with Camera',
              style: TextStyle(
                color: darkBrown,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Take a photo of any product to find\nsimilar items in nearby shops',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkBrown.withOpacity(0.6),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            _buildActionButton(
              icon: Icons.camera_alt,
              label: 'Open Camera',
              onTap: _openCamera,
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              icon: Icons.photo_library,
              label: 'Choose from Gallery',
              onTap: _pickFromGallery,
              isPrimary: false,
            ),
            const SizedBox(height: 32),
            _buildFeaturesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: Center(
              child: kIsWeb
                  ? FutureBuilder<Uint8List>(
                      future: _capturedImage!.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.contain,
                          );
                        }
                        return CircularProgressIndicator(color: primaryOrange);
                      },
                    )
                  : Image.network(
                      _capturedImage!.path,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              if (_isAnalyzing) ...[
                CircularProgressIndicator(color: primaryOrange),
                const SizedBox(height: 16),
                Text(
                  'Analyzing image...',
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildBottomButton(
                        icon: Icons.refresh,
                        label: 'Retake',
                        onTap: () => setState(() => _capturedImage = null),
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _buildBottomButton(
                        icon: Icons.search,
                        label: 'Search Products',
                        onTap: _searchProduct,
                        isPrimary: true,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [primaryOrange, const Color(0xFFA8481A)],
                )
              : null,
          color: isPrimary ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: primaryOrange, width: 2),
          boxShadow: [
            BoxShadow(
              color: (isPrimary ? primaryOrange : Colors.black).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : primaryOrange,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : primaryOrange,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [primaryOrange, const Color(0xFFA8481A)],
                )
              : null,
          color: isPrimary ? null : bgColor,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: primaryOrange.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : primaryOrange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : primaryOrange,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How it works',
            style: TextStyle(
              color: darkBrown,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            Icons.camera_alt,
            'Capture',
            'Take a photo of the product',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.auto_awesome,
            'Analyze',
            'AI detects product features',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.store,
            'Find',
            'Get matching products & shops',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: primaryOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryOrange, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: darkBrown,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: darkBrown.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
