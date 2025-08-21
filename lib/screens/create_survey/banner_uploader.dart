import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utilities/constants.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class BannerUploader extends StatelessWidget {
  final String? bannerPath; // Changed from bannerUrl to bannerPath
  final Function(String?) onBannerSelected;

  const BannerUploader({
    super.key,
    this.bannerPath,
    required this.onBannerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.image, color: AppConstants.primaryColor),
            SizedBox(width: 8),
            Text(
              'Survey Banner',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        bannerPath != null
            ? _buildBannerPreview()
            : _buildUploadArea(context),
      ],
    );
  }

  Widget _buildBannerPreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: _buildBannerImage(),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: InkWell(
            onTap: () => onBannerSelected(null),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerImage() {
    if (bannerPath == null) {
      return _buildErrorPlaceholder();
    }

    // Check if it's a URL or local path
    if (bannerPath!.startsWith('http')) {
      // Network image (for existing URLs)
      return Image.network(
        bannerPath!,
        width: double.infinity,
        height: 160,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    } else {
      // Local file
      return Image.file(
        File(bannerPath!),
        width: double.infinity,
        height: 160,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    }
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Failed to load image',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea(BuildContext context) {
    return InkWell(
      onTap: () => _selectBanner(context),
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[400]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          color: Colors.grey[50],
        ),
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: Colors.grey[400]!,
            strokeWidth: 2,
            borderRadius: AppConstants.borderRadius,
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 48,
                  color: AppConstants.primaryColor,
                ),
                SizedBox(height: 8),
                Text(
                  'Upload Survey Banner',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Click to add an image (optional)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Recommended: 1200 x 300 pixels',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectBanner(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Show image source selection
      final ImageSource? source = await _showImageSourceDialog(context);
      if (source == null) return;

      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 300,
        imageQuality: 85,
      );

      if (image != null && context.mounted) {
        // Show loading snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Processing banner...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );

        try {
          // Validate file size (max 5MB)
          final file = File(image.path);
          final fileSizeInBytes = await file.length();
          const maxSizeInBytes = 5 * 1024 * 1024; // 5MB

          if (fileSizeInBytes > maxSizeInBytes) {
            if (context.mounted) {
              _showErrorDialog(context, 'File size too large. Maximum size is 5MB.');
            }
            return;
          }

          // Return the local file path directly
          onBannerSelected(image.path);

          if (kDebugMode) {
            print('Banner selected: ${image.path}');
          }
        } catch (e) {
          if (context.mounted) {
            _showErrorDialog(context, 'Failed to process image: $e');
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to pick image: $e');
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;
  final List<double> dashPattern;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
    this.dashPattern = const [6, 3],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    _drawDashedPath(canvas, path, paint, dashPattern);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, List<double> pattern) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;
      int patternIndex = 0;

      while (distance < pathMetric.length) {
        final length = pattern[patternIndex % pattern.length];
        if (draw) {
          final extractPath = pathMetric.extractPath(distance, distance + length);
          canvas.drawPath(extractPath, paint);
        }
        distance += length;
        draw = !draw;
        patternIndex++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
