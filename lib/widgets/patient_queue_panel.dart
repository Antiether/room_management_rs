import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/hospital_state.dart';

class PatientQueuePanel extends StatefulWidget {
  final HospitalState state;
  final Function(PatientModel patient) onAssignPatient;
  final VoidCallback onAddNewPatient;

  const PatientQueuePanel({
    super.key,
    required this.state,
    required this.onAssignPatient,
    required this.onAddNewPatient,
  });

  @override
  State<PatientQueuePanel> createState() => _PatientQueuePanelState();
}

class _PatientQueuePanelState extends State<PatientQueuePanel> {
  String _filter = 'all'; // 'all', 'cito', 'bpjs', 'umum'

  @override
  Widget build(BuildContext context) {
    final patients = widget.state.waitingPatients.where((p) {
      if (_filter == 'cito') {
        return p.urgency == AdmissionUrgency.emergencyCito;
      }
      if (_filter == 'bpjs') {
        return p.paymentCategory == PaymentCategory.bpjsKelas1 ||
            p.paymentCategory == PaymentCategory.bpjsKelas2 ||
            p.paymentCategory == PaymentCategory.bpjsKelas3;
      }
      if (_filter == 'umum') {
        return p.paymentCategory == PaymentCategory.umumMandiri ||
            p.paymentCategory == PaymentCategory.asuransiSwasta;
      }
      return true;
    }).toList();

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.people_alt_rounded, size: 20, color: Color(0xFF0F172A)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Antrean Pendaftaran',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${patients.length} Menunggu',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3730A3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Semua', 'all'),
                    const SizedBox(width: 6),
                    _buildFilterChip('🚨 CITO / IGD', 'cito'),
                    const SizedBox(width: 6),
                    _buildFilterChip('BPJS', 'bpjs'),
                    const SizedBox(width: 6),
                    _buildFilterChip('Umum / Asuransi', 'umum'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List of Patients
        Expanded(
          child: patients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      const Text(
                        'Semua antrean pasien telah dialokasikan!',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: patients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return _buildPatientCard(patient);
                  },
                ),
        ),

        // Bottom Add Patient Button
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: ElevatedButton.icon(
            onPressed: widget.onAddNewPatient,
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
            label: const Text('+ Pendaftaran Pasien Masuk Baru (IGD/Poli)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _filter = value;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientCard(PatientModel patient) {
    final isCito = patient.urgency == AdmissionUrgency.emergencyCito;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCito ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
          width: isCito ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isCito
                ? Colors.red.withOpacity(0.06)
                : Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Urgency badge & No RM
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: patient.urgencyColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    patient.urgencyLabel,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: patient.urgencyColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  patient.noRM,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Patient Name, Gender, Age
            Row(
              children: [
                Text(
                  patient.gender == 'L' ? '👨' : '👩',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    patient.name,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                Text(
                  '${patient.age} Tahun',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Diagnosis
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.medical_services_outlined, size: 13, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    patient.diagnosis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Bottom Info: Payment Category, Source, and Action Button
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: patient.paymentCategoryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: patient.paymentCategoryColor.withOpacity(0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          patient.paymentCategoryLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: patient.paymentCategoryColor,
                          ),
                        ),
                      ),
                      Text(
                        'Asal: ${patient.admissionSource}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => widget.onAssignPatient(patient),
                  icon: const Icon(Icons.bookmark_add_outlined, size: 14),
                  label: const Text('Pilih Bed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
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
        ),
      ),
    );
  }
}
