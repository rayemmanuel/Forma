// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile_model.dart';

class ApiService {

  static const String _baseUrl =
      'http://192.168.55.101:3000';

  /// Fetches clothing recommendations from the backend.
  static Future<Map<String, List<ClothingItem>>> getRecommendations({
    required String gender,
    required String bodyType,
    required String skinUndertone,
  }) async {
    final Map<String, List<ClothingItem>> recommendations = {};

    try {
      // Construct the URL with query parameters
      final uri = Uri.parse('$_baseUrl/api/recommendations').replace(
        queryParameters: {
          'gender': gender,
          'bodyType': bodyType,
          'skinUndertone': skinUndertone,
        },
      );

      // Make the GET request
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Loop through each category returned from the server (e.g., "Dresses", "Shirts")
        data.forEach((category, items) {
          final List<dynamic> itemList = items;
          // Convert the JSON for each item into a ClothingItem object
          recommendations[category] = itemList
              .map((itemJson) => ClothingItem.fromJson(itemJson))
              .toList();
        });

        return recommendations;
      } else {
        // If the server did not return a 200 OK response, log the error
        print('Failed to load recommendations: ${response.body}');
        return {};
      }
    } catch (e) {
      // Catch any errors during the HTTP call
      print('Error fetching recommendations: $e');
      return {};
    }
  }
}
