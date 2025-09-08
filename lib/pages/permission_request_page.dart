// lib/pages/permission_request_page.dart
// First-launch screen that:
//  • Lists all required permissions with their current OS status
//  • Lets the user tap “Grant” to invoke the native Allow/Deny popup
//  • Tracks which permissions are granted/denied
//  • Includes a Continue button that always returns to HomePage
//    while clearing the firstLaunch flag so this screen shows only once

import 'dart:io';                              // To detect the current platform (Android vs iOS)
import 'package:flutter/material.dart';        // Core Flutter UI widgets
import 'package:permission_handler/permission_handler.dart'; // OS-level permission APIs
import 'package:shared_preferences/shared_preferences.dart'; // Persisting simple key/value pairs

/// A stateful page that drives the OS permission dialogs one by one.
class PermissionRequestPage extends StatefulWidget {
  /// Default constructor forwards the optional Key to super.
  const PermissionRequestPage({super.key});

  @override
  State<PermissionRequestPage> createState() => _PermissionRequestPageState();
}

class _PermissionRequestPageState extends State<PermissionRequestPage> {
  /// 1) Maps each Permission enum to a human-readable label.
  ///    On Android, we include POST_NOTIFICATIONS only if the platform is Android.
  final Map<Permission, String> _permNames = {
    Permission.location:      'Location',
    if (Platform.isAndroid) Permission.notification: 'Notifications',
    Permission.camera:        'Camera',
    Permission.microphone:    'Microphone',
    Permission.contacts:      'Contacts',
  };

  /// 2) Holds the latest PermissionStatus for each permission in `_permNames`.
  ///    Initialized empty; filled by `_loadStatuses()` on init.
  Map<Permission, PermissionStatus> _statuses = {};

  @override
  void initState() {
    super.initState();
    // 3) When this widget first appears, load each permission’s current status.
    _loadStatuses();
  }

  /// 4) Asynchronously queries the OS for the current status of each permission.
  ///    Populates `_statuses` and triggers a rebuild.
  Future<void> _loadStatuses() async {
    final Map<Permission, PermissionStatus> result = {};
    // 4a) Loop through every permission key
    for (final perm in _permNames.keys) {
      // 4b) Ask the plugin for the current status (granted, denied, etc.)
      result[perm] = await perm.status;
    }
    // 4c) Update state so UI shows the latest statuses under each ListTile
    setState(() => _statuses = result);
  }

  /// 5) Invoked when the user taps “Grant” for a specific permission.
  ///    Requests the OS dialog and then reloads that permission’s status.
  Future<void> _request(Permission perm) async {
    // 5a) Fire the native popup (Allow / Deny)
    final status = await perm.request();
    // 5b) Store the new status locally so the subtitle updates
    setState(() => _statuses[perm] = status);
  }

  /// 6) Called when the user taps “Continue to App” at the bottom.
  ///    Marks firstLaunch=false so this screen never reappears,
  ///    then pops back to the HomePage.
  Future<void> _finish() async {
    // 6a) Obtain the SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();
    // 6b) Persist that we've completed the first-run permission setup
    await prefs.setBool('firstLaunch', false);
    // 6c) Navigate back (pop) to HomePage
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 7) Standard AppBar with a title
      appBar: AppBar(title: const Text('Permissions Setup')),
      // 8) ListView with padding: intro text, permission tiles, Continue button
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 9) Introductory description
          const Text(
            'To get the best experience, please grant these permissions. '
                'You can skip any—you’ll still enter the app.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),

          // 10) Build a Card + ListTile for each permission in our map
          for (final entry in _permNames.entries)
            Card(
              child: ListTile(
                // 10a) Display the permission label (e.g., “Camera”)
                title: Text(entry.value),
                // 10b) Show the current status (granted, denied, etc.)
                subtitle: Text(
                  _statuses[entry.key]
                      ?.toString()
                      .split('.')
                      .last           // Converts PermissionStatus.granted → "granted"
                      ?? 'Unknown',      // Fallback if status isn’t loaded yet
                ),
                // 10c) “Grant” button to trigger the OS popup for this permission
                trailing: ElevatedButton(
                  onPressed: () => _request(entry.key),
                  child: const Text('Grant'),
                ),
              ),
            ),

          const SizedBox(height: 30),

          // 11) A Continue button that always returns to HomePage
          ElevatedButton(
            onPressed: _finish,
            child: const Text('Continue to App'),
          ),
        ],
      ),
    );
  }
}
