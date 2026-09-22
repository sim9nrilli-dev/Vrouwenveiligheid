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
        onThemeChanged: (isDark) {
          setState(() => isDarkMode = isDark);
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

  // This is intentionally a tight Benelux frame, not a large rectangle around it.
  static const LatLng beneluxNW = LatLng(53.7, 2.5);
  static const LatLng beneluxSE = LatLng(49.3, 7.5);
  static const LatLng beneluxCenter = LatLng(51.5, 4.8);
  static final LatLngBounds beneluxBounds = LatLngBounds(
    beneluxNW,
    beneluxSE,
  );

  // Outer outline of the three Benelux countries. The mask below makes every
  // tile outside this outline sea, so Germany and France are not shown.
  static const List<LatLng> beneluxOutline = [
    LatLng(51.35, 3.36), // Belgian coast
    LatLng(51.50, 3.72),
    LatLng(51.80, 3.85),
    LatLng(52.35, 3.85),
    LatLng(52.85, 4.35),
    LatLng(53.55, 6.60), // Dutch Wadden coast
    LatLng(53.55, 6.95),
    LatLng(53.20, 7.20), // Netherlands/Germany border
    LatLng(52.65, 7.05),
    LatLng(52.10, 6.90),
    LatLng(51.45, 6.25),
    LatLng(51.05, 6.05),
    LatLng(50.75, 6.15),
    LatLng(50.55, 6.10),
    LatLng(50.30, 6.15),
    LatLng(50.18, 5.95), // Luxembourg/Germany border
    LatLng(49.45, 6.15),
    LatLng(49.45, 5.75), // Luxembourg/France border
    LatLng(49.50, 5.20),
    LatLng(49.55, 4.85),
    LatLng(49.75, 4.45),
    LatLng(50.05, 4.20),
    LatLng(50.35, 3.35),
    LatLng(50.75, 2.55), // Belgian/French border
    LatLng(51.05, 2.55),
    LatLng(51.20, 2.85),
  ];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitBeneluxBounds());
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
      backgroundColor: Colors.transparent,
      builder: (context) => SettingsPanel(
        isDarkMode: widget.isDarkMode,
        onDarkModeChanged: widget.onThemeChanged,
      ),
    );
  }

  void _zoomIn() {
    final newZoom = (mapController.camera.zoom + 1).clamp(6.0, 19.0);
    mapController.move(mapController.camera.center, newZoom);
  }

  void _zoomOut() {
    final newZoom = (mapController.camera.zoom - 1).clamp(6.0, 19.0);
    mapController.move(mapController.camera.center, newZoom);
  }

  @override
  Widget build(BuildContext context) {
    final seaColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF123B4A)
        : const Color(0xFF9ED8EA);

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
              cameraConstraint: CameraConstraint.contain(bounds: beneluxBounds),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.vrouwenveiligheid.app',
                maxZoom: 19,
                retinaMode: false,
              ),
              // A world-sized polygon with a Benelux-shaped hole masks all
              // surrounding countries. Only the Benelux map remains visible.
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: const [
                      LatLng(-85, -180),
                      LatLng(-85, 180),
                      LatLng(85, 180),
                      LatLng(85, -180),
                    ],
                    color: seaColor,
                    isFilled: true,
                    holePointsList: [beneluxOutline],
                  ),
                ],
              ),
              RichAttributionWidget(
                alignment: AttributionAlignment.bottomLeft,
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: _GlassPanel(
                  borderRadius: BorderRadius.circular(32),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MapButton(icon: Icons.add, onPressed: _zoomIn),
                      _MapButton(icon: Icons.remove, onPressed: _zoomOut),
                      _MapButton(icon: Icons.home, onPressed: _fitBeneluxBounds),
                      const _GlassDivider(),
                      _MapButton(
                        icon: Icons.settings_outlined,
                        onPressed: _openSettings,
                      ),
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

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const _GlassPanel({required this.child, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.58),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.28 : 0.78),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
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
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.22),
    );
  }
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          splashColor: primary.withValues(alpha: 0.16),
          highlightColor: primary.withValues(alpha: 0.08),
          child: Ink(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.62),
                  primary.withValues(alpha: 0.10),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.72),
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: primary,
              size: 25,
            ),
          ),
        ),
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
    return _GlassPanel(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Instellingen',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: Icon(Icons.dark_mode, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Donkere modus'),
                  trailing: Switch(
                    value: isDarkMode,
                    activeColor: Theme.of(context).colorScheme.primary,
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
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Meldingen instellingen geopend')),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.info, color: Theme.of(context).colorScheme.secondary),
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
        ),
      ),
    );
  }
}
