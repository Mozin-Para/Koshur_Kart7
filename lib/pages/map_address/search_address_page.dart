import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'address_model.dart';

class SearchAddressPage extends StatefulWidget {
  const SearchAddressPage({super.key});
  @override
  State<SearchAddressPage> createState() =>
      _SearchAddressPageState();
}

class _SearchAddressPageState extends State<SearchAddressPage> {
  static const _placesKey = 'AIzaSyCMOBzGodb2wDkaavr45Hn0DpPT3q-AivI';
  final _ctrl = TextEditingController();
  List<Map<String, dynamic>> _preds = [];
  bool _loading = false;
  Map<String, dynamic>? _selectedPrediction;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onSearchChanged);
  }

  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _onChanged(_ctrl.text);
      }
    });
  }

  Future<void> _onChanged(String input) async {
    if (!mounted) return;

    if (input.trim().isEmpty) {
      setState(() {
        _preds = [];
        _selectedPrediction = null;
      });
      return;
    }
    setState(() => _loading = true);

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': input,
        'types': 'address',
        'components': 'country:IN',
        'location': '34.0837,74.7973',
        'radius': '50000',
        'key': _placesKey,
      },
    );

    try {
      final resp = await http.get(uri);
      if (!mounted) return;

      final body = jsonDecode(resp.body) as Map<String, dynamic>;

      setState(() {
        _preds = (body['status'] == 'OK')
            ? (body['predictions'] as List)
            .cast<Map<String, dynamic>>()
            : [];
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _select(Map<String, dynamic> p) async {
    if (!mounted) return;
    setState(() => _selectedPrediction = p);
  }

  Future<void> _confirmSelection() async {
    if (_selectedPrediction == null || !mounted) return;

    setState(() => _loading = true);

    final placeId = _selectedPrediction!['place_id'] as String;
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {
        'place_id': placeId,
        'fields': 'formatted_address,geometry,address_components',
        'key': _placesKey,
      },
    );

    try {
      final resp = await http.get(uri);
      if (!mounted) return;

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (body['status'] != 'OK') return;

      final r = body['result'] as Map<String, dynamic>;
      final loc = (r['geometry']['location'] as Map)
          .cast<String, dynamic>();
      final lat = (loc['lat'] as num).toDouble();
      final lng = (loc['lng'] as num).toDouble();
      final line = r['formatted_address'] as String;

      final comps = (r['address_components'] as List)
          .cast<Map<String, dynamic>>();
      String pick(String type) {
        final c = comps.firstWhere(
              (c) => (c['types'] as List).contains(type),
          orElse: () => <String, dynamic>{'long_name': ''},
        );
        return (c['long_name'] as String).trim();
      }

      final addr = Address(
        line:        line,
        landmark:    pick('sublocality_level_1'),
        village:     pick('sublocality_level_1'),
        city:        pick('locality'),
        district:    pick('administrative_area_level_2'),
        state:       pick('administrative_area_level_1'),
        country:     pick('country'),
        pinCode:     pick('postal_code'),
        locationUrl:
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
        latitude:    lat,
        longitude:   lng,
        type:        'Other',
        isDefault:   false,
      );

      if (mounted) {
        Navigator.pop(context, addr);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.removeListener(_onSearchChanged);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Address'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search for any location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _ctrl.clear();
                    if (mounted) {
                      setState(() {
                        _preds = [];
                        _selectedPrediction = null;
                      });
                    }
                  },
                )
                    : null,
              ),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: _preds.isEmpty
                ? Center(
              child: _ctrl.text.isEmpty
                  ? const Text('Start typing to search for locations')
                  : const Text('No results found'),
            )
                : ListView.builder(
              itemCount: _preds.length,
              itemBuilder: (_, i) {
                final p = _preds[i];
                final isSelected = _selectedPrediction == p;
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(p['description'] as String),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  tileColor: isSelected ? Colors.grey[100] : null,
                  onTap: () => _select(p),
                );
              },
            ),
          ),
          if (_selectedPrediction != null)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _confirmSelection,
                    child: const Text('CONFIRM & SAVE'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}