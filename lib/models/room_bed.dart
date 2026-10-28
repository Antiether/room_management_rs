import 'package:flutter/material.dart';
import 'patient.dart';

enum BedStatus {
  available,           // Kosong & Siap Digunakan
  booked,              // Telah dibooking/dialokasikan, pasien menuju kamar
  occupied,            // Sedang digunakan pasien rawat inap
  needsCleaning,       // Kotor / Menunggu petugas kebersihan pasca checkout
  cleaningInProgress,  // Sedang dibersihkan (ada timer durasi)
  maintenance,         // Perbaikan / Rusak
}

enum RoomClass {
  kelas3,
  kelas2,
  kelas1,
  vip,
  vvip,
  icu,
}

class BedModel {
  final String id;
  final String code; // e.g., 'Bed A', 'Bed B', 'Bed C', 'Bed D'
  final String roomId;
  final String roomNumber;
  BedStatus status;
  PatientModel? currentPatient;
  DateTime? lastStatusChange;
  DateTime? cleaningStartTime;
  int cleaningDurationSeconds; // Durasi estimasi pembersihan (default misal 60 detik demo / 30 menit real)
  String? cleanerName;
  String? notes;

  BedModel({
    required this.id,
    required this.code,
    required this.roomId,
    required this.roomNumber,
    this.status = BedStatus.available,
    this.currentPatient,
    this.lastStatusChange,
    this.cleaningStartTime,
    this.cleaningDurationSeconds = 45,
    this.cleanerName,
    this.notes,
  });

  String get fullLabel => '$roomNumber - $code';

  String get statusLabel {
    switch (status) {
      case BedStatus.available:
        return 'Kosong & Siap';
      case BedStatus.booked:
        return 'Dibooking';
      case BedStatus.occupied:
        return 'Terisi';
      case BedStatus.needsCleaning:
        return 'Perlu Dibersihkan';
      case BedStatus.cleaningInProgress:
        return 'Sedang Dibersihkan';
      case BedStatus.maintenance:
        return 'Perbaikan';
    }
  }

  Color get statusColor {
    switch (status) {
      case BedStatus.available:
        return const Color(0xFF10B981); // Emerald
      case BedStatus.booked:
        return const Color(0xFFF59E0B); // Amber
      case BedStatus.occupied:
        return const Color(0xFFEF4444); // Red
      case BedStatus.needsCleaning:
        return const Color(0xFFEA580C); // Orange
      case BedStatus.cleaningInProgress:
        return const Color(0xFF0284C7); // Cyan/Sky blue
      case BedStatus.maintenance:
        return const Color(0xFF64748B); // Slate
    }
  }

  IconData get statusIcon {
    switch (status) {
      case BedStatus.available:
        return Icons.check_circle_outline;
      case BedStatus.booked:
        return Icons.bookmark_added_outlined;
      case BedStatus.occupied:
        return Icons.hotel_rounded;
      case BedStatus.needsCleaning:
        return Icons.cleaning_services_outlined;
      case BedStatus.cleaningInProgress:
        return Icons.hourglass_top_rounded;
      case BedStatus.maintenance:
        return Icons.build_outlined;
    }
  }
}

class RoomModel {
  final String id;
  final String roomNumber; // e.g. 'R.101', 'R.201', 'VIP-301'
  final String wardId;
  final String name;
  final RoomClass roomClass;
  final int floor;
  final List<BedModel> beds;
  final List<String> facilities; // ['AC', 'Oksigen Sentral', 'Kamar Mandi Dalam', 'Nurse Call', 'TV', 'Sofa']
  final double x; // Koordinat denah visual (grid position)
  final double y;
  final double width;
  final double height;

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.wardId,
    required this.name,
    required this.roomClass,
    required this.floor,
    required this.beds,
    required this.facilities,
    required this.x,
    required this.y,
    this.width = 240,
    this.height = 200,
  });

  int get totalBeds => beds.length;
  int get availableBeds => beds.where((b) => b.status == BedStatus.available).length;
  int get occupiedBeds => beds.where((b) => b.status == BedStatus.occupied).length;
  int get bookedBeds => beds.where((b) => b.status == BedStatus.booked).length;
  int get cleaningBeds => beds.where((b) => b.status == BedStatus.needsCleaning || b.status == BedStatus.cleaningInProgress).length;

  String get classLabel {
    switch (roomClass) {
      case RoomClass.kelas3:
        return 'Kelas 3 (KRIS)';
      case RoomClass.kelas2:
        return 'Kelas 2';
      case RoomClass.kelas1:
        return 'Kelas 1';
      case RoomClass.vip:
        return 'VIP';
      case RoomClass.vvip:
        return 'VVIP Suite';
      case RoomClass.icu:
        return 'ICU / Kritis';
    }
  }

  Color get classColor {
    switch (roomClass) {
      case RoomClass.kelas3:
        return const Color(0xFF0284C7); // Blue
      case RoomClass.kelas2:
        return const Color(0xFF0D9488); // Teal
      case RoomClass.kelas1:
        return const Color(0xFF4F46E5); // Indigo
      case RoomClass.vip:
        return const Color(0xFF9333EA); // Purple
      case RoomClass.vvip:
        return const Color(0xFFC026D3); // Fuchsia / Gold
      case RoomClass.icu:
        return const Color(0xFFBE123C); // Rose/Crimson
    }
  }

  /// Memeriksa pemisahan gender dalam kamar multi-bed
  /// Return: 'L' jika hanya diisi pria, 'P' jika hanya wanita, 'Campur'/null jika kosong
  String? get currentGenderOccupancy {
    final genders = beds
        .where((b) => b.currentPatient != null)
        .map((b) => b.currentPatient!.gender)
        .toSet();
    if (genders.isEmpty) return null;
    if (genders.length == 1) return genders.first;
    return 'Campur';
  }
}

class WardModel {
  final String id;
  final String name; // e.g. 'Gedung A - Rawat Inap Teratai'
  final String description;
  final int floor;
  final List<RoomModel> rooms;

  WardModel({
    required this.id,
    required this.name,
    required this.description,
    required this.floor,
    required this.rooms,
  });

  int get totalBeds => rooms.fold(0, (sum, room) => sum + room.totalBeds);
  int get availableBeds => rooms.fold(0, (sum, room) => sum + room.availableBeds);
  int get occupiedBeds => rooms.fold(0, (sum, room) => sum + room.occupiedBeds);
  int get bookedBeds => rooms.fold(0, (sum, room) => sum + room.bookedBeds);
  int get cleaningBeds => rooms.fold(0, (sum, room) => sum + room.cleaningBeds);
  double get occupancyRate => totalBeds == 0 ? 0 : (occupiedBeds / totalBeds) * 100;
}
