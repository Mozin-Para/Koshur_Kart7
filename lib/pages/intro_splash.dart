// lib/pages/profile/intro_splash.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/typing_text.dart';
import 'home_page.dart';

class IntroSplash extends StatefulWidget {
  final Duration initialDelay;
  final Duration stepDelay;
  final Duration totalDelay;

  const IntroSplash({
    super.key,
    this.initialDelay = const Duration(milliseconds: 700),
    this.stepDelay = const Duration(milliseconds: 400),
    this.totalDelay = const Duration(seconds: 3),
  });

  @override
  State<IntroSplash> createState() => _IntroSplashState();
}

class _IntroSplashState extends State<IntroSplash>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  bool _showTitle = false;
  bool _showFast = false;
  bool _showXYZ = false;
  bool _showMoraf = false;
  final List<Timer> _timers = [];
  final List<_IconParticle> _particles = [];
  static const List<IconData> _iconOptions = [
    Icons.favorite,
    Icons.favorite,
    Icons.shopping_cart,
    Icons.fastfood,
    Icons.cake,
    Icons.local_cafe,
    Icons.phone_android,
    Icons.headphones,
  ];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFFFCC17),
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFFCC17),
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    _scheduleSequence();

    _timers.add(Timer(widget.totalDelay, () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    }));
  }

  void _scheduleSequence() {
    _timers.add(Timer(widget.initialDelay, () {
      if (!mounted) return;
      setState(() => _showTitle = true);
      _slideController.forward();

      _timers.add(Timer(widget.stepDelay, () {
        if (!mounted) return;
        setState(() => _showFast = true);
      }));

      _timers.add(Timer(widget.stepDelay * 2, () {
        if (!mounted) return;
        setState(() => _showXYZ = true);
      }));

      _timers.add(Timer(widget.stepDelay * 3, () {
        if (!mounted) return;
        setState(() => _showMoraf = true);
      }));
    }));
  }

  void _spawnParticle(Offset pos) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    final scaleAnim = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    final offsetAnim = Tween<double>(begin: 0, end: -300).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    final opacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );

    final icon = _iconOptions[_rnd.nextInt(_iconOptions.length)];

    final particle = _IconParticle(
      key: UniqueKey(),
      position: pos,
      icon: icon,
      controller: controller,
      scale: scaleAnim,
      offset: offsetAnim,
      opacity: opacityAnim,
    );

    setState(() => _particles.add(particle));
    controller.forward();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        if (mounted) {
          setState(() => _particles.removeWhere((p) => p.key == particle.key));
        }
      }
    });
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _slideController.dispose();
    for (final p in _particles) {
      p.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFFFCC17);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (details) => _spawnParticle(details.localPosition),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TypingText(
                      text: 'I ❤️ Kashmir',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_showTitle)
                      SlideTransition(
                        position: _slideAnimation,
                        child: const Text(
                          'Koshur Kart',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    if (_showFast)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Instant Delivery Service',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ),
                    if (_showXYZ)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          '.Simple .Fast .You Believe it',
                          style: TextStyle(fontSize: 13, color: Colors.black),
                        ),
                      ),
                  ],
                ),
              ),

              if (_showMoraf)
                const Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Text(
                    'SOFTWALLET ALGORITHM TECHNOLOGIES © 2019',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),

              for (final p in _particles)
                Positioned(
                  key: p.key,
                  left: p.position.dx - 40,
                  top: p.position.dy - 40 + p.offset.value,
                  child: AnimatedBuilder(
                    animation: p.controller,
                    builder: (_, __) => Opacity(
                      opacity: p.opacity.value,
                      child: Transform.scale(
                        scale: p.scale.value,
                        child: Icon(
                          p.icon,
                          size: 80,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconParticle {
  final Key key;
  final Offset position;
  final IconData icon;
  final AnimationController controller;
  final Animation<double> scale;
  final Animation<double> offset;
  final Animation<double> opacity;

  _IconParticle({
    required this.key,
    required this.position,
    required this.icon,
    required this.controller,
    required this.scale,
    required this.offset,
    required this.opacity,
  });
}