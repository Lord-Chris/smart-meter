import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_meter/ui/shared/app_constants.dart';
import 'package:smart_meter/ui/views/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (context, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
            useMaterial3: true,
            cardTheme: CardTheme(
              color: Colors.grey.shade100,
              surfaceTintColor: Colors.grey.shade100,
            ),
          ),
          home: const HomeView(),
        );
      },
    );
  }
}


/// Smart Meter features: 
/// 1. Show current current(I) reading
/// 2. Show current voltage(V) reading
/// 3. Show current power(P) reading
/// 4. Max and Min Power reading
/// 5. Energy consumption in kWh for the last min, hour, day, week, month, year
/// 6. Cost of energy consumption in Naira for the last min, hour, day, week, month, year.
/// 7. Anomaly detection and alerting for the following: 