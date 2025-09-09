// lib/widgets/refer_and_earn_msg.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows a dialog prompting the user to share the app and earn coins.
/// Replaces the previous animation with a looping GIF asset.
Future<void> showReferAndEarnMsgDialog(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'ReferAndEarn',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (ctx, anim1, anim2) {
      return SafeArea(
        child: Center(
          child: _ReferAndEarnDialogContent(),
        ),
      );
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
          reverseCurve: Curves.easeOut,
        ),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

class _ReferAndEarnDialogContent extends StatelessWidget {
  const _ReferAndEarnDialogContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final surface   = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main dialog container
          Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Looping coin GIF
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Image.asset(
                    'assets/coin.gif',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  'Share & Earn!',
                  style:
                  theme.textTheme.titleLarge?.copyWith(color: onSurface),
                ),

                const SizedBox(height: 8),

                // Message
                Text(
                  'Share this app & earn 99 coins after user apply your redam code in app.',
                  textAlign: TextAlign.center,
                  style:
                  theme.textTheme.bodyMedium?.copyWith(color: onSurface),
                ),

                const SizedBox(height: 24),

                // Share button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Share Now'),
                    onPressed: () async {
                      // Capture the messenger **before** any awaits
                      final messenger = ScaffoldMessenger.of(context);
                      final uri = Uri.parse('https://chinarhomes.com/');

                      final canLaunch = await canLaunchUrl(uri);
                      if (canLaunch) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Could not launch link'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Close (X) button
          Positioned(
            top: -10,
            right: -10,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                decoration: BoxDecoration(
                  color: surface,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.close,
                  size: 22,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
