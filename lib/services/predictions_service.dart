import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PredictionsService {
  final String baseUrl = 'https://footballprediction.site/api';
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>?> fetchPredictions() async {
    debugPrint('Attempting to fetch predictions');

    try {
      final result = await _authService.authenticatedRequest(() async {
        final headers = await _authService.getHeaders();
        debugPrint('Headers being sent: $headers');

        return http.get(
          Uri.parse('$baseUrl/predictions'),
          headers: headers,
        );
      });

      if (result['success']) {
        debugPrint('Predictions fetched successfully');

        // The response is already parsed, so we don't need to decode it again
        final Map<String, dynamic> parsedData = result['data'];
        debugPrint('Parsed predictions data: $parsedData');

        return parsedData;
      } else {
        debugPrint('Failed to fetch predictions: ${result['message']}');
        return null;
      }
    } catch (error) {
      debugPrint('Fetch Predictions Error: $error');
      debugPrint('Fetch Predictions Error Stack Trace: ${StackTrace.current}');
      return null;
    }
  }
}
