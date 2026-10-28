import 'package:flutter/material.dart';
import '../services/hospital_state.dart';
import '../models/room_bed.dart';

class KpiSummaryBar extends StatelessWidget {
  final HospitalState state;
  final bool isCompact;

  const KpiSummaryBar({
    super.key,
    required this.state,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bor = state.hospitalBOR;

    // WHO / Kemenkes Standard for Bed Occupancy Rate (BOR):
    // Ideal: 60% - 85%
    // Overcrowded / Crisis: > 85%
    // Underutilized: < 60%
    Color borColor;
    String borStatus;
    if (bor > 85) {
      borColor = const Color(0xFFDC2626); // Red
      borStatus = 'Tinggi / Hampir Penuh';
    } else if (bor >= 60) {
      borColor = const Color(0xFF10B981); // Green
      borStatus = 'Ideal (Standar Kemenkes)';
    } else {
      borColor = const Color(0xFFF59E0B); // Amber
      borStatus = 'Rendah';
    }

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMiniKpi(
                label: 'Total',
                value: '${state.totalHospitalBeds}',
                color: Colors.blueGrey,
              ),
              const SizedBox(width: 8),
              _buildMiniKpi(
                label: 'Siap',
                value: '${state.totalHospitalAvailable}',
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              _buildMiniKpi(
                label: 'Terisi',
                value: '${state.totalHospitalOccupied}',
                color: const Color(0xFFEF4444),
              ),
              const SizedBox(width: 8),
              _buildMiniKpi(
                label: 'EVS',
                value: '${state.totalHospitalCleaning}',
                color: const Color(0xFFEA580C),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: borColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borColor.withOpacity(0.3)),
                ),
                child: Text(
                  'BOR ${bor.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: borColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildKpiCard(
            title: 'Total Bed',
            value: '${state.totalHospitalBeds}',
            subtitle: '${state.wards.length} Gedung Perawatan',
            icon: Icons.hotel_rounded,
            color: const Color(0xFF475569),
          ),
          _buildKpiCard(
            title: 'Kosong / Siap',
            value: '${state.totalHospitalAvailable}',
            subtitle: 'Bisa langsung dipesan',
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF10B981),
            isSelected: state.filterBedStatus == BedStatus.available,
            onTap: () => state.setBedStatusFilter(
              state.filterBedStatus == BedStatus.available ? null : BedStatus.available,
            ),
          ),
          _buildKpiCard(
            title: 'Terisi Pasien',
            value: '${state.totalHospitalOccupied}',
            subtitle: 'Sedang rawat inap',
            icon: Icons.personal_injury_outlined,
            color: const Color(0xFFEF4444),
            isSelected: state.filterBedStatus == BedStatus.occupied,
            onTap: () => state.setBedStatusFilter(
              state.filterBedStatus == BedStatus.occupied ? null : BedStatus.occupied,
            ),
          ),
          _buildKpiCard(
            title: 'Dibooking',
            value: '${state.totalHospitalBooked}',
            subtitle: 'Pasien transit/menuju kamar',
            icon: Icons.bookmark_added_outlined,
            color: const Color(0xFFF59E0B),
            isSelected: state.filterBedStatus == BedStatus.booked,
            onTap: () => state.setBedStatusFilter(
              state.filterBedStatus == BedStatus.booked ? null : BedStatus.booked,
            ),
          ),
          _buildKpiCard(
            title: 'Pembersihan EVS',
            value: '${state.totalHospitalCleaning}',
            subtitle: 'Perlu / sedang disterilisasi',
            icon: Icons.cleaning_services_rounded,
            color: const Color(0xFFEA580C),
            isSelected: state.filterBedStatus == BedStatus.needsCleaning ||
                state.filterBedStatus == BedStatus.cleaningInProgress,
            onTap: () => state.setBedStatusFilter(
              state.filterBedStatus == BedStatus.needsCleaning ? null : BedStatus.needsCleaning,
            ),
          ),
          // Bed Occupancy Rate Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: borColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        value: (bor / 100).clamp(0.0, 1.0),
                        strokeWidth: 4.5,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        color: borColor,
                      ),
                    ),
                    Text(
                      '${bor.toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: borColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'BOR (Bed Occupancy)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    Text(
                      borStatus,
                      style: TextStyle(
                        fontSize: 11,
                        color: borColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Antrean Pasien Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: state.urgentWaitingCount > 0
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: state.urgentWaitingCount > 0
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFF86EFAC),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  state.urgentWaitingCount > 0
                      ? Icons.warning_amber_rounded
                      : Icons.people_alt_outlined,
                  size: 20,
                  color: state.urgentWaitingCount > 0
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF16A34A),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${state.waitingPatients.length} Pasien Antre Bed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: state.urgentWaitingCount > 0
                            ? const Color(0xFF991B1B)
                            : const Color(0xFF166534),
                      ),
                    ),
                    if (state.urgentWaitingCount > 0)
                      Text(
                        '${state.urgentWaitingCount} CITO IGD Prioritas',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDC2626),
                        ),
                      )
                    else
                      const Text(
                        'Tidak ada antrean kritis',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniKpi({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.2),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.filter_alt, size: 14, color: color),
                    ],
                  ],
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
