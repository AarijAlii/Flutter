import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search City'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<WeatherProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Enter city name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.fetchWeather(_controller.text.trim());
                  },
                  child: const Text('Search'),
                ),
                const SizedBox(height: 16),
                if (provider.isLoading)
                  const CircularProgressIndicator()
                else if (provider.errorMessage != null)
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  )
                else if (provider.cityWeatherData.containsKey(
                  _controller.text.trim().toLowerCase(),
                )) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${provider.cityWeatherData[_controller.text.trim().toLowerCase()]!.cityName}, ${provider.cityWeatherData[_controller.text.trim().toLowerCase()]!.country}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Temperature: ${_formatTemperature(provider.cityWeatherData[_controller.text.trim().toLowerCase()]!.temperature)}',
                          ),
                          Text(
                            'Description: ${provider.cityWeatherData[_controller.text.trim().toLowerCase()]!.description}',
                          ),
                          Text(
                            'Humidity: ${provider.cityWeatherData[_controller.text.trim().toLowerCase()]!.humidity}%',
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed:
                                provider.isFavorite(_controller.text.trim())
                                ? null
                                : () {
                                    final weather =
                                        provider.cityWeatherData[_controller
                                            .text
                                            .trim()
                                            .toLowerCase()]!;
                                    provider.addToFavorites(weather.cityName);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Added to favorites'),
                                      ),
                                    );
                                  },
                            icon: Icon(
                              provider.isFavorite(_controller.text.trim())
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                            label: const Text('Add to Favorites'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatTemperature(double temp) {
    final provider = Provider.of<WeatherProvider>(context, listen: false);
    if (provider.isCelsius) {
      return '${temp.toStringAsFixed(1)}°C';
    } else {
      final fahrenheit = temp * 9 / 5 + 32;
      return '${fahrenheit.toStringAsFixed(1)}°F';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
