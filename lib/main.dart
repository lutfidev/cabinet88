import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/audio_service.dart';
import 'services/haptic_service.dart';
import 'services/progress_service.dart';
import 'services/settings_service.dart';
import 'services/trophy_service.dart';
import 'theme/app_theme.dart';
import 'widgets/crt_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Settings are read before the first frame, so nothing renders with a
  // default it is about to replace — a scanline overlay that arrived one frame
  // late would flicker on every launch. Progress comes up with it, so no
  // screen shows a dash where a real best score exists.
  final SettingsService settings = SettingsService();
  final ProgressService progress = ProgressService();
  await Future.wait<void>(<Future<void>>[settings.load(), progress.load()]);
  runApp(Cabinet88App(settings: settings, progress: progress));
}

/// App entry. UI logic lives in the screens, not here.
class Cabinet88App extends StatelessWidget {
  const Cabinet88App({
    super.key,
    required this.settings,
    required this.progress,
  });

  final SettingsService settings;
  final ProgressService progress;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProgressService>.value(value: progress),
        ChangeNotifierProvider<SettingsService>.value(value: settings),
        // Feel, both halves of it. Each reads its own switch at the moment of
        // the call, so a toggle needs no rebuild to take effect.
        Provider<HapticService>(
          create: (BuildContext context) =>
              HapticService(context.read<SettingsService>()),
        ),
        Provider<AudioService>(
          create: (BuildContext context) =>
              AudioService(context.read<SettingsService>()),
          dispose: (BuildContext _, AudioService audio) => audio.dispose(),
        ),
        // Every trophy is derived, never stored, so the service is rebuilt
        // whenever progress moves and the case updates with it.
        ProxyProvider<ProgressService, TrophyService>(
          update: (BuildContext _, ProgressService stored, TrophyService? _) =>
              ProgressTrophyService(stored),
        ),
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
