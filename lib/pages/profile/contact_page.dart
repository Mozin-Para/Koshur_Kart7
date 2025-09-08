// lib/pages/profile/contact_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../managers/theme_manager.dart';
import '../../managers/color_manager.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeMgr = context.watch<ThemeManager>();
    final colorMgr = context.watch<ColorManager>();

    final accent      = colorMgr.currentMaterialColor.shade500;
    final isLightMode = themeMgr.themeMode == ThemeMode.light;
    final textColor   = isLightMode ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: accent,
        iconTheme: IconThemeData(color: textColor),
        title: Text('Contact Us', style: TextStyle(color: textColor)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('support@koshurkart.com',
                style: TextStyle(fontSize: 16, color: accent)),
            const SizedBox(height: 16),
            Text('Phone:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('+91 96224 24392',
                style: TextStyle(fontSize: 16, color: accent)),
            const SizedBox(height: 32),
            Text('Address:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('123 Koshur Kart Lane\nSrinagar, Jammu & Kashmir',
                style: TextStyle(fontSize: 16, color: accent)),
          ],
        ),
      ),
    );
  }
}
