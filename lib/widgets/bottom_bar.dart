// lib/widgets/bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../managers/color_manager.dart';  // Provides current accent color/gradient

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
    // Expanded so each item takes equal width.
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
  final ColorManager colorManager;

  const FloatingBottomBar({
    super.key,
    required this.isVisible,
    required this.onItemSelected,
    required this.colorManager,
  });

  @override
  Widget build(BuildContext context) {
    // 1) When the nav bar is shown, MediaQuery.viewPadding.bottom
    //    equals its height. When hidden (gesture mode), it's zero.
    final double navBarHeight = MediaQuery.of(context).viewPadding.bottom;

    // 2) Always pad above that height so the bar floats atop the nav bar.
    final double bottomPadding = navBarHeight;

    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 600),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: SafeArea(
            top: false,
            bottom: false, // manual padding covers bottom inset
            child: AnimatedBuilder(
              animation: colorManager,
              builder: (context, _) {
                // 3) Semi-transparent accent background
                final bgColor = colorManager.currentMaterialColor
                    .shade500
                    .withOpacity(1);

                return Material(
                  color: bgColor,
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
                              ? Colors.red.shade700.withOpacity(0.9)
                              : Colors.transparent,
                          iconColor: isExternal ? Colors.white : Colors.black,
                          labelColor: isExternal ? Colors.white : Colors.black,
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
