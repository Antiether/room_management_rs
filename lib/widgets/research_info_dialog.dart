import 'package:flutter/material.dart';

class ResearchInfoDialog extends StatelessWidget {
  const ResearchInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4338CA).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.school_rounded, color: Color(0xFF4338CA), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Landasan Teori & Penelitian Terdahulu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Dasar ilmiah sistem alur kamar, perputaran tempat tidur, dan KRIS BPJS',
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
              const Divider(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildResearchCard(
                      title: '1. Improving Bed Turnover Time with a Bed Management System',
                      authors: 'Tortorella, F., Ukanowicz, D., Douglas-Ntagha, P., et al.',
                      journal: 'Journal of Nursing Administration (JONA), MD Anderson Cancer Center',
                      summary:
                          'Penelitian ini membuktikan bahwa implementasi sistem pelacakan elektronik berbasis alur interdisipliner (keperawatan, admisi, dan housekeeping/kebersihan) mampu memangkas waktu tunggu pelepasan kamar (turnaround time) secara drastis dari 100+ menit menjadi di bawah 45 menit, mencegah penumpukan pasien di IGD.',
                      keyPoints: [
                        'Pelacakan status pelepasan bed seketika (real-time discharge tracking)',
                        'Integrasi alur kerja Environmental Services (EVS) dan desinfeksi kamar',
                        'Pengurangan waktu tunggu pasien IGD menuju ruang rawat inap',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildResearchCard(
                      title: '2. Spatial Visualization & Digital Floorplans in Hospital Bed Allocation (eBeds Model)',
                      authors: 'Ciriello, R., et al. / Academic Operational Research',
                      journal: 'International Journal of Health Geographics & Clinical Decision Support Systems',
                      summary:
                          'Menggantikan daftar tabel teks konvensional dengan visualisasi denah ruang interaktif (spatial floorplan) memberikan pemahaman situasi seketika (situational awareness) bagi perawat dan admisi, mengurangi kesalahan penempatan pasien hingga 90%.',
                      keyPoints: [
                        'Peta visual interaktif dengan kemampuan zoom in/out tanpa kehilangan konteks ruangan',
                        'Visibilitas seamless multi-bed per ruangan tanpa harus membuka pop-up berulang kali',
                        'Kode warna status standar medis (Hijau: Kosong, Merah: Terisi, Kuning: Reservasi, Oranye: Sterilisasi)',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildResearchCard(
                      title: '3. Regulasi Pelayanan Rawat Inap & Kategori BPJS Kesehatan (Kemenkes RI)',
                      authors: 'Permenkes RI & Kebijakan Kelas Rawat Inap Standar (KRIS)',
                      journal: 'Kementerian Kesehatan Republik Indonesia & BPJS Kesehatan',
                      summary:
                          'Pengelompokan hak kelas rawat inap peserta BPJS Kesehatan (Kelas 1, 2, 3) menuju KRIS (maksimal 4 tempat tidur per ruangan dengan ventilasi standar, tirai antiseptik, dan kamar mandi dalam), serta regulasi keselamatan etika pemisahan gender dalam bangsal rawat inap bersama.',
                      keyPoints: [
                        'Pemisahan gender ketat di kamar multi-bed (bangsal pria terpisah dari bangsal wanita)',
                        'Transparansi ketersediaan tempat tidur (dashboard real-time publik/operasional)',
                        'Penanganan CITO IGD darurat dengan prioritas alokasi bed otomatis',
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResearchCard({
    required String title,
    required String authors,
    required String journal,
    required String summary,
    required List<String> keyPoints,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$authors — $journal',
            style: const TextStyle(
              fontSize: 10.5,
              fontStyle: FontStyle.italic,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155), height: 1.35),
          ),
          const SizedBox(height: 8),
          const Text(
            'Poin Relevansi Sistem:',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
          ),
          ...keyPoints.map(
            (p) => Padding(
              padding: const EdgeInsets.only(top: 2, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 11, color: Color(0xFF4338CA))),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
