import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'address_model.dart';

class MapPickerBottomSheet extends StatefulWidget {
  const MapPickerBottomSheet({super.key});

  @override
  State<MapPickerBottomSheet> createState() => _MapPickerBottomSheetState();
}

class _MapPickerBottomSheetState extends State<MapPickerBottomSheet> {
  static const _apiKey = 'AIzaSyCMOBzGodb2wDkaavr45Hn0DpPT3q-AivI';
  LatLng? _pin;
  bool _loading = true;
  late GoogleMapController _mapCtrl;
  LatLng _currentCenter = const LatLng(34.0837, 74.7973);

  @override
  void initState() {
    super.initState();
    _initGps();
  }

  Future<void> _initGps() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _pin = LatLng(pos.latitude, pos.longitude);
        _currentCenter = LatLng(pos.latitude, pos.longitude);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _pin = _currentCenter;
        _loading = false;
      });
    }
  }

  Future<void> _confirm() async {
    if (_pin == null) return;
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'latlng': '${_pin!.latitude},${_pin!.longitude}',
        'key': _apiKey,
      },
    );
    final resp = await http.get(uri);
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (data['status'] != 'OK' || (data['results'] as List).isEmpty) {
      Navigator.pop(context);
      return;
    }

    final best = (data['results'] as List).cast<Map<String, dynamic>>()[0];
    final formatted = best['formatted_address'] as String;
    final comps = (best['address_components'] as List).cast<Map<String, dynamic>>();

    String pick(String type) {
      final c = comps.firstWhere(
            (c) => (c['types'] as List).contains(type),
        orElse: () => <String, dynamic>{'long_name': ''},
      );
      return (c['long_name'] as String).trim();
    }

    final addr = Address(
      line: formatted,
      landmark: pick('sublocality_level_1'),
      village: pick('sublocality_level_1'),
      city: pick('locality'),
      district: pick('administrative_area_level_2'),
      state: pick('administrative_area_level_1'),
      country: pick('country'),
      pinCode: pick('postal_code'),
      locationUrl: 'https://www.google.com/maps/search/?api=1&query=${_pin!.latitude},${_pin!.longitude}',
      latitude: _pin!.latitude,
      longitude: _pin!.longitude,
      type: 'Other',
      isDefault: false,
    );

    Navigator.pop(context, addr);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapCtrl = controller;
  }

  void _setPinToCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _pin = LatLng(pos.latitude, pos.longitude);
      });
      _mapCtrl.animateCamera(
        CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)),
      );
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Location on Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _setPinToCurrentLocation,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pin ?? _currentCenter,
              zoom: 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: _onMapCreated,
            onTap: (position) {
              setState(() {
                _pin = position;
              });
            },
            markers: _pin != null
                ? {
              Marker(
                markerId: const MarkerId('pin_marker'),
                position: _pin!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueYellow),
              )
            }
                : {},
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Location',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _pin != null
                          ? 'Lat: ${_pin!.latitude.toStringAsFixed(6)}, Lng: ${_pin!.longitude.toStringAsFixed(6)}'
                          : 'Tap on the map to select a location',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _pin != null ? _confirm : null,
                        child: const Text('CONFIRM & SAVE LOCATION'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}