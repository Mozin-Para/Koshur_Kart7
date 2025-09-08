// lib/widgets/smooth_scroll_behavior.dart

import 'package:flutter/material.dart';

class SmoothScrollBehavior extends MaterialScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    final plat = Theme.of(context).platform;
    if (plat == TargetPlatform.iOS || plat == TargetPlatform.macOS) {
      return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
    }
    return const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}
