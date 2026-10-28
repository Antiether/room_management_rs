import 'package:flutter/material.dart';
import '../models/room_bed.dart';
import '../services/hospital_state.dart';

class BedTile extends StatelessWidget {
  final BedModel bed;
  final RoomModel room;
  final HospitalState state;
  final VoidCallback onTap;

  const BedTile({
    super.key,
    required this.bed,
    required this.room,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = state.selectedBed?.id == bed.id;
    final statusColor = bed.statusColor;

    // Search active cleaning task for this bed to show countdown
    final cleaningTask = state.cleaningTasks
        .cast<dynamic>()
        .firstWhere((t) => t.bedId == bed.id && !t.isCompleted, orElse: () => null);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? statusColor.withOpacity(0.18)
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? statusColor : statusColor.withOpacity(0.4),
              width: isSelected ? 2.0 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? statusColor.withOpacity(0.25)
                    : Colors.black.withOpacity(0.04),
                blurRadius: isSelected ? 6 : 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Bed Code + Status Pill
              Row(
                children: [
                  Icon(
                    bed.statusIcon,
                    size: 14,
                    color: statusColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      bed.code,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getShortStatus(bed.status),
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Body Content depending on status
              if (bed.status == BedStatus.occupied && bed.currentPatient != null) ...[
                // Occupied info
                Row(
                  children: [
                    Text(
                      bed.currentPatient!.gender == 'L' ? '👨' : '👩',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        bed.currentPatient!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: bed.currentPatient!.paymentCategoryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: bed.currentPatient!.paymentCategoryColor.withOpacity(0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        bed.currentPatient!.shortPaymentLabel,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          color: bed.currentPatient!.paymentCategoryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${bed.currentPatient!.age}th',
                      style: const TextStyle(
                        fontSize: 9.0,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ] else if (bed.status == BedStatus.booked && bed.currentPatient != null) ...[
                // Booked info
                Row(
                  children: [
                    const Icon(Icons.person_pin_circle_outlined, size: 13, color: Color(0xFFD97706)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        bed.currentPatient!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  'Transit dari: ${bed.currentPatient!.admissionSource}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFFB45309),
                  ),
                ),
              ] else if (bed.status == BedStatus.cleaningInProgress) ...[
                // Cleaning in progress countdown
                Row(
                  children: [
                    const SizedBox(
                      width: 11,
                      height: 11,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      cleaningTask != null
                          ? 'Sisa: ${cleaningTask.formattedRemaining}'
                          : 'Sedang disteril...',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  bed.cleanerName ?? 'Petugas EVS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF475569),
                  ),
                ),
              ] else if (bed.status == BedStatus.needsCleaning) ...[
                // Needs cleaning
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFEA580C)),
                    SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        'Menunggu Tim EVS',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC2410C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Klik untuk panggil kebersihan',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF9A3412),
                  ),
                ),
              ] else ...[
                // Available
                const Row(
                  children: [
                    Icon(Icons.add_task_rounded, size: 12, color: Color(0xFF10B981)),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Siap Pakai',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Klik utk booking',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getShortStatus(BedStatus status) {
    switch (status) {
      case BedStatus.available:
        return 'Siap';
      case BedStatus.booked:
        return 'Booking';
      case BedStatus.occupied:
        return 'Terisi';
      case BedStatus.needsCleaning:
        return 'Kotor';
      case BedStatus.cleaningInProgress:
        return 'EVS';
      case BedStatus.maintenance:
        return 'Rusak';
    }
  }
}
