import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PredictionsService {
  final String baseUrl = 'https://footballprediction.site/api';
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>?> fetchPredictions() async {

    try {
      final result = await _authService.authenticatedRequest(() async {
        final headers = await _authService.getHeaders();

        return http.get(
          Uri.parse('$baseUrl/predictions'),
          headers: headers,
        );
      });

      if (result['success']) {
        // The response is already parsed, so we don't need to decode it again
        final Map<String, dynamic> parsedData = result['data'];
        return parsedData;
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }
}
