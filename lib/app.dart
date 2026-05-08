import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/gxbank/gxbank_entry_screen.dart';

class GXBuddyApp extends StatelessWidget {
  const GXBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GXBuddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const GXBankEntryScreen(),
    );
  }
}
