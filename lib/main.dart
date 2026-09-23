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

  // Landgrenzen per land in plaats van één grove, hoekige omtrek. Hierdoor
  // blijven de kustlijn, Zeeland, Limburg en Luxemburg herkenbaar zonder
  // afhankelijk te zijn van online kaarttegels.
  static const countryOutlines = <List<LatLng>>[
    // Nederland
    [
      LatLng(51.35, 3.36), LatLng(51.42, 3.50), LatLng(51.52, 3.66),
      LatLng(51.62, 3.78), LatLng(51.72, 3.84), LatLng(51.82, 3.84),
      LatLng(51.92, 3.90), LatLng(52.08, 3.96), LatLng(52.25, 4.05),
      LatLng(52.42, 4.18), LatLng(52.58, 4.32), LatLng(52.70, 4.42),
      LatLng(52.82, 4.57), LatLng(52.95, 4.78), LatLng(53.08, 4.96),
      LatLng(53.20, 5.18), LatLng(53.32, 5.42), LatLng(53.45, 5.68),
      LatLng(53.56, 5.95), LatLng(53.56, 6.18), LatLng(53.51, 6.38),
      LatLng(53.55, 6.62), LatLng(53.55, 6.95), LatLng(53.40, 7.05),
      LatLng(53.25, 7.18), LatLng(53.10, 7.20), LatLng(52.95, 7.10),
      LatLng(52.80, 7.05), LatLng(52.66, 7.02), LatLng(52.52, 6.98),
      LatLng(52.38, 6.92), LatLng(52.24, 6.84), LatLng(52.10, 6.76),
      LatLng(51.96, 6.68), LatLng(51.82, 6.55), LatLng(51.68, 6.38),
      LatLng(51.54, 6.24), LatLng(51.39, 6.18), LatLng(51.24, 6.13),
      LatLng(51.10, 5.99), LatLng(50.98, 5.86), LatLng(50.86, 5.82),
      LatLng(50.75, 5.87), LatLng(50.65, 5.96), LatLng(50.53, 5.97),
      LatLng(50.42, 5.90), LatLng(50.31, 5.81), LatLng(50.20, 5.82),
      LatLng(50.12, 5.77), LatLng(50.08, 5.65), LatLng(50.12, 5.53),
      LatLng(50.22, 5.44), LatLng(50.31, 5.35), LatLng(50.40, 5.22),
      LatLng(50.46, 5.08), LatLng(50.52, 4.94), LatLng(50.58, 4.78),
      LatLng(50.66, 4.62), LatLng(50.74, 4.48), LatLng(50.83, 4.32),
      LatLng(50.93, 4.15), LatLng(51.04, 3.98), LatLng(51.14, 3.80),
      LatLng(51.23, 3.62), LatLng(51.35, 3.36),
    ],
    // België
    [
      LatLng(51.35, 2.55), LatLng(51.35, 3.36), LatLng(51.23, 3.62),
      LatLng(51.14, 3.80), LatLng(51.04, 3.98), LatLng(50.93, 4.15),
      LatLng(50.83, 4.32), LatLng(50.74, 4.48), LatLng(50.66, 4.62),
      LatLng(50.58, 4.78), LatLng(50.52, 4.94), LatLng(50.46, 5.08),
      LatLng(50.40, 5.22), LatLng(50.31, 5.35), LatLng(50.22, 5.44),
      LatLng(50.12, 5.53), LatLng(50.08, 5.65), LatLng(49.98, 5.78),
      LatLng(49.87, 5.85), LatLng(49.76, 5.86), LatLng(49.65, 5.82),
      LatLng(49.54, 5.75), LatLng(49.45, 5.72), LatLng(49.50, 5.35),
      LatLng(49.55, 5.00), LatLng(49.62, 4.65), LatLng(49.76, 4.43),
      LatLng(49.91, 4.25), LatLng(50.08, 4.10), LatLng(50.25, 3.84),
      LatLng(50.40, 3.57), LatLng(50.55, 3.25), LatLng(50.70, 2.91),
      LatLng(50.84, 2.62), LatLng(51.00, 2.55), LatLng(51.18, 2.55),
      LatLng(51.35, 2.55),
    ],
    // Luxemburg
    [
      LatLng(49.89, 5.73), LatLng(50.18, 5.75), LatLng(50.35, 5.95),
      LatLng(50.18, 6.15), LatLng(49.96, 6.24), LatLng(49.61, 6.36),
      LatLng(49.45, 6.36), LatLng(49.45, 6.10), LatLng(49.54, 5.75),
      LatLng(49.70, 5.72), LatLng(49.89, 5.73),
    ],
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
              // Lokale kaart: geen internet, tiles of laadscherm nodig.
              PolygonLayer(
                polygons: [
                  for (final outline in countryOutlines)
                    Polygon(
                      points: outline,
                      color: land,
                      borderColor: border,
                      borderStrokeWidth: 2.0,
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
