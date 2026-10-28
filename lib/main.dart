import 'package:flutter/material.dart';
import 'services/hospital_state.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final hospitalState = HospitalState();
  runApp(HospitalRoomManagementApp(hospitalState: hospitalState));
}

class HospitalRoomManagementApp extends StatelessWidget {
  final HospitalState hospitalState;

  const HospitalRoomManagementApp({super.key, required this.hospitalState});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmarterBMS - Hospital Bed & Room Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E), // Teal medical primary color
          primary: const Color(0xFF0F766E),
          secondary: const Color(0xFF0284C7),
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        fontFamily: 'Segoe UI',
      ),
      home: HomeScreen(hospitalState: hospitalState),
    );
  }
}
