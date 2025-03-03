import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tottouchordertastemobileapplication/core/config/app_colors.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String? imageUrl;
  final String username;
  final double size;
  final VoidCallback? onTap;
  final File? imageFile;

  const ProfilePictureWidget({
    super.key,
    this.imageUrl,
    required this.username,
    this.size = 300,
    this.onTap,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.7),
                  AppColors.primary.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: _buildProfileImage(),
                ),
              ),
            ),
          ),
          if (onTap != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: size / 9,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    // Prioritize local file if available
    if (imageFile != null) {
      return _buildLocalFileImage();
    }

    // Then check for network image
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return _buildNetworkImage();
    }

    // Fallback to initials
    return _buildInitialsImage();
  }

  Widget _buildLocalFileImage() {
    return ClipOval(
      child: Image.file(
        imageFile!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildInitialsImage();
        },
      ),
    );
  }

  Widget _buildNetworkImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => _buildPlaceholderImage(),
      errorWidget: (context, url, error) {
        // Log the error if needed
        debugPrint('Error loading network image: $error');

        // Check for specific network-related errors
        if (error is SocketException ||
            error is HttpException ||
            error.toString().contains('404')) {
          return _buildInitialsImage();
        }

        return _buildPlaceholderImage();
      },
    );
  }

  Widget _buildInitialsImage() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getInitials(),
          style: TextStyle(
            fontSize: size / 2,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.primary.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    if (username.isEmpty) return '?';

    // Split the username and get first letters
    final parts = username.split(' ');

    // If only one name, take first two characters
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    // Take first letters of first two parts
    return parts
        .take(2)
        .map((part) => part.isNotEmpty ? part[0] : '')
        .join()
        .toUpperCase();
  }
}
