// lib/pages/profile/guest_profile_page.dart

import 'package:flutter/material.dart';
import 'login_page.dart';  // <-- correct relative import

/// Simple profile screen for guests:
/// • Toggle dark mode via Theme.of(context)
/// • “Log In” button navigates to your real LoginPage
class GuestProfilePage extends StatelessWidget {
  const GuestProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Guest Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dark Mode switch
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: theme.brightness == Brightness.dark,
              onChanged: (v) {
                // If you have a singleton ThemeManager, call it here:
                // ThemeManager().toggleDarkMode(v);
              },
            ),

            const SizedBox(height: 24),

            const Divider(),

            const Spacer(),

            // Log In button at bottom
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text('Log In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
