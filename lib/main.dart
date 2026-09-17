import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/settings_service.dart';
import 'services/trophy_service.dart';
import 'theme/app_theme.dart';
import 'widgets/crt_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Settings are read before the first frame, so nothing renders with a
  // default it is about to replace — a scanline overlay that arrived one frame
  // late would flicker on every launch.
  final SettingsService settings = SettingsService();
  await settings.load();
  runApp(Cabinet88App(settings: settings));
}

/// App entry. UI logic lives in the screens, not here.
class Cabinet88App extends StatelessWidget {
  const Cabinet88App({super.key, required this.settings});

  final SettingsService settings;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // The one service the UI reads progress through. Phase 5 replaces the
        // implementation, not the seam.
        Provider<TrophyService>.value(value: const SeededTrophyService()),
        ChangeNotifierProvider<SettingsService>.value(value: settings),
      ],
      child: MaterialApp(
        title: 'Cabinet88',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        // The CRT overlay is applied once, over every route (hard rule 5). No
        // screen builds one of its own.
        builder: (BuildContext context, Widget? child) =>
            CrtOverlay(child: child ?? const SizedBox.shrink()),
        home: const HomeScreen(),
      ),
    );
  }
}
