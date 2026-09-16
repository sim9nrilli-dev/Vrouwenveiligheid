import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vrouwenveiligheid',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late MapController mapController;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SettingsPanel(
        isDarkMode: isDarkMode,
        onDarkModeChanged: (value) {
          setState(() {
            isDarkMode = value;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Interactieve kaart op de achtergrond
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: const LatLng(52.1326, 5.2913), // Nederland
              initialZoom: 7.0,
              minZoom: 5.0,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(52.3676, 4.9041), // Amsterdam
                    width: 80,
                    height: 80,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Amsterdam - Veilig Area')),
                        );
                      },
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ),
                  Marker(
                    point: const LatLng(52.0116, 4.3571), // Den Haag
                    width: 80,
                    height: 80,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Den Haag - Veilig Area')),
                        );
                      },
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.orange,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Bovenste balk met title
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      '🛡️ Vrouwenveiligheid',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  // Settings knop
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _openSettings,
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.purple,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}

class SettingsPanel extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onDarkModeChanged;

  const SettingsPanel({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Instellingen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.dark_mode, color: Colors.purple),
            title: const Text('Donkere modus'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: onDarkModeChanged,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.map, color: Colors.purple),
            title: const Text('Kaart instellingen'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kaart instellingen geopend')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.purple),
            title: const Text('Meldingen'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Meldingen instellingen geopend')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.purple),
            title: const Text('Over deze app'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Vrouwenveiligheid',
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }
}
