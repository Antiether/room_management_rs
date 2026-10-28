import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/hospital_state.dart';

class NewPatientDialog extends StatefulWidget {
  final HospitalState state;

  const NewPatientDialog({super.key, required this.state});

  @override
  State<NewPatientDialog> createState() => _NewPatientDialogState();
}

class _NewPatientDialogState extends State<NewPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _sourceController = TextEditingController(text: 'IGD Emergency');

  String _gender = 'L';
  PaymentCategory _payment = PaymentCategory.bpjsKelas3;
  AdmissionUrgency _urgency = AdmissionUrgency.emergencyCito;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _diagnosisController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F766E).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.person_add_rounded, color: Color(0xFF0F766E), size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pendaftaran Pasien Masuk Rawat Inap',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Data pendaftaran baru dari IGD / Poliklinik',
                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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
                  const Divider(height: 20),

                  // Nama Pasien
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap Pasien *',
                      prefixIcon: Icon(Icons.badge_outlined, size: 20),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),

                  // Usia & Jenis Kelamin
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Usia (Tahun) *',
                            prefixIcon: Icon(Icons.cake_outlined, size: 20),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _gender,
                          decoration: const InputDecoration(
                            labelText: 'Jenis Kelamin *',
                            prefixIcon: Icon(Icons.wc_outlined, size: 20),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'L', child: Text('Laki-laki (L)')),
                            DropdownMenuItem(value: 'P', child: Text('Perempuan (P)')),
                          ],
                          onChanged: (v) => setState(() => _gender = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Diagnosis
                  TextFormField(
                    controller: _diagnosisController,
                    decoration: const InputDecoration(
                      labelText: 'Diagnosis Masuk *',
                      prefixIcon: Icon(Icons.healing_outlined, size: 20),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),

                  // Kategori Pembayaran (BPJS / Umum / Asuransi)
                  DropdownButtonFormField<PaymentCategory>(
                    initialValue: _payment,
                    decoration: const InputDecoration(
                      labelText: 'Kategori Penjamin / Pembayaran *',
                      prefixIcon: Icon(Icons.payment_outlined, size: 20),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: PaymentCategory.bpjsKelas3,
                        child: Text('BPJS Kesehatan - Kelas 3 (KRIS)'),
                      ),
                      DropdownMenuItem(
                        value: PaymentCategory.bpjsKelas2,
                        child: Text('BPJS Kesehatan - Kelas 2'),
                      ),
                      DropdownMenuItem(
                        value: PaymentCategory.bpjsKelas1,
                        child: Text('BPJS Kesehatan - Kelas 1'),
                      ),
                      DropdownMenuItem(
                        value: PaymentCategory.umumMandiri,
                        child: Text('Pasien Umum (Biaya Mandiri)'),
                      ),
                      DropdownMenuItem(
                        value: PaymentCategory.asuransiSwasta,
                        child: Text('Asuransi Swasta / Korporasi'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _payment = v!),
                  ),
                  const SizedBox(height: 12),

                  // Urgensi Masuk
                  DropdownButtonFormField<AdmissionUrgency>(
                    initialValue: _urgency,
                    decoration: const InputDecoration(
                      labelText: 'Tingkat Urgensi Masuk *',
                      prefixIcon: Icon(Icons.emergency_outlined, size: 20),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: AdmissionUrgency.emergencyCito,
                        child: Text('🚨 CITO / IGD Darurat Prioritas'),
                      ),
                      DropdownMenuItem(
                        value: AdmissionUrgency.electiveBiasa,
                        child: Text('📅 Elektif / Terencana Poliklinik'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _urgency = v!),
                  ),
                  const SizedBox(height: 18),

                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final randomRM = 'RM-2026-${(1000 + DateTime.now().millisecond).toString()}';
                        final newPatient = PatientModel(
                          id: 'PAT-${DateTime.now().millisecondsSinceEpoch}',
                          noRM: randomRM,
                          name: _nameController.text.trim(),
                          age: int.tryParse(_ageController.text.trim()) ?? 30,
                          gender: _gender,
                          diagnosis: _diagnosisController.text.trim(),
                          paymentCategory: _payment,
                          urgency: _urgency,
                          admissionSource: _sourceController.text.trim(),
                        );

                        widget.state.registerNewPatient(newPatient);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Pasien ${newPatient.name} ($randomRM) berhasil terdaftar di antrean!',
                            ),
                            backgroundColor: const Color(0xFF0F766E),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Simpan & Masukkan Antrean'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
