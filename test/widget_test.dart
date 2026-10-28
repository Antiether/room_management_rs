import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:room_management/main.dart';
import 'package:room_management/services/hospital_state.dart';

void main() {
  testWidgets('Hospital BMS - Desktop and Squeezed Mobile Viewport Test', (WidgetTester tester) async {
    final state = HospitalState();

    // 1. Test Desktop Screen (width: 1280)
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(HospitalRoomManagementApp(hospitalState: state));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('SmarterBMS'), findsOneWidget);
    expect(find.text('Antrean Pendaftaran'), findsOneWidget);

    // 2. Squeeze Window to Mobile Viewport (width: 400 - like mobile browser or smartphone app)
    tester.view.physicalSize = const Size(400, 840);
    await tester.pumpWidget(HospitalRoomManagementApp(hospitalState: state));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('SmarterBMS'), findsOneWidget);
    expect(find.text('Denah Spasial'), findsOneWidget);
    expect(find.text('Daftar Kamar'), findsOneWidget);

    // 3. Switch to "Daftar Kamar" mode on mobile
    await tester.tap(find.text('Daftar Kamar'));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify room numbers are visible in list mode
    expect(find.text('R.101'), findsOneWidget);

    // 4. Switch to Antrean Pasien tab on mobile bottom bar
    await tester.tap(find.byIcon(Icons.people_alt_outlined));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Antrean Pendaftaran'), findsOneWidget);

    state.dispose();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
