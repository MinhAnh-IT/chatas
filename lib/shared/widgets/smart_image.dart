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

  const SmartAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.fallbackText,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        child: Text(
          fallbackText?.isNotEmpty == true ? fallbackText![0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: radius * 0.8,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      );
    }

    final url = imageUrl!;

    // Handle network URLs
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        backgroundImage: NetworkImage(url),
        onBackgroundImageError: (error, stackTrace) {
          // Will show fallback child
        },
        child: Text(
          fallbackText?.isNotEmpty == true ? fallbackText![0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: radius * 0.8,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
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
          backgroundColor: backgroundColor ?? Colors.grey[300],
          backgroundImage: FileImage(file),
          onBackgroundImageError: (error, stackTrace) {
            // Will show fallback child
          },
          child: Text(
            fallbackText?.isNotEmpty == true ? fallbackText![0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: radius * 0.8,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        );
      }
    }

    // Handle assets
    if (url.startsWith('assets/')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        backgroundImage: AssetImage(url),
        onBackgroundImageError: (error, stackTrace) {
          // Will show fallback child
        },
        child: Text(
          fallbackText?.isNotEmpty == true ? fallbackText![0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: radius * 0.8,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      );
    }

    // Default fallback
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[300],
      child: Text(
        fallbackText?.isNotEmpty == true ? fallbackText![0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
