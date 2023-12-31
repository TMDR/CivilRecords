import 'package:flutter/material.dart';
import 'login/login_page.dart';
import 'values/app_constants.dart';
import 'values/app_routes.dart';
import 'values/app_theme.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Civil Records',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.loginScreen,
      navigatorKey: AppConstants.navigationKey,
      routes: {AppRoutes.loginScreen: (context) => const LoginPage()},
    );
  }
}
