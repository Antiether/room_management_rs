import 'package:flutter/material.dart';

enum PaymentCategory {
  bpjsKelas1,
  bpjsKelas2,
  bpjsKelas3,
  umumMandiri,
  asuransiSwasta,
}

enum AdmissionUrgency {
  emergencyCito,
  electiveBiasa,
  transferInternal,
}

enum PatientStatus {
  waitingAdmission,
  booked,
  admitted,
  discharged,
}

class PatientModel {
  final String id;
  final String noRM; // Nomor Rekam Medis (e.g. RM-2026-0812)
  final String name;
  final int age;
  final String gender; // 'L' (Laki-laki) or 'P' (Perempuan)
  final String diagnosis;
  final PaymentCategory paymentCategory;
  final String bpjsCardNumber;
  final AdmissionUrgency urgency;
  final String admissionSource; // 'IGD', 'Poliklinik Penyakit Dalam', 'Rujukan Luar'
  PatientStatus status;
  String? assignedBedId;
  String? assignedRoomNumber;
  DateTime? admissionTime;

  PatientModel({
    required this.id,
    required this.noRM,
    required this.name,
    required this.age,
    required this.gender,
    required this.diagnosis,
    required this.paymentCategory,
    this.bpjsCardNumber = '',
    required this.urgency,
    required this.admissionSource,
    this.status = PatientStatus.waitingAdmission,
    this.assignedBedId,
    this.assignedRoomNumber,
    this.admissionTime,
  });

  String get paymentCategoryLabel {
    switch (paymentCategory) {
      case PaymentCategory.bpjsKelas1:
        return 'BPJS Kelas 1';
      case PaymentCategory.bpjsKelas2:
        return 'BPJS Kelas 2';
      case PaymentCategory.bpjsKelas3:
        return 'BPJS Kelas 3 (KRIS)';
      case PaymentCategory.umumMandiri:
        return 'Pasien Umum (Mandiri)';
      case PaymentCategory.asuransiSwasta:
        return 'Asuransi Swasta';
    }
  }

  String get shortPaymentLabel {
    switch (paymentCategory) {
      case PaymentCategory.bpjsKelas1:
        return 'BPJS-1';
      case PaymentCategory.bpjsKelas2:
        return 'BPJS-2';
      case PaymentCategory.bpjsKelas3:
        return 'BPJS-3';
      case PaymentCategory.umumMandiri:
        return 'UMUM';
      case PaymentCategory.asuransiSwasta:
        return 'ASURANSI';
    }
  }

  Color get paymentCategoryColor {
    switch (paymentCategory) {
      case PaymentCategory.bpjsKelas1:
      case PaymentCategory.bpjsKelas2:
      case PaymentCategory.bpjsKelas3:
        return const Color(0xFF0D9488); // Teal for BPJS Kesehatan
      case PaymentCategory.umumMandiri:
        return const Color(0xFF3B82F6); // Blue for Umum
      case PaymentCategory.asuransiSwasta:
        return const Color(0xFF8B5CF6); // Purple for Insurance
    }
  }

  String get urgencyLabel {
    switch (urgency) {
      case AdmissionUrgency.emergencyCito:
        return 'CITO / Darurat IGD';
      case AdmissionUrgency.electiveBiasa:
        return 'Elektif / Terencana';
      case AdmissionUrgency.transferInternal:
        return 'Perpindahan Ruangan';
    }
  }

  Color get urgencyColor {
    switch (urgency) {
      case AdmissionUrgency.emergencyCito:
        return const Color(0xFFDC2626); // Red
      case AdmissionUrgency.electiveBiasa:
        return const Color(0xFF0284C7); // Sky blue
      case AdmissionUrgency.transferInternal:
        return const Color(0xFFD97706); // Amber
    }
  }
}
