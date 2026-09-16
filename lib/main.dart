import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vrouwenveiligheid',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomePage(
        isDarkMode: isDarkMode,
        onThemeChanged: (isDark) {
          setState(() {
            isDarkMode = isDark;
          });
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late MapController mapController;

  // Benelux bounds
  static const LatLng beneluxNW = LatLng(53.6, 2.5);   // Noord-West
  static const LatLng beneluxSE = LatLng(49.4, 6.6);   // Zuid-Oost
  static const LatLng beneluxCenter = LatLng(51.5, 4.8);

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    // Zoom naar Benelux bij start
    _fitBeneluxBounds();
  }

  void _fitBeneluxBounds() {
    mapController.move(beneluxCenter, 7.5);
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SettingsPanel(
        isDarkMode: widget.isDarkMode,
        onDarkModeChanged: (value) {
          widget.onThemeChanged(value);
        },
      ),
    );
  }

  void _zoomIn() {
    final newZoom = (mapController.camera.zoom + 1).clamp(6.0, 20.0);
    mapController.move(mapController.camera.center, newZoom);
  }

  void _zoomOut() {
    final newZoom = (mapController.camera.zoom - 1).clamp(6.0, 20.0);
    mapController.move(mapController.camera.center, newZoom);
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
              initialCenter: beneluxCenter,
              initialZoom: 7.5,
              minZoom: 6.0,  // Benelux goed zichtbaar
              maxZoom: 20.0, // Heel ver inzoomen toegestaan
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: widget.isDarkMode
                    ? 'https://tiles.stadiamaps.com/tiles/stamen_toner/{z}/{x}/{y}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
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
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
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
                      color: Theme.of(context).scaffoldBackgroundColor,
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
          // Zoom knoppen aan de rechterkant
          SafeArea(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
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
                        onPressed: _zoomIn,
                        icon: const Icon(
                          Icons.add,
                          color: Colors.purple,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
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
                        onPressed: _zoomOut,
                        icon: const Icon(
                          Icons.remove,
                          color: Colors.purple,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
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
                        onPressed: _fitBeneluxBounds,
                        icon: const Icon(
                          Icons.home,
                          color: Colors.purple,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
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

class SettingsPanel extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onDarkModeChanged;

  const SettingsPanel({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
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
            // Donkere Modus Toggle
            ListTile(
              leading: const Icon(Icons.dark_mode, color: Colors.purple),
              title: const Text('Donkere modus'),
              trailing: Switch(
                value: isDarkMode,
                activeColor: Colors.purple,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                  });
                  widget.onDarkModeChanged(value);
                },
              ),
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
      ),
    );
  }
}
