import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/trophy_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const Cabinet88App());
}

/// App entry. UI logic lives in the screens, not here.
class Cabinet88App extends StatelessWidget {
  const Cabinet88App({super.key});

  @override
  Widget build(BuildContext context) {
    // The one service the UI reads progress through. Phase 5 replaces the
    // implementation, not the seam.
    return Provider<TrophyService>.value(
      value: const SeededTrophyService(),
      child: MaterialApp(
        title: 'Cabinet88',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const HomeScreen(),
      ),
    );
  }
}
