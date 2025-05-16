import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart'; 
import 'package:flutter/foundation.dart' show kIsWeb;
import 'services/firebase_service.dart';

import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/customer_home_page.dart';
import 'pages/driver_home_page.dart';
import 'pages/place_order_page.dart';
import 'pages/order_confirmation_page.dart';
import 'pages/order_list_page.dart';
import 'pages/profile_page.dart';
import 'models/user_model.dart';
import 'models/order_model.dart';
import 'utils/app_constants.dart';
// Temporarily commented out Firebase
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_patches.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase services
  await FirebaseServiceLocator.instance.initialize();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ByPass App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppConstants.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          primary: AppConstants.primaryColor,
          secondary: AppConstants.secondaryColor,
          tertiary: AppConstants.tertiaryColor,
        ),
        useMaterial3: true,
        
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppConstants.primaryButtonStyle,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/customer_home': (context) => const CustomerHomePage(),
        '/driver_home': (context) => const DriverHomePage(),
        '/place_order': (context) => const PlaceOrderPage(),
        '/orders': (context) => const OrderListPage(),
        '/profile': (context) => const ProfilePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/order_confirmation') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => OrderConfirmationPage(orderData: args),
          );
        }
        return null;
      },
    );
  }
}
