// lib/widgets/typing_text.dart
// A widget that types out a given string character by character,
// then continuously appends up to three trailing dots in a loop,
// and cleans up all timers on disposal to prevent memory leaks.

import 'package:flutter/material.dart';  // Provides core Flutter widgets and TextStyle.
import 'dart:async';                     // Provides Timer and Timer.periodic for animations.

/// A StatefulWidget that types out [text] with a typing animation
/// and then shows looping dots ("", ".", "..", "...") after the text.
class TypingText extends StatefulWidget {
  /// The full text string to reveal one character at a time.
  final String text;

  /// The TextStyle to apply to the displayed characters and dots.
  final TextStyle style;

  /// The interval between each character being appended.
  /// Defaults to 100 milliseconds if not specified.
  final Duration speed;

  /// Constructor for TypingText.
  /// - [key] is forwarded to the superclass for widget identity.
  /// - [text] is required: the string to animate.
  /// - [style] is required: how the text should look.
  /// - [speed] is optional: how quickly each character appears.
  const TypingText({
    super.key,
    required this.text,
    required this.style,
    this.speed = const Duration(milliseconds: 100),
  });

  @override
  State<TypingText> createState() => _TypingTextState();
}

/// Private State class that manages the typing and dots timers.
class _TypingTextState extends State<TypingText> {
  /// The portion of [widget.text] that has already been typed and displayed.
  String _displayedText = '';

  /// The next index in [widget.text] to type when the timer ticks.
  int _index = 0;

  /// The current trailing dots string, cycles from "" to "..." repeatedly.
  String _dots = '';

  /// Timer that fires every [widget.speed] to append one character.
  Timer? _typingTimer;

  /// Timer that fires every 500ms to update the trailing dots.
  Timer? _dotsTimer;

  @override
  void initState() {
    super.initState();  // Always call super.initState() first.
    _startTyping();     // Kick off the character typing animation.
    _startDots();       // Kick off the trailing dots animation.
  }

  /// Starts a periodic timer that appends one character at a time.
  void _startTyping() {
    _typingTimer = Timer.periodic(widget.speed, (timer) {
      // If there are still characters left in the text...
      if (_index < widget.text.length) {
        setState(() {
          // Append the character at the current index.
          _displayedText += widget.text[_index];
          // Move to the next character for the next tick.
          _index++;
        });
      } else {
        // All characters have been typed: cancel the typing timer.
        timer.cancel();
      }
    });
  }

  /// Starts a periodic timer that loops the trailing dots from "" to "..."
  void _startDots() {
    _dotsTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        // If fewer than 3 dots, add one more; otherwise reset to empty.
        _dots = (_dots.length < 3) ? '$_dots.' : '';
      });
    });
  }

  @override
  void dispose() {
    // Cancel the typing timer if still active, preventing leaks.
    _typingTimer?.cancel();
    // Cancel the dots timer if still active, preventing leaks.
    _dotsTimer?.cancel();
    super.dispose();    // Always call super.dispose() last.
  }

  @override
  Widget build(BuildContext context) {
    // Combine the typed text and the animated dots into a single Text widget.
    return Text(
      '$_displayedText$_dots',   // Display the current text plus dots.
      style: widget.style,       // Apply the passed-in TextStyle.
      textAlign: TextAlign.center, // Center the text horizontally.
    );
  }
}
