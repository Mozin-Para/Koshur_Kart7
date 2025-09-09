// lib/widgets/bottom_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../managers/color_manager.dart';

/// A single icon+label item in the bar.
class BottomBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
  final Color labelColor;

  const BottomBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor = Colors.transparent,
    this.iconColor       = Colors.white,
    this.labelColor      = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: labelColor, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A floating bottom navigation bar that:
///  • Slides up/down on scroll
///  • Fades in/out
///  • Always floats above the system nav bar
class FloatingBottomBar extends StatelessWidget {
  final bool isVisible;
  final ValueChanged<int> onItemSelected;

  const FloatingBottomBar({
    super.key,
    required this.isVisible,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Fetch accent color from Provider
    final accent = context.watch<ColorManager>().currentMaterialColor.shade500;

    // Height of the system nav bar (for gesture navigation)
    final navBarHeight = MediaQuery.of(context).viewPadding.bottom;

    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 600),
        child: Padding(
          padding: EdgeInsets.only(bottom: navBarHeight),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Material(
              // Full opacity: no withOpacity needed
              color: accent,
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: List.generate(6, (i) {
                    const icons = [
                      Icons.store,
                      Icons.category,
                      Icons.copy,
                      Icons.support_agent,
                      Icons.shopping_cart,
                      Icons.other_houses,
                    ];
                    const labels = [
                      'Home',
                      'Categories',
                      'Photostat',
                      'Support',
                      'Cart',
                      'Room Rent',
                    ];
                    final isExternal = i == 5;

                    return BottomBarItem(
                      icon: icons[i],
                      label: labels[i],
                      onTap: () async {
                        onItemSelected(i);
                        if (isExternal) {
                          final url = Uri.parse('https://chinarhomes.com/');
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      backgroundColor: isExternal
                      // 90% opacity via withAlpha
                          ? Colors.red.shade700.withAlpha((0.9 * 255).round())
                          : Colors.transparent,
                      iconColor:   isExternal ? Colors.white : Colors.black,
                      labelColor:  isExternal ? Colors.white : Colors.black,
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
