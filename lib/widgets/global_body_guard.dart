// lib/widgets/global_body_guard.dart
// Locks to portrait, enters edge-to-edge mode (both bars visible),
// and styles only the navigation bar (white bg, dark icons).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlobalBodyGuard extends StatefulWidget {
  final Widget child;
  const GlobalBodyGuard({super.key, required this.child});

  @override
  _GlobalBodyGuardState createState() => _GlobalBodyGuardState();
}

class _GlobalBodyGuardState extends State<GlobalBodyGuard> {
  @override
  void initState() {
    super.initState();

    // 1) Lock orientation to portrait-up
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // 2) Edge-to-edge: content can draw behind status + nav bars,
    //    but both remain visible at all times.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // 3) Only style the NAVIGATION bar here:
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      // Do not set statusBarColor/iconBrightness here.
    ));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
