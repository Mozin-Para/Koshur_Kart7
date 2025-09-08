import 'package:flutter/material.dart';

import '../../managers/theme_manager.dart';
import '../../managers/color_manager.dart';
import '../../widgets/theme_mode_toggle.dart';
import 'theme_color_settings_page.dart';
import 'login_page.dart';

/// Guest‐mode profile screen: lets you toggle dark/light, pick accent color,
/// then tap "Log In" to enter the real login flow.
class GuestProfilePage extends StatelessWidget {
  final ThemeManager themeManager;
  final ColorManager colorManager;

  const GuestProfilePage({
    Key? key,
    required this.themeManager,
    required this.colorManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Profile'),
        actions: [
          // Dark/light toggle (same widget as in ProfilePage)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ThemeModeToggle(
              themeManager: themeManager,
              colorManager: colorManager,
              width: 52,
              height: 26,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          const Divider(),
          const Spacer(),

          // Log In button at bottom
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                  );
                },
                child: const Text('Log In'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}