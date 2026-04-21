import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Google Maps API Key - REPLACE WITH YOUR KEY
  static const String _googleApiKey = 'AIzaSyA5KnKCCQM6OwuSWyF0K-m9ugIr6HPbOvY';

  // ═══════════════════════════════════════════════════════════════════════════
  // GEOLOCATION - Get Current Location
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current position with error handling
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('⚠️ Location services are disabled');
        return null;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('⚠️ Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('⚠️ Location permissions are permanently denied');
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint('✅ Current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      return null;
    }
  }

  /// Get address from coordinates (Reverse Geocoding)
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = '${place.street}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}';
        debugPrint('✅ Address: $address');
        return address;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting address: $e');
      return null;
    }
  }

  /// Get coordinates from address (Forward Geocoding)
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        debugPrint('✅ Coordinates: ${location.latitude}, ${location.longitude}');
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting coordinates: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DISTANCE CALCULATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calculate distance between two points in kilometers
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final distanceInMeters = Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
    
    final distanceInKm = distanceInMeters / 1000;
    debugPrint('📏 Distance: ${distanceInKm.toStringAsFixed(2)} km');
    return distanceInKm;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GOOGLE DISTANCE MATRIX API
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get distance and duration using Google Distance Matrix API
  Future<Map<String, dynamic>?> getDistanceMatrix({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String mode = 'driving', // driving, walking, bicycling, transit
  }) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=$originLat,$originLng'
        '&destinations=$destLat,$destLng'
        '&mode=$mode'
        '&key=$_googleApiKey'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK') {
          final element = data['rows'][0]['elements'][0];
          
          if (element['status'] == 'OK') {
            final result = {
              'distance': element['distance']['text'], // e.g., "5.2 km"
              'distanceValue': element['distance']['value'], // in meters
              'duration': element['duration']['text'], // e.g., "15 mins"
              'durationValue': element['duration']['value'], // in seconds
            };
            
            debugPrint('✅ Distance Matrix: ${result['distance']}, ${result['duration']}');
            return result;
          }
        }
      }
      
      debugPrint('⚠️ Distance Matrix API failed');
      return null;
    } catch (e) {
      debugPrint('❌ Error calling Distance Matrix API: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GOOGLE PLACES API - Nearby Search
  // ═══════════════════════════════════════════════════════════════════════════

  /// Search for nearby places
  Future<List<Map<String, dynamic>>> searchNearbyPlaces({
    required double latitude,
    required double longitude,
    int radius = 5000, // in meters
    String type = 'clothing_store',
  }) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$latitude,$longitude'
        '&radius=$radius'
        '&type=$type'
        '&key=$_googleApiKey'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          
          final places = results.map((place) {
            return {
              'name': place['name'],
              'address': place['vicinity'],
              'latitude': place['geometry']['location']['lat'],
              'longitude': place['geometry']['location']['lng'],
              'rating': place['rating'] ?? 0.0,
              'placeId': place['place_id'],
            };
          }).toList();
          
          debugPrint('✅ Found ${places.length} nearby places');
          return places;
        }
      }
      
      debugPrint('⚠️ Places API failed');
      return [];
    } catch (e) {
      debugPrint('❌ Error calling Places API: $e');
      return [];
    }
  }

  /// Get place details by place ID
  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=name,formatted_address,formatted_phone_number,opening_hours,rating,photos'
        '&key=$_googleApiKey'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK') {
          final result = data['result'];
          debugPrint('✅ Place details retrieved');
          return result;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error getting place details: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Format distance for display
  String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceInKm.toStringAsFixed(1)} km';
  }

  /// Calculate walking time (average speed: 5 km/h)
  String calculateWalkingTime(double distanceInKm) {
    final minutes = (distanceInKm / 5 * 60).round();
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  /// Calculate driving time (average speed: 40 km/h in city)
  String calculateDrivingTime(double distanceInKm) {
    final minutes = (distanceInKm / 40 * 60).round();
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }
}
