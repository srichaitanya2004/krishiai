import 'package:flutter/material.dart';
import 'chatbot_screen.dart';
import 'settings_screens.dart';
import 'prediction_screen.dart';
import 'package:geolocator/geolocator.dart';
import '../services/weather_service.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;

  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      print("Requesting permission...");

      LocationPermission permission = await Geolocator.requestPermission();
      print("Permission status: $permission");

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("Latitude: ${position.latitude}");
      print("Longitude: ${position.longitude}");

      final weather = await WeatherService.fetchWeather(
        position.latitude,
        position.longitude,
      );

      print("Weather response: $weather");

      setState(() {
        _weatherData = weather;
        _isLoadingWeather = false;
      });
    } catch (e) {
      print("ERROR: $e");

      setState(() {
        _isLoadingWeather = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Predict',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardScreen();
      case 1:
        return const PredictionScreen();
      case 2:
        return const ChatbotScreen();
      case 3:
        return const SettingsScreen();
      default:
        return _buildDashboardScreen();
    }
  }

  // ================= DASHBOARD =================

  Widget _buildDashboardScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== WEATHER CARD =====
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _isLoadingWeather
                  ? const Center(child: CircularProgressIndicator())
                  : _weatherData == null
                  ? const Text("Unable to load weather")
                  : Row(
                      children: [
                        const Icon(
                          Icons.wb_sunny,
                          size: 50,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _weatherData!['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${_weatherData!['weather'][0]['description']}, "
                                "${_weatherData!['main']['temp']}°C",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Humidity: ${_weatherData!['main']['humidity']}%",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                "Wind: ${_weatherData!['wind']['speed']} m/s",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 20),

          // ===== QUICK ACTIONS =====
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildActionCard(
                'Crop Prediction',
                Icons.analytics,
                Colors.green,
              ),
              _buildActionCard('Soil Testing', Icons.terrain, Colors.brown),
              _buildActionCard('Pest Control', Icons.bug_report, Colors.red),
              _buildActionCard('Irrigation', Icons.water_drop, Colors.blue),
            ],
          ),

          const SizedBox(height: 20),

          // ===== RECENT ALERTS =====
          const Text(
            'Recent Alerts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAlertItem(
                    'Irrigation needed for Wheat field',
                    Colors.orange,
                  ),
                  const Divider(),
                  _buildAlertItem('Fertilizer time in 3 days', Colors.blue),
                  const Divider(),
                  _buildAlertItem('Pest alert in nearby farms', Colors.red),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          if (title == 'Crop Prediction') {
            setState(() => _currentIndex = 1);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 35, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertItem(String title, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.warning, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
