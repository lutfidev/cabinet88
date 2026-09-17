import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

void main() {
  runApp(const Cabinet88App());
}

/// App entry. Screens arrive in phase 2 — this holds nothing but the shell.
class Cabinet88App extends StatelessWidget {
  const Cabinet88App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cabinet88',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const Scaffold(),
    );
  }
}
