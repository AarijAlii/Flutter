import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> predefinedCities = [
    'London',
    'Karachi',
    'New York',
    'Tokyo',
    'Sydney',
  ];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WeatherProvider>(context, listen: false);
      for (var city in predefinedCities) {
        provider.fetchWeather(city);
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WeatherWise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
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
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Major Cities',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: predefinedCities.length,
                    itemBuilder: (context, index) {
                      final city = predefinedCities[index];
                      final weather =
                          provider.cityWeatherData[city.toLowerCase()];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 120,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                city,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (weather != null) ...[
                                Text(_formatTemperature(weather.temperature)),
                                Image.network(
                                  'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                                  width: 50,
                                  height: 50,
                                ),
                              ] else ...[
                                const CircularProgressIndicator(),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Favorite Cities',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                if (provider.getFavoriteWeathers().isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No favorite cities yet. Search and add some!'),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.getFavoriteWeathers().length,
                    itemBuilder: (context, index) {
                      final weather = provider.getFavoriteWeathers()[index];
                      return ListTile(
                        title: Text(weather.cityName),
                        subtitle: Text(_formatTemperature(weather.temperature)),
                        leading: Image.network(
                          'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                          width: 50,
                          height: 50,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () {
                            provider.removeFromFavorites(weather.cityName);
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
}
