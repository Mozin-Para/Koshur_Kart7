import 'package:flutter/material.dart';
import '../../managers/profile_manager.dart';

/// Displays a tappable card with:
///  • Avatar on left
///  • Name / Phone / DOB / Email
///  • Pencil overlay at top‐left (opens edit)
///  • Unique ID badge at top‐right (opens pop‐up)
///  • Adaptive surface & border colors for light/dark
class ProfileYourAccountDetails extends StatelessWidget {
  final String name;
  final String phone;
  final String email;
  final String dob;
  final String uniqueId;
  final VoidCallback onTap;
  final VoidCallback? onUniqueTap;

  const ProfileYourAccountDetails({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.dob,
    required this.uniqueId,
    required this.onTap,
    this.onUniqueTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final surface     = theme.colorScheme.surface;
    final onSurface   = theme.colorScheme.onSurface;
    final accent      = theme.colorScheme.primary;
    final onAccent    = theme.colorScheme.onPrimary;
    final isDark      = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white : Colors.black;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar on left
                GestureDetector(
                  onTap: onTap,
                  child: AnimatedBuilder(
                    animation: ProfileManager(),
                    builder: (_, __) => CircleAvatar(
                      radius: 40,
                      backgroundImage: ProfileManager().avatarImage,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Details column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Account Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(name,
                          style: TextStyle(
                              fontSize: 16, color: onSurface)),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Text(phone,
                              style: TextStyle(
                                  fontSize: 16, color: onSurface)),
                          const SizedBox(width: 4),
                          const Icon(Icons.check_circle,
                              color: Colors.blue, size: 16),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text('DOB: $dob',
                          style: TextStyle(
                              fontSize: 16, color: onSurface)),
                      const SizedBox(height: 8),

                      Text(email,
                          style: TextStyle(
                              fontSize: 16, color: onSurface)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Pencil overlay (top-left)
        Positioned(
          top: -10,
          left: -10,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.edit, size: 20, color: onAccent),
            ),
          ),
        ),

        // Unique ID badge (top-right)
        Positioned(
          top: -10,
          right: -10,
          child: GestureDetector(
            onTap: onUniqueTap,
            child: Container(
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(8),
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                uniqueId,
                style: TextStyle(
                  color: onAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
