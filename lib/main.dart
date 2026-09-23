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

  // Handmatig vereenvoudigde, vloeiende contouren. De punten volgen nu de
  // echte kustboog van Vlaanderen, Zeeland, Holland en de Waddenzee, in
  // plaats van een hoekige omtrek die de hele Benelux overspant.
  static const countryOutlines = <List<LatLng>>[
    // Nederland: Belgische grens -> Zeeland -> Noordzeekust -> Wadden -> oostgrens -> Limburg.
    [
      LatLng(51.35, 3.36), LatLng(51.43, 3.50), LatLng(51.52, 3.65),
      LatLng(51.62, 3.76), LatLng(51.74, 3.82), LatLng(51.86, 3.83),
      LatLng(51.98, 3.88), LatLng(52.12, 3.97), LatLng(52.27, 4.09),
      LatLng(52.40, 4.22), LatLng(52.52, 4.32), LatLng(52.65, 4.39),
      LatLng(52.78, 4.53), LatLng(52.88, 4.68), LatLng(52.96, 4.83),
      LatLng(53.04, 5.00), LatLng(53.12, 5.18), LatLng(53.22, 5.36),
      LatLng(53.33, 5.55), LatLng(53.44, 5.77), LatLng(53.54, 6.00),
      LatLng(53.56, 6.20), LatLng(53.51, 6.38), LatLng(53.55, 6.59),
      LatLng(53.56, 6.82), LatLng(53.53, 6.98), LatLng(53.44, 7.08),
      LatLng(53.31, 7.19), LatLng(53.15, 7.20), LatLng(53.02, 7.12),
      LatLng(52.87, 7.07), LatLng(52.70, 7.02), LatLng(52.54, 6.98),
      LatLng(52.38, 6.92), LatLng(52.23, 6.84), LatLng(52.08, 6.76),
      LatLng(51.93, 6.67), LatLng(51.79, 6.56), LatLng(51.65, 6.43),
      LatLng(51.52, 6.29), LatLng(51.39, 6.20), LatLng(51.26, 6.13),
      LatLng(51.12, 6.02), LatLng(50.99, 5.88), LatLng(50.86, 5.82),
      LatLng(50.74, 5.87), LatLng(50.63, 5.96), LatLng(50.52, 5.97),
      LatLng(50.41, 5.91), LatLng(50.30, 5.82), LatLng(50.20, 5.82),
      LatLng(50.12, 5.76), LatLng(50.08, 5.64), LatLng(50.12, 5.52),
      LatLng(50.22, 5.43), LatLng(50.31, 5.34), LatLng(50.40, 5.21),
      LatLng(50.46, 5.07), LatLng(50.52, 4.92), LatLng(50.58, 4.77),
      LatLng(50.65, 4.62), LatLng(50.73, 4.48), LatLng(50.82, 4.32),
      LatLng(50.91, 4.16), LatLng(51.02, 3.99), LatLng(51.13, 3.81),
      LatLng(51.23, 3.63), LatLng(51.35, 3.36),
    ],
    // België: een aparte kustlijn en zuidgrens, zodat België niet meer als
    // een uitstulping van de Nederlandse vorm wordt getekend.
    [
      LatLng(51.35, 2.55), LatLng(51.35, 2.67), LatLng(51.34, 2.80),
      LatLng(51.33, 2.94), LatLng(51.32, 3.08), LatLng(51.31, 3.22),
      LatLng(51.31, 3.36), LatLng(51.27, 3.50), LatLng(51.21, 3.64),
      LatLng(51.13, 3.81), LatLng(51.03, 3.98), LatLng(50.92, 4.16),
      LatLng(50.82, 4.32), LatLng(50.73, 4.48), LatLng(50.65, 4.62),
      LatLng(50.57, 4.78), LatLng(50.51, 4.93), LatLng(50.45, 5.08),
      LatLng(50.39, 5.22), LatLng(50.30, 5.35), LatLng(50.21, 5.44),
      LatLng(50.11, 5.54), LatLng(50.06, 5.67), LatLng(49.97, 5.79),
      LatLng(49.86, 5.86), LatLng(49.74, 5.86), LatLng(49.62, 5.82),
      LatLng(49.52, 5.75), LatLng(49.45, 5.72), LatLng(49.49, 5.42),
      LatLng(49.54, 5.10), LatLng(49.61, 4.78), LatLng(49.74, 4.51),
      LatLng(49.89, 4.29), LatLng(50.07, 4.12), LatLng(50.23, 3.88),
      LatLng(50.39, 3.59), LatLng(50.53, 3.28), LatLng(50.68, 2.95),
      LatLng(50.82, 2.65), LatLng(50.98, 2.55), LatLng(51.17, 2.55),
      LatLng(51.35, 2.55),
    ],
    // Luxemburg: herkenbare compacte vorm, los van de Belgische polygon.
    [
      LatLng(49.89, 5.73), LatLng(50.05, 5.75), LatLng(50.20, 5.82),
      LatLng(50.35, 5.95), LatLng(50.27, 6.08), LatLng(50.16, 6.17),
      LatLng(49.98, 6.22), LatLng(49.80, 6.32), LatLng(49.61, 6.36),
      LatLng(49.46, 6.35), LatLng(49.45, 6.10), LatLng(49.54, 5.75),
      LatLng(49.70, 5.72), LatLng(49.89, 5.73),
    ],
  ];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitBeneluxBounds());
  }

  void _fitBeneluxBounds() => mapController.fitCamera(
        CameraFit.bounds(bounds: beneluxBounds, padding: const EdgeInsets.all(24)),
      );

  void _zoomIn() => mapController.move(
        mapController.camera.center,
        (mapController.camera.zoom + 1).clamp(6.0, 19.0),
      );

  void _zoomOut() => mapController.move(
        mapController.camera.center,
        (mapController.camera.zoom - 1).clamp(6.0, 19.0),
      );

  void _openSettings() => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => SettingsPanel(
          isDarkMode: widget.isDarkMode,
          onDarkModeChanged: widget.onThemeChanged,
        ),
      );

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
              PolygonLayer(
                polygons: [
                  for (final outline in countryOutlines)
                    Polygon(
                      points: outline,
                      color: land,
                      borderColor: border,
                      borderStrokeWidth: 1.8,
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
