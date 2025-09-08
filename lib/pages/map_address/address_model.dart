// lib/pages/map_address/address_model.dart

import 'dart:convert';

/// A simple Address model with serialization for prefs.
class Address {
  final String line;
  final String landmark;
  final String village;
  final String city;
  final String district;
  final String state;
  final String country;
  final String pinCode;
  final String locationUrl;
  final double? latitude;
  final double? longitude;
  final String type;
  final bool isDefault;

  Address({
    required this.line,
    required this.landmark,
    required this.village,
    required this.city,
    required this.district,
    required this.state,
    required this.country,
    required this.pinCode,
    required this.locationUrl,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.isDefault,
  });

  /// An empty placeholder.
  factory Address.empty() => Address(
    line: '',
    landmark: '',
    village: '',
    city: '',
    district: '',
    state: '',
    country: '',
    pinCode: '',
    locationUrl: '',
    latitude: null,
    longitude: null,
    type: 'Other',
    isDefault: false,
  );

  Address copyWith({
    String? line,
    String? landmark,
    String? village,
    String? city,
    String? district,
    String? state,
    String? country,
    String? pinCode,
    String? locationUrl,
    double? latitude,
    double? longitude,
    String? type,
    bool? isDefault,
  }) {
    return Address(
      line:        line        ?? this.line,
      landmark:    landmark    ?? this.landmark,
      village:     village     ?? this.village,
      city:        city        ?? this.city,
      district:    district    ?? this.district,
      state:       state       ?? this.state,
      country:     country     ?? this.country,
      pinCode:     pinCode     ?? this.pinCode,
      locationUrl: locationUrl ?? this.locationUrl,
      latitude:    latitude    ?? this.latitude,
      longitude:   longitude   ?? this.longitude,
      type:        type        ?? this.type,
      isDefault:   isDefault   ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'line': line,
      'landmark': landmark,
      'village': village,
      'city': city,
      'district': district,
      'state': state,
      'country': country,
      'pinCode': pinCode,
      'locationUrl': locationUrl,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'isDefault': isDefault,
    };
  }

  factory Address.fromMap(Map<String, dynamic> m) {
    return Address(
      line:        m['line']        as String,
      landmark:    m['landmark']    as String,
      village:     m['village']     as String,
      city:        m['city']        as String,
      district:    m['district']    as String,
      state:       m['state']       as String,
      country:     m['country']     as String,
      pinCode:     m['pinCode']     as String,
      locationUrl: m['locationUrl'] as String,
      latitude:    (m['latitude']    as num?)?.toDouble(),
      longitude:   (m['longitude']   as num?)?.toDouble(),
      type:        m['type']        as String,
      isDefault:   m['isDefault']   as bool,
    );
  }

  String toJson() => jsonEncode(toMap());

  static Address fromJson(String source) =>
      Address.fromMap(jsonDecode(source) as Map<String, dynamic>);

  /// Serialize a list to a single JSON string for prefs.
  static String toPrefs(List<Address> list) =>
      jsonEncode(list.map((a) => a.toMap()).toList());

  /// Deserialize from prefs or return empty list.
  static List<Address> listFromPrefs(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final arr = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return arr.map(Address.fromMap).toList();
  }
}
