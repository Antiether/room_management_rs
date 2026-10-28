import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/room_bed.dart';
import '../services/hospital_state.dart';
import '../widgets/kpi_summary_bar.dart';
import '../widgets/ward_map_canvas.dart';
import '../widgets/room_card.dart';
import '../widgets/patient_queue_panel.dart';
import '../widgets/cleaning_tracker_panel.dart';
import '../widgets/bed_action_dialog.dart';
import '../widgets/new_patient_dialog.dart';
import '../widgets/research_info_dialog.dart';

class MobileLayout extends StatefulWidget {
  final HospitalState state;

  const MobileLayout({super.key, required this.state});

  @override
  State<MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<MobileLayout> {
  int _currentIndex = 0;
  bool _isMapView = true; // true: Denah Spasial, false: Daftar Kamar (Grid)

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
    final activeCleaningCount = state.cleaningTasks.where((t) => !t.isCompleted).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 14,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
              'Sistem Manajemen Kamar & Bed RS',
              style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.school_outlined, size: 20),
            tooltip: 'Dasar Teori & Riset',
            onPressed: _openResearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, size: 20),
            tooltip: 'Pendaftaran Pasien Baru',
            onPressed: _openNewPatientDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Ward Switcher Horizontal Bar
          _buildWardSelectorBar(state),

          // Compact KPI Summary Bar
          KpiSummaryBar(state: state, isCompact: true),

          // Main Screen based on selected tab
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                // Tab 0: Kamar & Bed (With Map vs List toggle)
                _buildRoomsTab(state),

                // Tab 1: Antrean Pasien
                PatientQueuePanel(
                  state: state,
                  onAssignPatient: (patient) {
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

                // Tab 2: Cleaning Tasks
                CleaningTrackerPanel(state: state),

                // Tab 3: BOR & Info
                _buildInfoTab(state),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.meeting_room_outlined),
            selectedIcon: Icon(Icons.meeting_room_rounded),
            label: 'Kamar & Bed',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('${state.waitingPatients.length}'),
              child: const Icon(Icons.people_alt_outlined),
            ),
            selectedIcon: Badge(
              label: Text('${state.waitingPatients.length}'),
              child: const Icon(Icons.people_alt_rounded),
            ),
            label: 'Antrean Pasien',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('$activeCleaningCount'),
              child: const Icon(Icons.cleaning_services_outlined),
            ),
            selectedIcon: Badge(
              label: Text('$activeCleaningCount'),
              child: const Icon(Icons.cleaning_services_rounded),
            ),
            label: 'Pembersihan',
          ),
          const NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'BOR & Riset',
          ),
        ],
      ),
    );
  }

  Widget _buildWardSelectorBar(HospitalState state) {
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: state.wards.map((ward) {
            final isSelected = state.currentWard.id == ward.id;
            return Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: InkWell(
                onTap: () => state.selectWard(ward),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ward.name.split('-').last.trim(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${ward.availableBeds}',
                          style: const TextStyle(
                            fontSize: 9.5,
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
    );
  }

  Widget _buildRoomsTab(HospitalState state) {
    return Column(
      children: [
        // Mode Toggle Header (Denah Spasial vs Daftar Kamar)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: true,
                      icon: Icon(Icons.map_outlined, size: 16),
                      label: Text('Denah Spasial', style: TextStyle(fontSize: 11)),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      icon: Icon(Icons.view_agenda_outlined, size: 16),
                      label: Text('Daftar Kamar', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                  selected: {_isMapView},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _isMapView = newSelection.first;
                    });
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Body based on mode
        Expanded(
          child: _isMapView
              ? WardMapCanvas(
                  state: state,
                  isMobile: true,
                  onBedTapped: (bed, room) => _openBedActionDialog(bed, room),
                )
              : _buildRoomListMode(state),
        ),
      ],
    );
  }

  // Mobile Clean Room List Mode (Never overlaps, scrollable, perfect for phones)
  Widget _buildRoomListMode(HospitalState state) {
    final filteredRooms = state.filteredRooms;

    if (filteredRooms.isEmpty) {
      return const Center(
        child: Text('Tidak ada ruangan yang cocok dengan filter.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredRooms.length,
      itemBuilder: (context, index) {
        final room = filteredRooms[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: RoomCard(
            room: room,
            state: state,
            onBedSelected: (bed) => _openBedActionDialog(bed, room),
          ),
        );
      },
    );
  }

  Widget _buildInfoTab(HospitalState state) {
    final bor = state.hospitalBOR;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // BOR Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.pie_chart_outline_rounded, color: Color(0xFF0F766E)),
                    SizedBox(width: 8),
                    Text(
                      'Bed Occupancy Rate (BOR)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '${bor.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: bor > 85 ? Colors.red : const Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bor > 85
                                ? 'Kapasitas Hampir Penuh (>85%)'
                                : 'Tingkat Okupansi Ideal (60-85%)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: bor > 85 ? Colors.red : const Color(0xFF15803D),
                            ),
                          ),
                          const Text(
                            'Standar Kementerian Kesehatan RI & WHO',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (bor / 100).clamp(0.0, 1.0),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                  color: bor > 85 ? Colors.red : const Color(0xFF0F766E),
                  backgroundColor: const Color(0xFFE2E8F0),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Quick Research Banner
        Card(
          color: const Color(0xFFEEF2FF),
          child: ListTile(
            leading: const Icon(Icons.school_rounded, color: Color(0xFF4338CA)),
            title: const Text(
              'Dasar Riset & Literatur Ilmiah',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: const Text(
              'Tortorella (2013), Percell (2021), & Regulasi KRIS BPJS',
              style: TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openResearchDialog,
          ),
        ),
      ],
    );
  }
}
