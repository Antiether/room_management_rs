import 'package:flutter/material.dart';
import '../models/cleaning_task.dart';
import '../services/hospital_state.dart';

class CleaningTrackerPanel extends StatelessWidget {
  final HospitalState state;

  const CleaningTrackerPanel({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final activeTasks = state.cleaningTasks.where((t) => !t.isCompleted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Panel Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.cleaning_services_rounded, size: 18, color: Color(0xFFD97706)),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sistem Pembersihan Kamar & Turnaround (EVS)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Sterilisasi dan penyiapan bed pasca pasien pulang/pindah',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: activeTasks.isNotEmpty
                      ? const Color(0xFFFFF7ED)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: activeTasks.isNotEmpty
                        ? const Color(0xFFFDBA74)
                        : const Color(0xFF86EFAC),
                  ),
                ),
                child: Text(
                  '${activeTasks.length} Tugas Aktif',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: activeTasks.isNotEmpty
                        ? const Color(0xFFC2410C)
                        : const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Active Tasks List
        Expanded(
          child: activeTasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sanitizer_outlined, size: 48, color: Color(0xFF10B981)),
                      const SizedBox(height: 8),
                      const Text(
                        'Semua kamar telah bersih & steril!',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kapasitas siap pakai: ${state.totalHospitalAvailable} tempat tidur',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: activeTasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final task = activeTasks[index];
                    return _buildTaskCard(context, task);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, CleaningTaskModel task) {
    final isInProgress = task.isInProgress;
    final progress = task.progress;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isInProgress ? const Color(0xFF38BDF8) : const Color(0xFFFDBA74),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isInProgress
                ? Colors.blue.withOpacity(0.06)
                : Colors.orange.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Room & Bed info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isInProgress ? const Color(0xFFE0F2FE) : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '${task.roomNumber} - ${task.bedCode}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isInProgress ? const Color(0xFF0369A1) : const Color(0xFFC2410C),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.wardName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isInProgress ? const Color(0xFFE0F2FE) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isInProgress ? '⏱️ Sedang Disteril' : '⚠️ Menunggu EVS',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isInProgress ? const Color(0xFF0284C7) : const Color(0xFFEA580C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Timer & Progress
          if (isInProgress) ...[
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Sisa: ${task.formattedRemaining}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0369A1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_pin, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  'Petugas: ${task.cleanerName}',
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569)),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    state.finishCleaning(bedId: task.bedId);
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 15),
                  label: const Text('Tandai Selesai & Siap Pakai'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                const Text(
                  'Durasi SOP Standar: 45 detik (demo)',
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    state.startCleaning(bedId: task.bedId);
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: const Text('Mulai Pembersihan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
