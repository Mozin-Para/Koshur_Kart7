// lib/widgets/profile_header.dart
// A reusable header widget that shows:
//  • Circular avatar image
//  • User’s name, phone number, date of birth, email
//  • “Refer now” code in red
//
// This file lives under widgets/ so it can be imported anywhere
// in the app where a profile header is needed.

import 'package:flutter/material.dart';

/// ProfileHeader renders the top section of a profile page.
/// It displays avatarImage on the left and user details to its right.
class ProfileHeader extends StatelessWidget {
  /// The image provider for the avatar (asset, network, or file).
  final ImageProvider avatarImage;

  /// Full name of the user.
  final String name;

  /// User’s phone number.
  final String phone;

  /// User’s date of birth.
  final String dob;

  /// User’s email address.
  final String email;

  /// Unique referral or user ID.
  final String userId;

  /// Constructor requires all user data and the avatar image.
  const ProfileHeader({
    super.key,
    required this.avatarImage,
    required this.name,
    required this.phone,
    required this.dob,
    required this.email,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      // Arrange avatar and details horizontally
      children: [
        // CircleAvatar displays the avatarImage at a fixed radius.
        CircleAvatar(
          radius: 40,            // 40px radius yields an 80px diameter
          backgroundImage: avatarImage,
        ),

        const SizedBox(width: 16), // Spacing between avatar and text

        // Expanded wraps the details column so it fills remaining space
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User’s name in bold, larger font
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4), // Small gap

              // Phone number line
              Text('Phone: $phone'),

              // Date of birth line
              Text('DOB: $dob'),

              // Email address line
              Text('Email: $email'),

              const SizedBox(height: 8), // Space before refer code

              // Refer code highlighted in red and bold
              Text(
                'Refer now: $userId',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
