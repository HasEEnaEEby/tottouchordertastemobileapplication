import 'package:flutter/material.dart';

/// CustomerProfileView displays the customer's profile information and provides
/// options for editing the profile, changing the password, and other account settings.
class CustomerProfileView extends StatelessWidget {
  final String userName;
  final String email;
  // Optionally, you can add more fields like profileImage, phoneNumber, etc.

  const CustomerProfileView({
    super.key,
    required this.userName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Profile Header
            _ProfileHeader(
              userName: userName,
              email: email,
              profileImage:
                  'assets/profile.jpg', // Update with your asset path or network URL
            ),
            const SizedBox(height: 24),

            /// Profile Options
            _ProfileOption(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () {
                // Navigate to the Edit Profile screen
              },
            ),
            _ProfileOption(
              icon: Icons.lock,
              title: 'Change Password',
              onTap: () {
                // Navigate to the Change Password screen
              },
            ),
            _ProfileOption(
              icon: Icons.credit_card,
              title: 'Saved Cards',
              onTap: () {
                // Navigate to the Saved Cards screen
              },
            ),
            _ProfileOption(
              icon: Icons.language,
              title: 'Change Language',
              onTap: () {
                // Navigate to language settings
              },
            ),
            _ProfileOption(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                // Implement logout logic here
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// _ProfileHeader displays the user's profile image, name, and email.
class _ProfileHeader extends StatelessWidget {
  final String userName;
  final String email;
  final String profileImage;

  const _ProfileHeader({
    super.key,
    required this.userName,
    required this.email,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(profileImage),
          onBackgroundImageError: (_, __) {
            // Fallback if the image fails to load.
          },
        ),
        const SizedBox(height: 16),
        Text(
          userName,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          email,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

/// _ProfileOption is a reusable widget for a clickable profile option.
class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
