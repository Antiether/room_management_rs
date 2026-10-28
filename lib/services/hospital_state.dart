import 'dart:async';
import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/room_bed.dart';
import '../models/cleaning_task.dart';
import '../data/mock_data.dart';

class HospitalState extends ChangeNotifier {
  late List<WardModel> _wards;
  late WardModel _currentWard;
  late List<PatientModel> _waitingPatients;
  late List<CleaningTaskModel> _cleaningTasks;

  BedModel? _selectedBed;
  RoomModel? _selectedRoom;

  RoomClass? _filterRoomClass;
  BedStatus? _filterBedStatus;
  String _searchQuery = '';

  Timer? _cleaningTicker;

  HospitalState() {
    _initializeData();
    _startCleaningTicker();
  }

  void _initializeData() {
    _wards = MockData.getInitialWards();
    _currentWard = _wards.first;
    _waitingPatients = MockData.getInitialPatients();
    _cleaningTasks = MockData.getInitialCleaningTasks();
  }

  void _startCleaningTicker() {
    _cleaningTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool changed = false;
      for (final task in _cleaningTasks) {
        if (task.isInProgress && !task.isCompleted) {
          if (task.remainingSeconds > 0) {
            task.remainingSeconds -= 1;
            changed = true;
          } else {
            // Pembersihan otomatis selesai
            task.isCompleted = true;
            task.isInProgress = false;
            _markBedCleanInternal(task.bedId);
            changed = true;
          }
        }
      }
      if (changed) {
        notifyListeners();
      }
    });
  }

  void _markBedCleanInternal(String bedId) {
    for (final ward in _wards) {
      for (final room in ward.rooms) {
        for (final bed in room.beds) {
          if (bed.id == bedId) {
            bed.status = BedStatus.available;
            bed.currentPatient = null;
            bed.notes = 'Selesai disterilisasi & dibersihkan. Siap ditempati.';
            return;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _cleaningTicker?.cancel();
    super.dispose();
  }

  // Getters
  List<WardModel> get wards => _wards;
  WardModel get currentWard => _currentWard;
  List<PatientModel> get waitingPatients => _waitingPatients;
  List<CleaningTaskModel> get cleaningTasks => _cleaningTasks;
  BedModel? get selectedBed => _selectedBed;
  RoomModel? get selectedRoom => _selectedRoom;
  RoomClass? get filterRoomClass => _filterRoomClass;
  BedStatus? get filterBedStatus => _filterBedStatus;
  String get searchQuery => _searchQuery;

  // Global KPIs across the entire hospital
  int get totalHospitalBeds => _wards.fold(0, (sum, w) => sum + w.totalBeds);
  int get totalHospitalAvailable => _wards.fold(0, (sum, w) => sum + w.availableBeds);
  int get totalHospitalOccupied => _wards.fold(0, (sum, w) => sum + w.occupiedBeds);
  int get totalHospitalBooked => _wards.fold(0, (sum, w) => sum + w.bookedBeds);
  int get totalHospitalCleaning => _wards.fold(0, (sum, w) => sum + w.cleaningBeds);
  double get hospitalBOR => totalHospitalBeds == 0
      ? 0.0
      : (totalHospitalOccupied / totalHospitalBeds) * 100;

  int get urgentWaitingCount => _waitingPatients
      .where((p) => p.urgency == AdmissionUrgency.emergencyCito)
      .length;

  // Selection & Filters
  void selectWard(WardModel ward) {
    _currentWard = ward;
    _selectedBed = null;
    _selectedRoom = null;
    notifyListeners();
  }

  void selectBed(BedModel? bed, RoomModel? room) {
    _selectedBed = bed;
    _selectedRoom = room;
    notifyListeners();
  }

  void setRoomClassFilter(RoomClass? roomClass) {
    _filterRoomClass = roomClass;
    notifyListeners();
  }

  void setBedStatusFilter(BedStatus? status) {
    _filterBedStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  void resetFilters() {
    _filterRoomClass = null;
    _filterBedStatus = null;
    _searchQuery = '';
    notifyListeners();
  }

  // Actions: Booking Bed for Patient
  bool bookBed({
    required BedModel bed,
    required RoomModel room,
    required PatientModel patient,
    bool directCheckIn = false,
  }) {
    if (bed.status != BedStatus.available) {
      return false;
    }

    // Gender consistency check for multi-bed rooms
    if (room.beds.length > 1) {
      final existingGender = room.currentGenderOccupancy;
      if (existingGender != null && existingGender != patient.gender) {
        // Gender mismatch in multi-bed room
        // Still allow with override or warning, but flag it
      }
    }

    bed.status = directCheckIn ? BedStatus.occupied : BedStatus.booked;
    bed.currentPatient = patient;
    bed.lastStatusChange = DateTime.now();

    patient.status = directCheckIn ? PatientStatus.admitted : PatientStatus.booked;
    patient.assignedBedId = bed.id;
    patient.assignedRoomNumber = room.roomNumber;
    if (directCheckIn) {
      patient.admissionTime = DateTime.now();
    }

    _waitingPatients.removeWhere((p) => p.id == patient.id);

    // Refresh selection
    _selectedBed = bed;
    _selectedRoom = room;

    notifyListeners();
    return true;
  }

  // Action: Check-in patient already booked
  void checkInPatient(BedModel bed) {
    if (bed.status == BedStatus.booked && bed.currentPatient != null) {
      bed.status = BedStatus.occupied;
      bed.lastStatusChange = DateTime.now();
      bed.currentPatient!.status = PatientStatus.admitted;
      bed.currentPatient!.admissionTime = DateTime.now();
      notifyListeners();
    }
  }

  // Action: Discharge Patient / Release Bed
  void dischargePatient({
    required BedModel bed,
    required RoomModel room,
    required String wardName,
  }) {
    if (bed.currentPatient != null) {
      bed.currentPatient!.status = PatientStatus.discharged;
    }

    bed.status = BedStatus.needsCleaning;
    bed.currentPatient = null;
    bed.lastStatusChange = DateTime.now();
    bed.notes = 'Baru dikosongkan. Menunggu pembersihan oleh tim EVS.';

    // Create a new cleaning task
    final newTask = CleaningTaskModel(
      bedId: bed.id,
      roomNumber: room.roomNumber,
      wardName: wardName,
      bedCode: bed.code,
      cleanerName: 'Tim Kebersihan Siaga',
      requestedTime: DateTime.now(),
      durationSeconds: 45,
      remainingSeconds: 45,
      isInProgress: false,
    );

    _cleaningTasks.removeWhere((t) => t.bedId == bed.id);
    _cleaningTasks.insert(0, newTask);

    notifyListeners();
  }

  // Action: Start Cleaning Task
  void startCleaning({required String bedId, String cleanerName = 'Petugas EVS Siaga'}) {
    // Update task
    final taskIndex = _cleaningTasks.indexWhere((t) => t.bedId == bedId && !t.isCompleted);
    if (taskIndex != -1) {
      final task = _cleaningTasks[taskIndex];
      task.isInProgress = true;
      task.startedTime = DateTime.now();
      task.cleanerName = cleanerName;
    }

    // Update bed
    for (final ward in _wards) {
      for (final room in ward.rooms) {
        for (final bed in room.beds) {
          if (bed.id == bedId) {
            bed.status = BedStatus.cleaningInProgress;
            bed.cleanerName = cleanerName;
            bed.cleaningStartTime = DateTime.now();
            break;
          }
        }
      }
    }

    notifyListeners();
  }

  // Action: Finish Cleaning & Sterilization
  void finishCleaning({required String bedId}) {
    // Complete task
    for (final task in _cleaningTasks) {
      if (task.bedId == bedId) {
        task.isCompleted = true;
        task.isInProgress = false;
        task.remainingSeconds = 0;
      }
    }

    // Set bed to available
    _markBedCleanInternal(bedId);
    notifyListeners();
  }

  // Action: Add new emergency patient
  void registerNewPatient(PatientModel patient) {
    _waitingPatients.insert(0, patient);
    notifyListeners();
  }

  // Filtered rooms in current ward
  List<RoomModel> get filteredRooms {
    return _currentWard.rooms.where((room) {
      // Class filter
      if (_filterRoomClass != null && room.roomClass != _filterRoomClass) {
        return false;
      }

      // Status filter (room matches if ANY bed matches status)
      if (_filterBedStatus != null) {
        final hasMatchingBed = room.beds.any((b) => b.status == _filterBedStatus);
        if (!hasMatchingBed) return false;
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final matchRoom = room.roomNumber.toLowerCase().contains(_searchQuery) ||
            room.name.toLowerCase().contains(_searchQuery);
        final matchBed = room.beds.any((b) =>
            b.code.toLowerCase().contains(_searchQuery) ||
            (b.currentPatient?.name.toLowerCase().contains(_searchQuery) ?? false) ||
            (b.currentPatient?.noRM.toLowerCase().contains(_searchQuery) ?? false));
        if (!matchRoom && !matchBed) return false;
      }

      return true;
    }).toList();
  }
}
