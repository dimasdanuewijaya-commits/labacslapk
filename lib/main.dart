import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:labtrack_pro/firebase_options.dart';
import 'package:labtrack_pro/theme/app_theme.dart';
import 'package:labtrack_pro/screens/login_screen.dart';
import 'package:labtrack_pro/screens/main_shell.dart';
import 'package:labtrack_pro/screens/swap_notifications_screen.dart';
import 'package:labtrack_pro/screens/new_swap_request_screen.dart';
import 'package:labtrack_pro/screens/select_shift_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const LabTrackProApp());
}

class LabTrackProApp extends StatelessWidget {
  const LabTrackProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabAssistant Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainShell(),
        '/notifications': (context) => const SwapNotificationsScreen(),
        '/new-swap': (context) => const NewSwapRequestScreen(),
        '/select-shift': (context) => const SelectShiftScreen(),
      },
    );
  }
}
