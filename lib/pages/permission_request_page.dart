// lib/pages/permission_request_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionRequestPage extends StatefulWidget {
  const PermissionRequestPage({super.key});

  @override
  State<PermissionRequestPage> createState() => _PermissionRequestPageState();
}

class _PermissionRequestPageState extends State<PermissionRequestPage> {
  /// All permissions we ask on very first run.
  final Map<Permission, String> _allPermNames = {
    Permission.location:        'Location',
    if (Platform.isAndroid) Permission.notification: 'Notifications',
    Permission.camera:          'Camera',
    Permission.microphone:      'Microphone',
    Permission.contacts:        'Contacts',
  };

  /// Only these two on every subsequent open.
  final Map<Permission, String> _essentialPermNames = {
    Permission.location:        'Location',
    if (Platform.isAndroid) Permission.notification: 'Notifications',
  };

  bool _isFirstLaunch = true;
  Map<Permission, PermissionStatus> _statuses = {};

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // 1) Read first‐launch flag
    final prefs = await SharedPreferences.getInstance();
    final first = prefs.getBool('firstLaunch') ?? true;

    // 2) Load current status for all perms
    final result = <Permission, PermissionStatus>{};
    for (final perm in _allPermNames.keys) {
      result[perm] = await perm.status;
    }

    // 3) Update state
    setState(() {
      _isFirstLaunch = first;
      _statuses      = result;
    });

    // 4) After build, request OS dialogs
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final toRequest = _isFirstLaunch
          ? _allPermNames.keys
          : _essentialPermNames.keys.where((p) =>
      _statuses[p] != PermissionStatus.granted
      );
      for (final perm in toRequest) {
        await _requestPermission(perm);
      }
    });
  }

  Future<void> _requestPermission(Permission perm) async {
    final status = await perm.request();
    setState(() => _statuses[perm] = status);
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstLaunch', false);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Choose which map to render
    final permNames = _isFirstLaunch
        ? _allPermNames
        : _essentialPermNames;

    return Scaffold(
      appBar: AppBar(title: const Text('Permissions Setup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _isFirstLaunch
                ? 'Please grant all permissions for the best app experience.'
                : 'Checking Location & Notifications each time; others skipped.',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),

          // Permission tiles
          for (final entry in permNames.entries)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(entry.value),
                subtitle: Text(
                  _statuses[entry.key]
                      ?.toString()
                      .split('.')
                      .last
                      .toUpperCase() ??
                      'UNKNOWN',
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,       // red background
                  foregroundColor: Colors.white,     // white text/icon
                ),
                  onPressed: () => _requestPermission(entry.key),
                  child: const Text('Allow'),
                ),
              ),
            ),

          const SizedBox(height: 30),

          // Continue button
          ElevatedButton(style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,       // red background
            foregroundColor: Colors.white,     // white text/icon
          ),
            onPressed: _finish,
            child: const Text('Continue to App'),
          ),
        ],
      ),
    );
  }
}
