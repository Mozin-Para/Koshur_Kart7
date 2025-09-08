// Import necessary Dart and Flutter packages.
import 'dart:async'; // Enables use of asynchronous programming features like Timer.
import 'dart:math'; // Provides mathematical functions and a Random number generator.
import 'package:flutter/material.dart'; // Core Flutter framework widgets and utilities.
import 'package:flutter/services.dart'; // Allows interaction with platform services like SystemChrome for UI styling.

// Import custom widgets and managers from your project.
import '../widgets/typing_text.dart'; // Custom widget for text that appears to be typed out.
import '../managers/theme_manager.dart'; // Manages the application's theme (light/dark mode).
import '../managers/color_manager.dart'; // Manages the application's color scheme.
import 'home_page.dart'; // The screen to navigate to after the splash screen.

// Define the IntroSplash widget, which is a StatefulWidget because its appearance will change over time.
class IntroSplash extends StatefulWidget {
  // Declare final fields for dependencies that are passed to this widget.
  final ThemeManager themeManager; // Manages the theme for the app.
  final ColorManager colorManager; // Manages the color scheme for the app.

  // Declare final fields for controlling animation timings.
  final Duration initialDelay; // How long to wait before the first animation starts.
  final Duration stepDelay; // The delay between subsequent animation steps (e.g., revealing subtitles).
  final Duration totalDelay; // The total duration the splash screen will be visible before navigating away.

  // Constructor for the IntroSplash widget.
  const IntroSplash({
    super.key, // Optional key for widget identification and state preservation.
    required this.themeManager, // ThemeManager is required.
    required this.colorManager, // ColorManager is required.
    // Default values for delays if not provided when the widget is created.
    this.initialDelay = const Duration(milliseconds: 700), // Default initial delay of 700ms.
    this.stepDelay    = const Duration(milliseconds: 400), // Default step delay of 400ms.
    this.totalDelay   = const Duration(seconds: 3),      // Default total delay of 3 seconds.
  }); // Call the constructor of the parent class (StatefulWidget).

  // Creates the mutable state for this widget.
  @override
  State<IntroSplash> createState() => _IntroSplashState();
}

