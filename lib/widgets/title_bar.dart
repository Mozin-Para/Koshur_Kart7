// lib/widgets/title_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../managers/profile_manager.dart';
import '../managers/theme_manager.dart';
import '../managers/color_manager.dart';
import '../pages/map_address/address_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/profile/login_page.dart';
import '../pages/map_address/address_model.dart';

/// Full‐height header with gradient, title, ETA, address selector, search & chips.
class FullTitleBar extends StatefulWidget implements PreferredSizeWidget {
  const FullTitleBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(240);

  @override
  State<FullTitleBar> createState() => _FullTitleBarState();
}

class _FullTitleBarState extends State<FullTitleBar> {
  Address? _defaultAddress;

  @override
  Widget build(BuildContext context) {
    final pm       = context.watch<ProfileManager>();
    final themeMgr = context.watch<ThemeManager>();
    final colorMgr = context.watch<ColorManager>();
    final accent   = colorMgr.currentMaterialColor.shade500;
    final theme    = Theme.of(context);
    final bottomColor = theme.brightness == Brightness.light
        ? Colors.white
        : theme.colorScheme.surface;

    // Status bar contrast
    final iconBrightness =
    accent.computeLuminance() > 0.5 ? Brightness.dark : Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: iconBrightness,
        statusBarBrightness: iconBrightness,
      ),
    );

    // Category chips
    final chips = [
      _Chip(icon: Icons.list, label: 'All'),
      _Chip(icon: Icons.electrical_services, label: 'Electronics'),
      _Chip(icon: Icons.brush, label: 'Beauty'),
      _Chip(icon: Icons.weekend, label: 'Decor'),
      _Chip(icon: Icons.child_care, label: 'Kids'),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, bottomColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Koshur Kart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ETA + address + avatar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  // ETA & address
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '11 min',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => AddressPage(
                                onDefaultChanged: (addr) {
                                  setState(() => _defaultAddress = addr);
                                },
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: _defaultAddress != null
                                    ? Colors.red
                                    : Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _defaultAddress?.line ??
                                      'Set your delivery address',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Avatar & login/logout
                  GestureDetector(
                    onTap: () {
                      if (pm.isLoggedIn) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ProfilePage(),
                        ));
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ));
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          backgroundImage:
                          const AssetImage('assets/avatar_dp.png'),
                        ),
                        if (!pm.isLoggedIn)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.light
                      ? Colors.white
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products, books…',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ),
            ),

            // Chips
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                children: chips,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact header that slides in when scrolling up.
class MiniTitleBar extends StatelessWidget {
  final bool isVisible;
  const MiniTitleBar({Key? key, required this.isVisible}) : super(key: key);

  static const _searchH = 48.0;
  static const _chipsH  = 48.0;
  static const _vPad    = 8.0;

  @override
  Widget build(BuildContext context) {
    final colorMgr  = context.watch<ColorManager>();
    final accent    = colorMgr.currentMaterialColor.shade500;
    final theme     = Theme.of(context);
    final bottomGrad = theme.brightness == Brightness.light
        ? Colors.white
        : theme.colorScheme.surface;
    final statusBar  = MediaQuery.of(context).padding.top;
    final height     = statusBar + _vPad + _searchH + _vPad + _chipsH;

    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, -1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accent, bottomGrad],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Search
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: _vPad),
                  child: Container(
                    height: _searchH,
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.light
                          ? Colors.white
                          : theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search products, books…',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                ),

                // Chips row
                SizedBox(
                  height: _chipsH,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 16),
                    children: [
                      _Chip(icon: Icons.list, label: 'All'),
                      _Chip(icon: Icons.electrical_services, label: 'Electronics'),
                      _Chip(icon: Icons.brush, label: 'Beauty'),
                      _Chip(icon: Icons.weekend, label: 'Decor'),
                      _Chip(icon: Icons.child_care, label: 'Kids'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A single category chip used by both bars.
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({Key? key, required this.icon, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<ColorManager>().currentMaterialColor.shade500;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        avatar: Icon(icon, size: 16, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        backgroundColor: accent,
      ),
    );
  }
}
