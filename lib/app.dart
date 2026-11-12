import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme.dart';
import 'screens/doctors_screen.dart';

class MughayyirApp extends StatelessWidget {
  const MughayyirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'المُغير',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const DoctorsScreen(),
    );
  }
}