// Define the state class for the IntroSplash widget.
// It uses TickerProviderStateMixin to provide Ticker objects for animations.
class _IntroSplashState extends State<IntroSplash>
    with TickerProviderStateMixin {
  // Animation controller for the slide-in animation of the title.
  late final AnimationController _slideController; // Declared as late, will be initialized in initState.
  // Animation object that defines the offset values for the slide animation.
  late final Animation<Offset> _slideAnimation; // Declared as late, will be initialized in initState.

  // Boolean flags to control the visibility of different text elements on the screen.
  bool _showTitle = false; // True if the main title ("Koshur Kart") should be visible.
  bool _showFast  = false; // True if the first subtitle ("Instant Delivery Service") should be visible.
  bool _showXYZ   = false; // True if the second subtitle (".Simple .Fast .You Believe it") should be visible.
  bool _showMoraf = false; // True if the copyright text at the bottom should be visible.

  // A list to keep track of active Timer objects.
  // This allows them to be cancelled when the widget is disposed to prevent memory leaks.
  final List<Timer> _timers = [];

  // A list to store and manage the animated icon particles that appear on tap.
  final List<_IconParticle> _particles = [];

  // A static constant list of IconData to choose from when spawning particles.
  // 'static const' means this list is created once and shared among all instances of _IntroSplashState.
  static const List<IconData> _iconOptions = [
    Icons.favorite,      // A heart icon.
    Icons.favorite,      // Another heart icon (increases its chances of being picked).
    Icons.shopping_cart, // A shopping cart icon.
    Icons.fastfood,      // A fast food icon.
    Icons.cake,          // A cake icon.
    Icons.local_cafe,    // A coffee cup icon.
    Icons.phone_android, // An Android phone icon.
    Icons.headphones,    // Headphones icon.
  ];

  // An instance of the Random class to randomly select icons from _iconOptions.
  final Random _rnd = Random();

  // Called once when the widget is inserted into the widget tree.
  @override
  void initState() {
    super.initState(); // Always call super.initState() first.

    // Configure the system UI overlay style (status bar and navigation bar).
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFFFCC17),             // Set status bar background color.
      statusBarIconBrightness: Brightness.dark,      // Set status bar icons to dark.
      systemNavigationBarColor: Color(0xFFFFCC17),    // Set navigation bar background color.
      systemNavigationBarIconBrightness: Brightness.dark, // Set navigation bar icons to dark.
    ));

    // Initialize the AnimationController for the title's slide animation.
    _slideController = AnimationController(
      vsync: this, // `this` provides the TickerProvider.
      duration: const Duration(milliseconds: 800), // Animation duration of 800ms.
    );
    // Initialize the Animation<Offset> for the slide.
    // It tweens (interpolates) between an offset that starts off-screen to the left and an offset of zero (center).
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0), // Start 1.5 times its width to the left.
      end: Offset.zero,             // End at its natural position.
    ).animate(
      // Apply a curved animation to make the slide feel more natural (eases out).
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    // Schedule the sequence of text animations (title, subtitles, credit).
    _scheduleSequence();

    // Schedule the navigation to the HomePage after the totalDelay.
    _timers.add(Timer(widget.totalDelay, () {
      // Before navigating, check if the widget is still mounted (i.e., part of the widget tree).
      if (!mounted) return; // If not mounted, do nothing to avoid errors.
      // Replace the current screen (splash screen) with the HomePage.
      Navigator.pushReplacement(
        context, // The build context for navigation.
        MaterialPageRoute(
          // Define the builder for the new route (HomePage).
          builder: (_) => HomePage(
            // Pass the required theme and color managers to the HomePage.
            themeManager: widget.themeManager,
            colorManager: widget.colorManager,
          ),
        ),
      );
    }));
  }

  // Method to schedule the staggered appearance of text elements.
  void _scheduleSequence() {
    // Start the first timer, which will trigger after `widget.initialDelay`.
    _timers.add(Timer(widget.initialDelay, () {
      if (!mounted) return; // Check if mounted before updating state.
      // Update state to show the title and start its slide animation.
      setState(() => _showTitle = true);
      _slideController.forward(); // Start the slide-in animation.

      // Schedule the first subtitle to appear after `widget.stepDelay`.
      _timers.add(Timer(widget.stepDelay, () {
        if (!mounted) return; // Check if mounted.
        setState(() => _showFast = true); // Update state to show the first subtitle.
      }));

      // Schedule the second subtitle to appear after `widget.stepDelay * 2`.
      _timers.add(Timer(widget.stepDelay * 2, () {
        if (!mounted) return; // Check if mounted.
        setState(() => _showXYZ = true); // Update state to show the second subtitle.
      }));

      // Schedule the copyright credit to appear after `widget.stepDelay * 3`.
      _timers.add(Timer(widget.stepDelay * 3, () {
        if (!mounted) return; // Check if mounted.
        setState(() => _showMoraf = true); // Update state to show the copyright credit.
      }));
    }));
  }

  // Method to create and animate an icon particle when the screen is tapped.
  void _spawnParticle(Offset pos) { // `pos` is the local position of the tap.
    // Create an AnimationController for the particle's animations.
    final controller = AnimationController(
      vsync: this, // `this` provides the TickerProvider.
      duration: const Duration(milliseconds: 2000), // Particle animation duration of 2 seconds.
    );

    // Define the scale animation for the particle (pop-in effect).
    final scaleAnim = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: controller, // Link to the particle's controller.
        // Interval defines that this animation happens in the first 25% of the controller's duration.
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    // Define the offset animation for the particle (floating upwards).
    final offsetAnim = Tween<double>(begin: 0, end: -300).animate(
      // Animates over the full duration of the controller.
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    // Define the opacity animation for the particle (fading out).
    final opacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      // Animates over the full duration of the controller.
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );

    // Select a random icon from the predefined list.
    final icon = _iconOptions[_rnd.nextInt(_iconOptions.length)];

    // Create an instance of the _IconParticle data class.
    final particle = _IconParticle(
      key: UniqueKey(),        // Generate a unique key for widget identification.
      position: pos,           // Store the tap position.
      icon: icon,              // Store the selected icon.
      controller: controller,  // Store the animation controller for this particle.
      scale: scaleAnim,        // Store the scale animation.
      offset: offsetAnim,      // Store the offset animation.
      opacity: opacityAnim,    // Store the opacity animation.
    );

    // Add the new particle to the list and update the state to trigger a rebuild.
    setState(() => _particles.add(particle));
    controller.forward(); // Start the particle's animations.

    // Add a listener to the particle's animation controller.
    // This is used to clean up the particle when its animation completes.
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) { // If animation is done:
        controller.dispose(); // Dispose the controller to free resources.
        // Remove the particle from the list, identifying it by its unique key.
        // This also triggers a rebuild to remove it from the screen.
        if (mounted) { // Check if widget is still in the tree
          setState(() => _particles.removeWhere((p) => p.key == particle.key));
        }
      }
    });
  }

  // Called when this widget is removed from the widget tree.
  @override
  void dispose() {
    // Cancel all active timers to prevent them from firing after the widget is disposed.
    for (final t in _timers) {
      t.cancel();
    }
    // Dispose the slide animation controller to free its resources.
    _slideController.dispose();
    // Dispose all animation controllers for any active particles.
    for (final p in _particles) {
      p.controller.dispose();
    }
    super.dispose(); // Always call super.dispose() last.
  }

  // Describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    // Define the background color for the splash screen.
    const Color bgColor = Color(0xFFFFCC17);

    // Return a Scaffold widget, which provides a basic visual structure.
    return Scaffold(
      backgroundColor: bgColor, // Set the background color of the Scaffold.
      // Use SafeArea to ensure content is not obscured by system intrusions (like notches or status bars).
      body: SafeArea(
        // Use GestureDetector to detect taps on the screen.
        child: GestureDetector(
          behavior: HitTestBehavior.translucent, // Allows taps on transparent areas of the Stack.
          // When a tap down event occurs, call _spawnParticle with the local tap position.
          onTapDown: (details) => _spawnParticle(details.localPosition),
          // Use a Stack widget to layer multiple widgets on top of each other.
          child: Stack(
            children: [
              // Center the main column of text content.
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Column should only be as tall as its children.
                  children: [
                    // The "I ❤️ Kashmir" text with typing animation.
                    const TypingText(
                      text: 'I ❤️ Kashmir',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    // A SizedBox to add vertical spacing.
                    const SizedBox(height: 20),
                    // Conditionally display the "Koshur Kart" title if _showTitle is true.
                    if (_showTitle)
                      SlideTransition(
                        position: _slideAnimation, // Apply the slide animation.
                        child: const Text(
                          'Koshur Kart',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    // Conditionally display the first subtitle if _showFast is true.
                    if (_showFast)
                      const Padding(
                        padding: EdgeInsets.only(top: 8), // Add padding above the text.
                        child: Text(
                          'Instant Delivery Service',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ),
                    // Conditionally display the second subtitle if _showXYZ is true.
                    if (_showXYZ)
                      const Padding(
                        padding: EdgeInsets.only(top: 8), // Add padding above the text.
                        child: Text(
                          '.Simple .Fast .You Believe it',
                          style: TextStyle(fontSize: 13, color: Colors.black),
                        ),
                      ),
                  ],
                ),
              ),

              // Conditionally display the copyright credit at the bottom if _showMoraf is true.
              if (_showMoraf)
                const Positioned(
                  bottom: 16, // Position 16 pixels from the bottom.
                  left: 0,    // Align to the left edge.
                  right: 0,   // Align to the right edge (centers the text due to TextAlign.center).
                  child: Text(
                    'SOFTWALLET ALGORITHM TECHNOLOGIES © 2019',
                    textAlign: TextAlign.center, // Center the text horizontally.
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),

              // Iterate over the list of active particles and render each one.
              for (final p in _particles)
                Positioned(
                  key: p.key, // Use the particle's unique key.
                  // Calculate the left position to center the 80px icon over the tap.
                  // The icon's origin is top-left, so subtract half its width (40).
                  left: p.position.dx - 40,
                  // Calculate the top position, applying the animated offset.
                  // Subtract half its height (40) and add the current animated offset value.
                  top: p.position.dy - 40 + p.offset.value,
                  // Use AnimatedBuilder to rebuild the icon when its animations change.
                  child: AnimatedBuilder(
                    animation: p.controller, // Listen to the particle's animation controller.
                    builder: (_, __) => Opacity( // Apply the opacity animation.
                      opacity: p.opacity.value, // Get current opacity from animation.
                      child: Transform.scale(   // Apply the scale animation.
                        scale: p.scale.value,   // Get current scale from animation.
                        child: Icon(
                          p.icon,            // The specific icon for this particle.
                          size: 80,            // Fixed size for the icon.
                          color: Colors.redAccent, // Fixed color for the icon.
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

// A simple data class to hold information and animations for a single icon particle.
class _IconParticle {
  final Key key;                      // Unique identifier for the particle.
  final Offset position;               // Original tap position where the particle spawns.
  final IconData icon;                 // The icon to display for this particle.
  final AnimationController controller;  // Controls all animations for this particle.
  final Animation<double> scale;        // Animation for scaling (pop-in effect).
  final Animation<double> offset;       // Animation for vertical offset (floating effect).
  final Animation<double> opacity;      // Animation for opacity (fade-out effect).

  // Constructor for _IconParticle.
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
