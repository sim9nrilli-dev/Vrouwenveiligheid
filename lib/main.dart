import 'dart:ui';

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
    const orange = Color(0xFFF4511E);
    const red = Color(0xFFD32F2F);
    const yellow = Color(0xFFFFB300);

    return MaterialApp(
      title: 'Vrouwenveiligheid',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          primary: red,
          secondary: yellow,
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          primary: const Color(0xFFFF6659),
          secondary: yellow,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomePage(
        isDarkMode: isDarkMode,
        onThemeChanged: (value) => setState(() => isDarkMode = value),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final MapController mapController;

  static const beneluxNW = LatLng(53.7, 2.5);
  static const beneluxSE = LatLng(49.3, 7.5);
  static const beneluxCenter = LatLng(51.5, 4.8);
  static final beneluxBounds = LatLngBounds(beneluxNW, beneluxSE);

  // Vereenvoudigde lokale vectorkaart. Deze kaart wordt volledig door Flutter
  // getekend en heeft dus geen internet, tiles of laadscherm nodig.
  static const beneluxOutline = <LatLng>[
    LatLng(51.35, 3.36), LatLng(51.50, 3.72), LatLng(51.80, 3.85),
    LatLng(52.35, 3.85), LatLng(52.85, 4.35), LatLng(53.55, 6.60),
    LatLng(53.55, 6.95), LatLng(53.20, 7.20), LatLng(52.65, 7.05),
    LatLng(52.10, 6.90), LatLng(51.45, 6.25), LatLng(51.05, 6.05),
    LatLng(50.75, 6.15), LatLng(50.55, 6.10), LatLng(50.30, 6.15),
    LatLng(50.18, 5.95), LatLng(49.45, 6.15), LatLng(49.45, 5.75),
    LatLng(49.50, 5.20), LatLng(49.55, 4.85), LatLng(49.75, 4.45),
    LatLng(50.05, 4.20), LatLng(50.35, 3.35), LatLng(50.75, 2.55),
    LatLng(51.05, 2.55), LatLng(51.20, 2.85),
  ];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitBeneluxBounds());
  }

  void _fitBeneluxBounds() {
    mapController.fitCamera(
      CameraFit.bounds(bounds: beneluxBounds, padding: const EdgeInsets.all(24)),
    );
  }

  void _zoomIn() => mapController.move(
        mapController.camera.center,
        (mapController.camera.zoom + 1).clamp(6.0, 19.0),
      );

  void _zoomOut() => mapController.move(
        mapController.camera.center,
        (mapController.camera.zoom - 1).clamp(6.0, 19.0),
      );

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SettingsPanel(
        isDarkMode: widget.isDarkMode,
        onDarkModeChanged: widget.onThemeChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final sea = dark ? const Color(0xFF123B4A) : const Color(0xFF9ED8EA);
    final land = dark ? const Color(0xFF315D45) : const Color(0xFFE5E6C9);
    final border = dark ? const Color(0xFF8CCF9B) : const Color(0xFF73845D);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: beneluxCenter,
              initialZoom: 7.5,
              minZoom: 6.0,
              maxZoom: 19.0,
              backgroundColor: sea,
              cameraConstraint: CameraConstraint.contain(bounds: beneluxBounds),
            ),
            children: [
              // Geen TileLayer: de kaart is lokaal en werkt volledig offline.
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: beneluxOutline,
                    color: land,
                    borderColor: border,
                    borderStrokeWidth: 2.5,
                    isFilled: true,
                  ),
                ],
              ),
              MarkerLayer(
                markers: const [
                  Marker(point: LatLng(52.09, 5.12), width: 100, height: 30, child: _MapLabel('Nederland')),
                  Marker(point: LatLng(50.85, 4.35), width: 100, height: 30, child: _MapLabel('België')),
                  Marker(point: LatLng(49.61, 6.13), width: 110, height: 30, child: _MapLabel('Luxemburg')),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _GlassPanel(
                  borderRadius: BorderRadius.circular(32),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MapButton(icon: Icons.add, onPressed: _zoomIn),
                      _MapButton(icon: Icons.remove, onPressed: _zoomOut),
                      _MapButton(icon: Icons.home, onPressed: _fitBeneluxBounds),
                      const _GlassDivider(),
                      _MapButton(icon: Icons.settings_outlined, onPressed: _openSettings),
                    ],
                  ),
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

class _MapLabel extends StatelessWidget {
  final String text;
  const _MapLabel(this.text);

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .78),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  const _GlassPanel({required this.child, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: (dark ? Colors.black : Colors.white).withValues(alpha: .58),
            borderRadius: borderRadius,
            border: Border.all(color: Colors.white.withValues(alpha: dark ? .28 : .78), width: 1.2),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .18), blurRadius: 22, offset: const Offset(0, 8))],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassDivider extends StatelessWidget {
  const _GlassDivider();
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: .22),
      );
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _MapButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: primary, size: 25),
        style: IconButton.styleFrom(fixedSize: const Size(46, 46)),
      ),
    );
  }
}

class SettingsPanel extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  const SettingsPanel({super.key, required this.isDarkMode, required this.onDarkModeChanged});

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
  Widget build(BuildContext context) => _GlassPanel(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .35), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                Text('Instellingen', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 18),
                ListTile(
                  leading: Icon(Icons.dark_mode, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Donkere modus'),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      setState(() => isDarkMode = value);
                      widget.onDarkModeChanged(value);
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.notifications, color: Theme.of(context).colorScheme.secondary),
                  title: const Text('Meldingen'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meldingen instellingen geopend'))),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.info, color: Theme.of(context).colorScheme.secondary),
                  title: const Text('Over deze app'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => showAboutDialog(context: context, applicationName: 'Vrouwenveiligheid', applicationVersion: '1.0.0'),
                ),
              ],
            ),
          ),
        ),
      );
}
