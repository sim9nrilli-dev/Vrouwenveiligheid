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

  // Gebied waarin de kaart blijft: alleen de Benelux.
  static const LatLng beneluxNW = LatLng(53.6, 2.5);
  static const LatLng beneluxSE = LatLng(49.4, 6.6);
  static const LatLng beneluxCenter = LatLng(51.5, 4.8);
  static final LatLngBounds beneluxBounds = LatLngBounds(
    beneluxNW,
    beneluxSE,
  );

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitBeneluxBounds();
    });
  }

  void _fitBeneluxBounds() {
    mapController.fitCamera(
      CameraFit.bounds(
        bounds: beneluxBounds,
        padding: const EdgeInsets.all(24),
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SettingsPanel(
        isDarkMode: widget.isDarkMode,
        onDarkModeChanged: widget.onThemeChanged,
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
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: beneluxCenter,
              initialZoom: 7.5,
              minZoom: 6.0,
              maxZoom: 20.0,
              // Pannen buiten de Benelux wordt hiermee geblokkeerd.
              cameraConstraint: CameraConstraint.contain(
                bounds: beneluxBounds,
              ),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                // OpenStreetMap-kaart, zonder externe API-sleutel.
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.vrouwenveiligheid.app',
              ),
            ],
          ),
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
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
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
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
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
          SafeArea(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MapButton(icon: Icons.add, onPressed: _zoomIn),
                    const SizedBox(height: 8),
                    _MapButton(icon: Icons.remove, onPressed: _zoomOut),
                    const SizedBox(height: 8),
                    _MapButton(icon: Icons.home, onPressed: _fitBeneluxBounds),
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

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MapButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.purple, size: 28),
      ),
    );
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.dark_mode, color: Colors.purple),
              title: const Text('Donkere modus'),
              trailing: Switch(
                value: isDarkMode,
                activeColor: Colors.purple,
                onChanged: (value) {
                  setState(() => isDarkMode = value);
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
                  const SnackBar(
                    content: Text('Meldingen instellingen geopend'),
                  ),
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
