// lib/pages/home_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';       // for ScrollDirection
import 'package:flutter/services.dart';       // for AnnotatedRegion
import 'package:provider/provider.dart';      // for context.watch/read
import 'package:shared_preferences/shared_preferences.dart';
import '../managers/theme_manager.dart';
import '../managers/color_manager.dart';
import '../widgets/global_body_guard.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/smooth_scroll_behavior.dart';
import '../widgets/title_bar.dart';
import 'permission_request_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _fullBarHeight = 224.0;
  late final ScrollController _scrollController;
  bool _barVisible    = true;
  bool _showMiniBar   = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFirstLaunch());
  }

  void _onScroll() {
    final dir    = _scrollController.position.userScrollDirection;
    final offset = _scrollController.offset;

    if (dir == ScrollDirection.reverse && _barVisible) {
      setState(() => _barVisible = false);
    } else if (dir == ScrollDirection.forward && !_barVisible) {
      setState(() => _barVisible = true);
    }

    final show = offset >= _fullBarHeight;
    if (show != _showMiniBar) {
      setState(() => _showMiniBar = show);
    }
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance(); // line no 56
    final first = prefs.getBool('firstLaunch') ?? true;
    if (first) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PermissionRequestPage()),
      );
      await prefs.setBool('firstLaunch', false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read managers from Provider
    final themeMode = context.watch<ThemeManager>().themeMode;
    final color     = context.watch<ColorManager>().currentMaterialColor;

    // Choose the correct overlay style for light vs dark
    final overlay = (themeMode == ThemeMode.light)
        ? SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: Colors.white)
        : SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarColor: Colors.black);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: GlobalBodyGuard(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          body: Stack(
            children: [
              ScrollConfiguration(
                behavior: SmoothScrollBehavior(),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Full‐height header with your FullTitleBar
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      expandedHeight: _fullBarHeight,
                      pinned: false,
                      flexibleSpace: const FlexibleSpaceBar(
                        background: FullTitleBar(),   // line no 106
                      ),
                    ),

                    // Main list content
                    SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewPadding.bottom,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (_, i) => ListTile(
                            leading: Icon(Icons.star, color: color),
                            title: Text('Item #$i'),
                          ),
                          childCount: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Your floating mini‐bar that appears after scrolling
              MiniTitleBar(isVisible: _showMiniBar),    // line no 130

              // Bottom navigation / action bar
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingBottomBar(   // line no 135
                  isVisible: _barVisible,
                  onItemSelected: (i) => debugPrint('Tapped $i'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
