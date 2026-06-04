import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:firebase_messaging/firebase_messaging.dart'; 
import 'firebase_options.dart';
import 'core/network/network_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screen/splash_screen.dart';

// Background message handler (Must be outside of any class)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  // Required for Flutter to initialize properly before runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  // WAKE UP FIREBASE
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print("Firebase initialization failed. Check if google-services.json is added. Error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
      ],
      child: const TransportApp(),
    ),
  );
}

class TransportApp extends StatelessWidget {
  const TransportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pemeyaan Transport',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}