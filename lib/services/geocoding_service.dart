import 'dart:convert';
import 'package:http/http.dart' as http;

/// A tiny HTTP‐based service to get the full street-number address.
class GeocodingService {
  GeocodingService(this.apiKey);
  final String apiKey;

  /// Returns a full address line (street number, street name, neighborhood…)
  /// or null if the API fails.
  Future<String?> getFullAddress({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'latlng': '$latitude,$longitude',
        'key': apiKey,
      },
    );
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return null;
    final data = jsonDecode(resp.body) as Map<String, dynamic>;

    if (data['status'] != 'OK') return null;
    final results = data['results'] as List<dynamic>;

    if (results.isEmpty) return null;
    // 1) Prefer the most precise result
    final best = results.firstWhere(
          (r) {
        final types = (r['types'] as List<dynamic>).cast<String>();
        return types.contains('street_address') ||
            types.contains('premise') ||
            types.contains('subpremise');
      },
      orElse: () => results[0],
    ) as Map<String, dynamic>;

    // 2) Walk the address_components
    final comps = (best['address_components'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    String pick(String type) {
      final comp = comps.firstWhere(
            (c) => (c['types'] as List<dynamic>).contains(type),
        orElse: () => <String, dynamic>{'long_name': ''},
      );
      return (comp['long_name'] as String).trim();
    }

    final streetNumber = pick('street_number');
    final route        = pick('route');
    final neighborhood = pick('sublocality_level_1');
    final locality     = pick('locality');
    final admin2       = pick('administrative_area_level_2');
    final admin1       = pick('administrative_area_level_1');
    final postalCode   = pick('postal_code');
    final country      = pick('country');

    // 3) Join only the non‐empty parts
    final parts = [
      streetNumber,
      route,
      neighborhood,
      locality,
      admin2,
      admin1,
      postalCode,
      country,
    ].where((s) => s.isNotEmpty);

    return parts.join(', ');
  }
}
