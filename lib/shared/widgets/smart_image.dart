import 'dart:io';
import 'package:flutter/material.dart';

/// Smart image widget that handles different types of image sources:
/// - Network URLs (http/https)
/// - Local file paths (file://)
/// - Asset paths
/// - Fallback to default avatar
class SmartImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? fallback;
  final String? fallbackText;

  const SmartImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallback,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallback();
    }

    final url = imageUrl!;

    // Handle network URLs
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }

    // Handle local file paths
    if (url.startsWith('file://') || url.startsWith('/')) {
      final filePath = url.startsWith('file://') ? url.substring(7) : url;
      final file = File(filePath);

      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      }
    }

    // Handle assets
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    // Default fallback
    return _buildFallback();
  }

  Widget _buildFallback() {
    if (fallback != null) {
      return fallback!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: (width ?? height ?? 40) * 0.6,
        color: Colors.grey[600],
      ),
    );
  }
}

/// Smart avatar widget that uses SmartImage for CircleAvatar
class SmartAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? fallbackText;
  final Color? backgroundColor;
  final bool showBorder;
  final bool showShadow;

  const SmartAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.fallbackText,
    this.backgroundColor,
    this.showBorder = false,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: showShadow
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : null,
      child: Container(
        decoration: showBorder
            ? BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              )
            : null,
        child: _buildAvatar(),
      ),
    );
  }

  Widget _buildAvatar() {
    final fallbackChild = _buildFallbackChild();

    print(
      'SmartAvatar: Building avatar for URL: $imageUrl, fallbackText: $fallbackText',
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      print('SmartAvatar: Using fallback - no URL provided');
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? _getGradientColors()[0],
        child: fallbackChild,
      );
    }

    final url = imageUrl!;
    print('SmartAvatar: Processing URL: $url');

    // Handle network URLs
    if (url.startsWith('http://') || url.startsWith('https://')) {
      print('SmartAvatar: Loading network image: $url');
      return ClipOval(
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: showBorder
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                )
              : null,
          child: ClipOval(
            child: Image.network(
              url,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print(
                  'SmartAvatar: Network image failed to load: $url, error: $error',
                );
                return _buildFallbackAvatar();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  print('SmartAvatar: Network image loaded successfully: $url');
                  return child;
                }
                return Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    color: _getGradientColors()[0],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: radius * 0.5,
                      height: radius * 0.5,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    // Handle local file paths
    if (url.startsWith('file://') || url.startsWith('/')) {
      final filePath = url.startsWith('file://') ? url.substring(7) : url;
      final file = File(filePath);

      if (file.existsSync()) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? _getGradientColors()[0],
          backgroundImage: FileImage(file),
          onBackgroundImageError: (error, stackTrace) {
            // Will show fallback child
          },
          child: fallbackChild,
        );
      }
    }

    // Handle assets
    if (url.startsWith('assets/')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? _getGradientColors()[0],
        backgroundImage: AssetImage(url),
        onBackgroundImageError: (error, stackTrace) {
          // Will show fallback child
        },
        child: fallbackChild,
      );
    }

    // Default fallback
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? _getGradientColors()[0],
      child: fallbackChild,
    );
  }

  Widget _buildFallbackChild() {
    return Container(
      decoration: backgroundColor == null
          ? BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getGradientColors(),
              ),
            )
          : null,
      child: Center(
        child: Text(
          fallbackText?.isNotEmpty == true
              ? fallbackText![0].toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: radius * 0.8,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(),
        ),
      ),
      child: Center(
        child: Text(
          fallbackText?.isNotEmpty == true
              ? fallbackText![0].toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: radius * 0.8,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    // Generate consistent colors based on fallback text
    if (fallbackText?.isNotEmpty == true) {
      final char = fallbackText![0].toUpperCase();
      final index = char.codeUnitAt(0) % _avatarColors.length;
      return _avatarColors[index];
    }
    return [const Color(0xFF6C7B7F), const Color(0xFF5A6B6F)];
  }

  static const List<List<Color>> _avatarColors = [
    [Color(0xFF3498DB), Color(0xFF2980B9)], // Blue
    [Color(0xFFE67E22), Color(0xFFD35400)], // Orange
    [Color(0xFF2ECC71), Color(0xFF27AE60)], // Green
    [Color(0xFFE74C3C), Color(0xFFC0392B)], // Red
    [Color(0xFF9B59B6), Color(0xFF8E44AD)], // Purple
    [Color(0xFFF39C12), Color(0xFFE67E22)], // Yellow
    [Color(0xFF1ABC9C), Color(0xFF16A085)], // Turquoise
    [Color(0xFFE91E63), Color(0xFFC2185B)], // Pink
  ];
}
