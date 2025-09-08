// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // for ScrollDirection
import 'package:flutter/services.dart';  // for AnnotatedRegion
import 'package:shared_preferences/shared_preferences.dart';

import '../managers/theme_manager.dart';
import '../managers/color_manager.dart';
import '../widgets/global_body_guard.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/smooth_scroll_behavior.dart';
import '../widgets/title_bar.dart';      // now provides FullTitleBar & MiniTitleBar
import 'permission_request_page.dart';

class HomePage extends StatefulWidget {
  final ThemeManager themeManager;
  final ColorManager  colorManager;

  const HomePage({
    super.key,
    required this.themeManager,
    required this.colorManager,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _fullBarHeight = 224.0;

  late final ScrollController _scrollController;
  bool _barVisible  = true;
  bool _showMiniBar = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFirstLaunch());
  }

  void _onScroll() {
    final dir    = _scrollController.position.userScrollDirection;
    final offset = _scrollController.offset;

    // bottom bar
    if (dir == ScrollDirection.reverse && _barVisible) {
      setState(() => _barVisible = false);
    } else if (dir == ScrollDirection.forward && !_barVisible) {
      setState(() => _barVisible = true);
    }

    // mini‐bar threshold
    final show = offset >= _fullBarHeight;
    if (show != _showMiniBar) {
      setState(() => _showMiniBar = show);
    }
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
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
                    // full header
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      expandedHeight: _fullBarHeight,
                      pinned: false,
                      floating: false,
                      flexibleSpace: FlexibleSpaceBar(
                        background: FullTitleBar(
                          themeManager: widget.themeManager,
                          colorManager: widget.colorManager,
                        ),
                      ),
                    ),

                    // list content
                    SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewPadding.bottom,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (_, i) => ListTile(
                            leading: const Icon(Icons.star),
                            title: Text('Item #$i'),
                          ),
                          childCount: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // overlayed animated mini-bar
              MiniTitleBar(
                themeManager: widget.themeManager,
                colorManager: widget.colorManager,
                isVisible: _showMiniBar,
              ),

              // bottom bar
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingBottomBar(
                  isVisible: _barVisible,
                  onItemSelected: (i) => debugPrint('Tapped $i'),
                  colorManager: widget.colorManager,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
