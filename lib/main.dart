import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // 1. Import AdMob
import 'providers/calculator_provider.dart';
import 'theme/app_colors.dart';
import 'screens/main_nav_screen.dart';

void main() {
  // 2. We must ensure the engine is ready before initializing ads
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Initialize the Google Mobile Ads SDK
  MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
      ],
      child: MaterialApp(
        title: 'TripCost',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            background: AppColors.background,
          ),
          useMaterial3: true,
        ),
        home: const MainNavScreen(),
      ),
    );
  }
}