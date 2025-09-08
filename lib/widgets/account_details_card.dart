// lib/widgets/account_details_card.dart
// A boxed outline widget showing the top section of the Profile page:
// • “Your Account Details” header
// • Left column: Name, Phone, Email—each with an inline edit icon
// • Right column: Avatar with Unique ID above
// • Bottom line: Reference Number and a success message

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; info: The import of 'package:flutter/services.dart' is unnecessary because all of the used elements are also provided by the import of 'package:flutter/material.dart'. (unnecessary_import at [koshur_kart] lib\widgets\account_details_card.dart:9)
import '../managers/profile_manager.dart';

class AccountDetailsCard extends StatelessWidget {
  /// Display name
  final String name;

  /// Phone number
  final String phone;

  /// Email address
  final String email;

  /// Unique ID displayed above the avatar
  final String uniqueId;

  /// Reference number displayed at bottom
  final String referenceNumber;

  /// Callback when user taps the pencil to edit their name
  final VoidCallback onEditName;

  /// Callback when user taps the pencil to edit their phone
  final VoidCallback onEditPhone;

  /// Callback when user taps the pencil to edit their email
  final VoidCallback onEditEmail;

  const AccountDetailsCard({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.uniqueId,
    required this.referenceNumber,
    required this.onEditName,
    required this.onEditPhone,
    required this.onEditEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 1) Box outline with rounded corners
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),  // 2) Inner padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3) Header text
          const Text(
            'Your Account Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),  // 4) Spacing below header

          // 5) Row containing fields on left and avatar on right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── LEFT COLUMN: editable text fields ───────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // a) Name row with pencil icon
                    Row(
                      children: [
                        // Name text
                        Expanded(child: Text(name, style: const TextStyle(fontSize: 16))),
                        // Pencil icon to edit name
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: onEditName,
                          tooltip: 'Edit name',
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // b) Phone row with pencil icon
                    Row(
                      children: [
                        Expanded(child: Text(phone, style: const TextStyle(fontSize: 16))),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: onEditPhone,
                          tooltip: 'Edit phone',
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // c) Email row with pencil icon
                    Row(
                      children: [
                        Expanded(child: Text(email, style: const TextStyle(fontSize: 16))),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: onEditEmail,
                          tooltip: 'Edit email',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),  // 6) Gap between columns

              // ── RIGHT COLUMN: avatar + unique ID ────────────────
              Column(
                children: [
                  // Unique ID text
                  Text(
                    uniqueId,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // CircleAvatar listening to ProfileManager for live updates
                  AnimatedBuilder(
                    animation: ProfileManager(),
                    builder: (_, __) => CircleAvatar(
                      radius: 40,
                      backgroundImage: ProfileManager().avatarImage,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),  // 7) Spacer before footer

          // 8) Reference number + success message
          Row(
            children: [
              Text(
                'Reference Number: $referenceNumber',
                style: const TextStyle(fontSize: 14),
              ),
              const Spacer(),
              const Text(
                'Successfully updated',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
