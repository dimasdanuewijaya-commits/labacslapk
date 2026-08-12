import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:labtrack_pro/theme/app_theme.dart';
import 'package:labtrack_pro/screens/login_screen.dart';
import 'package:labtrack_pro/screens/main_shell.dart';


import 'package:labtrack_pro/screens/admin/admin_main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  final initialRoute = token != null ? '/main' : '/login';

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(LabTrackProApp(initialRoute: initialRoute));
}

class LabTrackProApp extends StatelessWidget {
  final String initialRoute;

  const LabTrackProApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabAssistant Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainShell(),
        '/admin_main': (context) => const AdminMainShell(),

      },
    );
  }
}
