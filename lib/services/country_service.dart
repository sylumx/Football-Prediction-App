import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../models/country.dart';

class CountryService {
  Future<List<Country>> getCountries() async {
    // Load country data from a JSON file
    String data = await rootBundle.loadString('assets/countries.json');
    List<dynamic> jsonResult = json.decode(data);

    return jsonResult
        .map((country) => Country(
              code: country['iso_3166_1_alpha2'],
              name: country['name'],
              flag: country['emoji'],
            ))
        .toList();
  }

  String getFlag(String countryCode) {
    // Implementation to get flag emoji from country code
    // You might need to implement this based on your data
    return '🏳️'; // Placeholder
  }
}
