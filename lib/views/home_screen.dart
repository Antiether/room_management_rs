import 'package:flutter/material.dart';
import '../services/hospital_state.dart';
import 'desktop_layout.dart';
import 'mobile_layout.dart';

class HomeScreen extends StatelessWidget {
  final HospitalState hospitalState;

  const HomeScreen({super.key, required this.hospitalState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: hospitalState,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Adaptive Breakpoint: >= 900px uses Desktop/Website layout
            if (constraints.maxWidth >= 900) {
              return DesktopLayout(state: hospitalState);
            } else {
              return MobileLayout(state: hospitalState);
            }
          },
        );
      },
    );
  }
}
