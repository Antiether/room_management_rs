import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/room_bed.dart';
import '../services/hospital_state.dart';
import '../widgets/kpi_summary_bar.dart';
import '../widgets/ward_map_canvas.dart';
import '../widgets/patient_queue_panel.dart';
import '../widgets/cleaning_tracker_panel.dart';
import '../widgets/bed_action_dialog.dart';
import '../widgets/new_patient_dialog.dart';
import '../widgets/research_info_dialog.dart';

class DesktopLayout extends StatefulWidget {
  final HospitalState state;

  const DesktopLayout({super.key, required this.state});

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> with SingleTickerProviderStateMixin {
  late TabController _sidebarTabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sidebarTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _sidebarTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openBedActionDialog(BedModel bed, RoomModel room, [PatientModel? patient]) {
    showDialog(
      context: context,
      builder: (context) => BedActionDialog(
        bed: bed,
        room: room,
        state: widget.state,
        preselectedPatient: patient,
      ),
    );
  }

  void _openNewPatientDialog() {
    showDialog(
      context: context,
      builder: (context) => NewPatientDialog(state: widget.state),
    );
  }

  void _openResearchDialog() {
    showDialog(
      context: context,
      builder: (context) => const ResearchInfoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          // Top Navigation Bar
          _buildTopNavbar(context, state),

          // KPI & BOR Summary Bar
          KpiSummaryBar(state: state),

          // Main Workspace: Map Canvas + Right Sidebar
          Expanded(
            child: Row(
              children: [
                // Interactive Ward Canvas
                Expanded(
                  child: WardMapCanvas(
                    state: state,
                    onBedTapped: (bed, room) {
                      _openBedActionDialog(bed, room);
                    },
                  ),
                ),

                // Right Sidebar: Patient Queue & EVS Cleaning
                Container(
                  width: 380,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(left: BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                  child: Column(
                    children: [
                      // Sidebar Tab Header
                      Container(
                        color: const Color(0xFFF8FAFC),
                        child: TabBar(
                          controller: _sidebarTabController,
                          labelColor: const Color(0xFF0F766E),
                          unselectedLabelColor: const Color(0xFF64748B),
                          indicatorColor: const Color(0xFF0F766E),
                          indicatorWeight: 3,
                          tabs: [
                            Tab(
                              icon: const Icon(Icons.people_alt_outlined, size: 18),
                              text: 'Antrean Pasien (${state.waitingPatients.length})',
                            ),
                            Tab(
                              icon: const Icon(Icons.cleaning_services_outlined, size: 18),
                              text: 'Pembersihan EVS (${state.cleaningTasks.where((t) => !t.isCompleted).length})',
                            ),
                          ],
                        ),
                      ),

                      // Sidebar Tab Views
                      Expanded(
                        child: TabBarView(
                          controller: _sidebarTabController,
                          children: [
                            PatientQueuePanel(
                              state: state,
                              onAssignPatient: (patient) {
                                // Prompt user to pick an available bed or pick the first available
                                final availableBed = state.currentWard.rooms
                                    .expand((r) => r.beds)
                                    .firstWhere(
                                      (b) => b.status == BedStatus.available,
                                      orElse: () => state.currentWard.rooms.first.beds.first,
                                    );
                                final room = state.currentWard.rooms.firstWhere(
                                  (r) => r.beds.any((b) => b.id == availableBed.id),
                                );
                                _openBedActionDialog(availableBed, room, patient);
                              },
                              onAddNewPatient: _openNewPatientDialog,
                            ),
                            CleaningTrackerPanel(state: state),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavbar(BuildContext context, HospitalState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Dark slate navy
        border: Border(bottom: BorderSide(color: Color(0xFF334155))),
      ),
      child: Row(
        children: [
          // App Logo & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SmarterBMS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Sistem Manajemen Kamar & Bed RS (Rawat Inap & BPJS)',
                    style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 24),

          // Ward Switcher Tabs
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: state.wards.map((ward) {
                  final isSelected = state.currentWard.id == ward.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: () => state.selectWard(ward),
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF334155),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.meeting_room_rounded,
                              size: 15,
                              color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              ward.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0284C7)
                                    : const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${ward.availableBeds} Siap',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Class Filter Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<RoomClass?>(
                dropdownColor: const Color(0xFF1E293B),
                value: state.filterRoomClass,
                hint: const Text('Filter Kelas Kamar',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                style: const TextStyle(color: Colors.white, fontSize: 12),
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF94A3B8)),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Semua Kelas')),
                  ...RoomClass.values.map(
                    (rc) => DropdownMenuItem(
                      value: rc,
                      child: Text(_getRoomClassLabel(rc)),
                    ),
                  ),
                ],
                onChanged: (val) => state.setRoomClassFilter(val),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Search Box
          SizedBox(
            width: 200,
            height: 36,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Cari kamar / bed / RM...',
                hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF94A3B8)),
                suffixIcon: state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 14, color: Color(0xFF94A3B8)),
                        onPressed: () {
                          _searchController.clear();
                          state.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                ),
              ),
              onChanged: (val) => state.setSearchQuery(val),
            ),
          ),
          const SizedBox(width: 12),

          // Research & Literature Button
          IconButton(
            tooltip: 'Dasar Teori & Penelitian Terdahulu',
            icon: const Icon(Icons.school_outlined, color: Color(0xFF38BDF8), size: 20),
            onPressed: _openResearchDialog,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  String _getRoomClassLabel(RoomClass rc) {
    switch (rc) {
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
}
