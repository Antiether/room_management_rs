import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/room_bed.dart';
import '../services/hospital_state.dart';

class BedActionDialog extends StatefulWidget {
  final BedModel bed;
  final RoomModel room;
  final HospitalState state;
  final PatientModel? preselectedPatient;

  const BedActionDialog({
    super.key,
    required this.bed,
    required this.room,
    required this.state,
    this.preselectedPatient,
  });

  @override
  State<BedActionDialog> createState() => _BedActionDialogState();
}

class _BedActionDialogState extends State<BedActionDialog> {
  PatientModel? _selectedPatient;

  @override
  void initState() {
    super.initState();
    _selectedPatient = widget.preselectedPatient;
  }

  @override
  Widget build(BuildContext context) {
    final bed = widget.bed;
    final room = widget.room;
    final state = widget.state;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Room & Bed info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bed.statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(bed.statusIcon, color: bed.statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${room.roomNumber} - ${bed.code}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: room.classColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                room.classLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: room.classColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${room.name} • Lt. ${room.floor} • ${bed.statusLabel}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: bed.statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Content based on Bed Status
              if (bed.status == BedStatus.available) ...[
                _buildAvailableBookingSection(context, state),
              ] else if (bed.status == BedStatus.occupied) ...[
                _buildOccupiedSection(context, state),
              ] else if (bed.status == BedStatus.booked) ...[
                _buildBookedSection(context, state),
              ] else if (bed.status == BedStatus.needsCleaning ||
                  bed.status == BedStatus.cleaningInProgress) ...[
                _buildCleaningSection(context, state),
              ] else ...[
                const Text('Bed dalam pemeliharaan/maintenance.'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 1. Available -> Booking / Check-in
  Widget _buildAvailableBookingSection(BuildContext context, HospitalState state) {
    final waiting = state.waitingPatients;
    final room = widget.room;
    final bed = widget.bed;

    // Multi-bed gender validation
    final existingGender = room.currentGenderOccupancy;
    bool hasGenderWarning = false;
    if (_selectedPatient != null && existingGender != null && existingGender != 'Campur') {
      if (_selectedPatient!.gender != existingGender) {
        hasGenderWarning = true;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Pilih Pasien dari Antrean Pendaftaran:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),

        if (waiting.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tidak ada pasien di antrean. Anda dapat menambahkan pasien baru dari panel antrean.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCBD5E1)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<PatientModel>(
                isExpanded: true,
                value: _selectedPatient,
                hint: const Text('Pilih pasien untuk ditempatkan...'),
                items: waiting.map((patient) {
                  return DropdownMenuItem<PatientModel>(
                    value: patient,
                    child: Row(
                      children: [
                        Text(patient.gender == 'L' ? '👨' : '👩'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${patient.name} (${patient.noRM}) - ${patient.paymentCategoryLabel}',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (patient.urgency == AdmissionUrgency.emergencyCito)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'CITO',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (p) {
                  setState(() {
                    _selectedPatient = p;
                  });
                },
              ),
            ),
          ),

        if (_selectedPatient != null) ...[
          const SizedBox(height: 12),
          // Patient Detail Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _selectedPatient!.name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _selectedPatient!.paymentCategoryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selectedPatient!.paymentCategoryLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _selectedPatient!.paymentCategoryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Diagnosis: ${_selectedPatient!.diagnosis}',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                ),
                Text(
                  'Asal: ${_selectedPatient!.admissionSource} • Usia: ${_selectedPatient!.age} tahun',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          // Gender Warning Alert if applicable
          if (hasGenderWarning) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, color: Color(0xFFDC2626), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Peringatan Bangsal: Ruangan ini telah ditempati pasien ${existingGender == "L" ? "Laki-laki" : "Perempuan"}. Harap perhatikan kepatuhan pemisahan gender.',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],

        const SizedBox(height: 18),
        // Action Buttons: Booking (Hotel style) vs Direct Check-in
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectedPatient == null
                    ? null
                    : () {
                        state.bookBed(
                          bed: bed,
                          room: room,
                          patient: _selectedPatient!,
                          directCheckIn: false,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Bed ${bed.fullLabel} berhasil dibooking untuk ${_selectedPatient!.name}',
                            ),
                            backgroundColor: const Color(0xFFD97706),
                          ),
                        );
                      },
                icon: const Icon(Icons.bookmark_added_outlined, size: 16),
                label: const Text('Booking (Reservasi)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: const Color(0xFFD97706),
                  side: const BorderSide(color: Color(0xFFD97706)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectedPatient == null
                    ? null
                    : () {
                        state.bookBed(
                          bed: bed,
                          room: room,
                          patient: _selectedPatient!,
                          directCheckIn: true,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Pasien ${_selectedPatient!.name} langsung Check-in di ${bed.fullLabel}',
                            ),
                            backgroundColor: const Color(0xFF0F766E),
                          ),
                        );
                      },
                icon: const Icon(Icons.hotel_rounded, size: 16),
                label: const Text('Langsung Check-in'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Occupied -> Details & Discharge (Triggers EVS Cleaning)
  Widget _buildOccupiedSection(BuildContext context, HospitalState state) {
    final patient = widget.bed.currentPatient;
    if (patient == null) return const Text('Tidak ada data pasien.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFCA5A5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${patient.gender == "L" ? "👨" : "👩"} ${patient.name}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    patient.noRM,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7F1D1D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Diagnosis: ${patient.diagnosis}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF450A0A))),
              Text('Kategori: ${patient.paymentCategoryLabel} • Usia: ${patient.age} th',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF7F1D1D))),
              Text('Asal Masuk: ${patient.admissionSource}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Alur Pasien Selesai / Pindah Kamar:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ketika pasien checkout atau pindah kamar, sistem akan secara otomatis mengosongkan bed dan mengaktifkan status "Perlu Pembersihan" agar tim kebersihan (EVS) segera mensterilkan ruangan.',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            state.dischargePatient(
              bed: widget.bed,
              room: widget.room,
              wardName: state.currentWard.name,
            );
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Pasien ${patient.name} telah checkout. Bed ${widget.bed.fullLabel} sekarang masuk antrean pembersihan EVS!',
                ),
                backgroundColor: const Color(0xFFEA580C),
              ),
            );
          },
          icon: const Icon(Icons.output_rounded, size: 18),
          label: const Text('Pasien Pulang / Checkout (Mulai Alur Pembersihan)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  // 3. Booked -> Confirm Check-in
  Widget _buildBookedSection(BuildContext context, HospitalState state) {
    final patient = widget.bed.currentPatient;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFCD34D)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Telah dibooking untuk: ${patient?.name ?? "-"}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF92400E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pasien sedang dalam proses administrasi / perjalanan dari ${patient?.admissionSource ?? "IGD"}.',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF78350F)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            state.checkInPatient(widget.bed);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Pasien ${patient?.name} berhasil Check-in di Bed ${widget.bed.fullLabel}!',
                ),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          },
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('Konfirmasi Pasien Tiba (Check-in Sekarang)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  // 4. Cleaning -> Start or finish cleaning
  Widget _buildCleaningSection(BuildContext context, HospitalState state) {
    final isCleaning = widget.bed.status == BedStatus.cleaningInProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCleaning ? const Color(0xFFE0F2FE) : const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCleaning ? const Color(0xFF7DD3FC) : const Color(0xFFFDBA74),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCleaning
                    ? 'Bed Sedang Disterilisasi oleh Tim EVS'
                    : 'Bed Kotor - Menunggu Pembersihan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isCleaning ? const Color(0xFF0369A1) : const Color(0xFFC2410C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isCleaning
                    ? 'Petugas ${widget.bed.cleanerName ?? "EVS"} sedang melakukan disinfeksi tempat tidur & penggantian linen.'
                    : 'Kamar telah dikosongkan. Perlu tindakan disinfeksi sebelum dapat ditempati pasien baru.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: isCleaning ? const Color(0xFF075985) : const Color(0xFF9A3412),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (!isCleaning)
          ElevatedButton.icon(
            onPressed: () {
              state.startCleaning(bedId: widget.bed.id);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text('Mulai Proses Pembersihan (Start Cleaning)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: () {
              state.finishCleaning(bedId: widget.bed.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Bed ${widget.bed.fullLabel} selesai disterilkan dan siap dipakai!',
                  ),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Selesaikan Pembersihan (Tandai Siap Pakai)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
      ],
    );
  }
}
