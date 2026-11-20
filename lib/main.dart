import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'view/auth/auth_page.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    await Future.delayed(const Duration(seconds: 2));

    runApp(MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const AuthPage(),
    ));
}