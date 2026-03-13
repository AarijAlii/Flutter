import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/weather.dart';

class WeatherProvider extends ChangeNotifier {
  final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  final String baseUrl =
      dotenv.env['OPENWEATHER_BASE_URL'] ??
      'https://api.openweathermap.org/data/2.5/weather';

  final Map<String, Weather> _cityWeatherData = {};
  final List<String> _favoriteCities = [];
  bool _isCelsius = true;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, Weather> get cityWeatherData => _cityWeatherData;
  List<String> get favoriteCities => _favoriteCities;
  bool get isCelsius => _isCelsius;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWeather(String cityName) async {
    if (cityName.isEmpty) {
      _errorMessage = 'Please enter a city name';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl?q=$cityName&units=metric&appid=$apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weather = Weather.fromJson(data);
        _cityWeatherData[cityName.toLowerCase()] = weather;
        _errorMessage = null;
      } else {
        _errorMessage = 'City not found or network error';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleUnit(bool isCelsius) {
    _isCelsius = isCelsius;
    notifyListeners();
  }

  void addToFavorites(String cityName) {
    final key = cityName.toLowerCase();
    if (_cityWeatherData.containsKey(key) && !_favoriteCities.contains(key)) {
      _favoriteCities.add(key);
      notifyListeners();
    }
  }

  void removeFromFavorites(String cityName) {
    _favoriteCities.remove(cityName.toLowerCase());
    notifyListeners();
  }

  List<Weather> getFavoriteWeathers() {
    return _favoriteCities
        .map((city) => _cityWeatherData[city])
        .where((weather) => weather != null)
        .cast<Weather>()
        .toList();
  }

  bool isFavorite(String cityName) {
    return _favoriteCities.contains(cityName.toLowerCase());
  }
}
