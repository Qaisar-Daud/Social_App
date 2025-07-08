
// TODO: Location Permission Controller From User
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:geocoding/geocoding.dart' as geo;
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import '../models/ip_location_model.dart';
//
// class LocationProvider with ChangeNotifier {
//   IPLocation? _location;
//   bool _isLoading = false;
//   String? _error;
//
//   IPLocation? get location => _location;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//
//   static Future<Map<String, dynamic>> getCurrentLocation() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) {
//         permission = await Geolocator.requestPermission();
//       }
//
//       if (permission == LocationPermission.always ||
//           permission == LocationPermission.whileInUse) {
//         // Step 1: Get lat/long
//         Position position = await Geolocator.getCurrentPosition(
//             desiredAccuracy: LocationAccuracy.high);
//
//         // Step 2: Use reverse geocoding to get address
//         List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
//             position.latitude, position.longitude);
//
//         final place = placemarks.first;
//
//         return {
//           'source': 'GPS',
//           'city': place.locality ?? '',
//           'region': place.administrativeArea ?? '',
//           'country': place.country ?? '',
//           'latitude': position.latitude,
//           'longitude': position.longitude,
//         };
//       } else {
//         return await _getLocationFromIP();
//       }
//     } catch (e) {
//       return await _getLocationFromIP();
//     }
//   }
//
//   static Future<Map<String, dynamic>> _getLocationFromIP() async {
//     try {
//       final res = await http.get(Uri.parse('https://ipwho.is/'));
//       if (res.statusCode == 200) {
//         final json = jsonDecode(res.body);
//         return {
//           'source': 'IP',
//           'ip': json['ip'],
//           'city': json['city'],
//           'region': json['region'],
//           'country': json['country'],
//           'latitude': json['latitude'],
//           'longitude': json['longitude'],
//         };
//       } else {
//         throw Exception('IP API failed');
//       }
//     } catch (e) {
//       return {
//         'source': 'unknown',
//         'error': 'Location not available: ${e.toString()}',
//       };
//     }
//   }
//
//   // Future<void> fetchLocation() async {
//   //   _isLoading = true;
//   //   _error = null;
//   //   notifyListeners();
//   //
//   //   try {
//   //     // Check and request permission
//   //     LocationPermission permission = await Geolocator.checkPermission();
//   //     if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
//   //       permission = await Geolocator.requestPermission();
//   //     }
//   //
//   //     if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
//   //       final Position position = await Geolocator.getCurrentPosition();
//   //       // You can optionally reverse geocode here if needed
//   //       _location = await _getLocationFromIP(); // Fallback to IP metadata even with GPS
//   //     } else {
//   //       _location = await _getLocationFromIP(); // Pure fallback
//   //     }
//   //   } catch (e) {
//   //     _error = 'Location fetch failed: $e';
//   //   }
//   //
//   //   _isLoading = false;
//   //   notifyListeners();
//   // }
//   //
//   // Future<IPLocation?> _getLocationFromIP() async {
//   //   try {
//   //     final res = await http.get(Uri.parse('https://ipwho.is/'));
//   //     if (res.statusCode == 200) {
//   //       final data = jsonDecode(res.body);
//   //       return IPLocation.fromJson(data);
//   //     } else {
//   //       throw Exception('IP API failed');
//   //     }
//   //   } catch (e) {
//   //     _error = 'IP location fetch failed: $e';
//   //     return null;
//   //   }
//   // }
// }
