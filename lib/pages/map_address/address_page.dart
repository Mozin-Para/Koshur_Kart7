import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'address_model.dart';
import 'confirm_delete_dialog.dart';
import 'edit_address_sheet.dart';
import 'map_picker_bottom_sheet.dart';
import 'search_address_page.dart';

class AddressPage extends StatefulWidget {
  final Function(Address)? onDefaultChanged;

  const AddressPage({super.key, this.onDefaultChanged});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage>
    with SingleTickerProviderStateMixin {
  static const _geoApiKey = 'AIzaSyCMOBzGodb2wDkaavr45Hn0DpPT3q-AivI';

  bool _hasPermission = false;
  bool _loadingLocation = false;
  List<Address> _saved = [];

  late final AnimationController _animCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _fadeAnim = CurvedAnimation(
    parent: _animCtrl,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    _loadSaved();
    _checkPermission();
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _saved = Address.listFromPrefs(prefs.getString('saved_addresses')));
  }

  Future<void> _checkPermission() async {
    final st = await Permission.location.status;
    setState(() => _hasPermission = st.isGranted);
  }

  Future<void> _requestPermission() async {
    final st = await Permission.location.request();
    setState(() => _hasPermission = st.isGranted);
  }

  Future<void> _useMyLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final addr = await _reverseGeocode(pos.latitude, pos.longitude);
      if (addr != null) {
        final fullAddr = addr.copyWith(
          type: 'Home',
          state: addr.state.isNotEmpty ? addr.state : 'Jammu And Kashmir',
          country: addr.country.isNotEmpty ? addr.country : 'India',
        );
        await _save(fullAddr, makeDefault: _saved.isEmpty);
        await _loadSaved();
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loadingLocation = false);
    }
  }

  Future<Address?> _reverseGeocode(double lat, double lng) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {'latlng': '$lat,$lng', 'key': _geoApiKey},
    );
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return null;

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (data['status'] != 'OK') return null;

    final best = (data['results'] as List).cast<Map<String, dynamic>>().first;
    final comps = (best['address_components'] as List).cast<Map<String, dynamic>>();

    String pick(String type) {
      return comps
          .firstWhere(
            (c) => (c['types'] as List).contains(type),
        orElse: () => <String, dynamic>{'long_name': ''},
      )['long_name']
          ?.toString() ??
          '';
    }

    final line = best['formatted_address'] as String;
    final sub = pick('sublocality_level_1');
    final city = pick('locality');
    final dist = pick('administrative_area_level_2');
    final state = pick('administrative_area_level_1');
    final country = pick('country');
    final pin = pick('postal_code');

    return Address(
      line: line,
      landmark: sub,
      village: sub,
      city: city,
      district: dist,
      state: state,
      country: country,
      pinCode: pin,
      locationUrl: 'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      latitude: lat,
      longitude: lng,
      type: 'Other',
      isDefault: false,
    );
  }

  Future<void> _save(Address a, {required bool makeDefault}) async {
    final prefs = await SharedPreferences.getInstance();
    var list = Address.listFromPrefs(prefs.getString('saved_addresses'));

    if (makeDefault) {
      list = list.map((x) => x.copyWith(isDefault: false)).toList();
      a = a.copyWith(isDefault: true);
    }

    final idx = list.indexWhere((x) => x.latitude == a.latitude && x.longitude == a.longitude);
    if (idx >= 0) {
      list[idx] = a;
    } else {
      if (list.length >= 3) list.removeAt(0);
      list.add(a);
    }

    await prefs.setString('saved_addresses', Address.toPrefs(list));
  }

  Future<void> _setDefaultAddress(Address address) async {
    await _save(address, makeDefault: true);
    await _loadSaved();
    if (widget.onDefaultChanged != null) {
      widget.onDefaultChanged!(address);
    }
  }

  Future<void> _confirmDelete(Address a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDeleteDialog(address: a),
    );
    if (ok == true) {
      await _delete(a);
    }
  }

  Future<void> _delete(Address a) async {
    final prefs = await SharedPreferences.getInstance();
    var list = Address.listFromPrefs(prefs.getString('saved_addresses'));
    list.removeWhere((x) => x.line == a.line && x.latitude == a.latitude);
    await prefs.setString('saved_addresses', Address.toPrefs(list));
    await _loadSaved();
  }

  Future<void> _openManual([Address? existing]) async {
    final result = await showModalBottomSheet<Address>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditAddressSheet(
        initial: existing ?? Address.empty(),
      ),
    );
    if (result != null) {
      await _save(result, makeDefault: result.isDefault);
      await _loadSaved();
      if (result.isDefault && widget.onDefaultChanged != null) {
        widget.onDefaultChanged!(result);
      }
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<Address>(
      MaterialPageRoute(
        builder: (_) => const MapPickerBottomSheet(),
      ),
    );
    if (result != null) {
      await _save(result, makeDefault: _saved.isEmpty);
      await _loadSaved();
      if (result.isDefault && widget.onDefaultChanged != null) {
        widget.onDefaultChanged!(result);
      }
    }
  }

  Future<void> _openSearch() async {
    final result = await Navigator.of(context).push<Address>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const SearchAddressPage(),
      ),
    );
    if (result != null) {
      await _save(result, makeDefault: _saved.isEmpty);
      await _loadSaved();
      if (result.isDefault && widget.onDefaultChanged != null) {
        widget.onDefaultChanged!(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height * 0.8;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black54,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: h,
          width: w,
          child: Material(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            clipBehavior: Clip.antiAlias,
            color: Colors.white,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_hasPermission) ...[
                        ElevatedButton.icon(
                          onPressed: _requestPermission,
                          icon: const Icon(Icons.location_on),
                          label: const Text('ENABLE LOCATION'),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_hasPermission) ...[
                        ElevatedButton.icon(
                          onPressed: _loadingLocation ? null : _useMyLocation,
                          icon: const Icon(Icons.my_location),
                          label: Text(_loadingLocation
                              ? 'Getting location…'
                              : 'USE MY LOCATION'),
                        ),
                        const SizedBox(height: 12),
                      ],

                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _openManual(),
                              icon: const Icon(Icons.edit_location),
                              label: const Text('Manual'),
                            ),
                            OutlinedButton.icon(
                              onPressed: _openMapPicker,
                              icon: const Icon(Icons.map),
                              label: const Text('Map'),
                            ),
                            OutlinedButton.icon(
                              onPressed: _openSearch,
                              icon: const Icon(Icons.search),
                              label: const Text('Search'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'YOUR SAVED ADDRESSES',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Expanded(
                        child: _saved.isEmpty
                            ? const Center(child: Text('No addresses saved.'))
                            : ListView.builder(
                          itemCount: _saved.length,
                          itemBuilder: (_, i) {
                            final a = _saved[i];
                            return ListTile(
                              leading: Icon(
                                a.isDefault
                                    ? Icons.star
                                    : Icons.star_border,
                                color: a.isDefault
                                    ? Colors.amber
                                    : Colors.grey,
                              ),
                              title: Text(a.line),
                              subtitle: Text('${a.city}, ${a.pinCode}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _openManual(a),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _confirmDelete(a),
                                  ),
                                ],
                              ),
                              onTap: () => _setDefaultAddress(a),
                              onLongPress: () {
                                Clipboard.setData(ClipboardData(text: a.locationUrl))
                                    .then((value) => ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(content: Text('Location URL copied to clipboard'))));
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 30),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}