import 'package:geocoding/geocoding.dart';

/// One-line postal-style label from a platform [Placemark] (same shape as post-job flow).
String? singleLineAddressFromPlacemark(Placemark p) {
  final parts = [
    p.street,
    p.subLocality,
    p.locality,
    p.postalCode,
    p.country,
  ].where((e) => e != null && e.toString().trim().isNotEmpty);
  final s = parts.join(', ');
  return s.isEmpty ? null : s;
}

/// Reverse geocode; returns null on empty result or failure (no throw).
Future<String?> reverseGeocodeLatLng(double lat, double lng) async {
  try {
    final marks = await placemarkFromCoordinates(lat, lng);
    if (marks.isEmpty) return null;
    return singleLineAddressFromPlacemark(marks.first);
  } catch (_) {
    return null;
  }
}
