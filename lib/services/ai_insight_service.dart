import '../models/room_bed.dart';

/// Offline demonstration insight generator.
///
/// This service intentionally makes no network requests and does not call an LLM.
/// It produces transparent, rule-based summaries from synthetic/mock bed data so
/// the demo works without a laptop server, API key, or internet connection.
class AiInsightResult {
  final String wardName;
  final double occupancyRate;
  final String riskLevel;
  final String summary;
  final List<String> recommendedActions;
  final List<String> limitations;
  final String model;

  const AiInsightResult({
    required this.wardName,
    required this.occupancyRate,
    required this.riskLevel,
    required this.summary,
    required this.recommendedActions,
    required this.limitations,
    required this.model,
  });
}

class AiInsightService {
  Future<AiInsightResult> generateInsight(WardModel ward) async {
    final beds = ward.rooms.expand((room) => room.beds).toList();
    final total = beds.length;
    final available = beds.where((b) => b.status == BedStatus.available).length;
    final occupied = beds.where((b) => b.status == BedStatus.occupied).length;
    final booked = beds.where((b) => b.status == BedStatus.booked).length;
    final cleaning = beds
        .where((b) => b.status == BedStatus.needsCleaning || b.status == BedStatus.cleaningInProgress)
        .length;
    final maintenance = beds.where((b) => b.status == BedStatus.maintenance).length;

    final bor = total == 0 ? 0.0 : occupied / total * 100.0;
    final operationallyUnavailable = booked + cleaning + maintenance;
    final risk = (bor >= 85 || available == 0)
        ? 'high'
        : (bor >= 70 || available <= 2 || cleaning + maintenance >= 3)
            ? 'moderate'
            : 'low';

    final actions = <String>[];
    if (cleaning > 0) {
      actions.add('Tinjau $cleaning bed yang berstatus perlu/sedang dibersihkan dan konfirmasi kesiapan dengan petugas terkait.');
    }
    if (booked > 0) {
      actions.add('Verifikasi $booked bed yang dibooking agar status reservasi dan estimasi kedatangan tetap akurat.');
    }
    if (maintenance > 0) {
      actions.add('Konfirmasi status $maintenance bed dalam perbaikan sebelum dihitung sebagai kapasitas yang dapat digunakan.');
    }
    if (available <= 2 && total > 0) {
      actions.add('Kapasitas siap pakai terbatas ($available bed). Koordinasikan dengan pengelola bangsal sebelum menerima penempatan baru.');
    }
    if (risk == 'high') {
      actions.add('Lakukan pengecekan kapasitas oleh staf berwenang dan ikuti prosedur eskalasi rumah sakit jika kebutuhan melebihi kapasitas.');
    } else if (risk == 'low') {
      actions.add('Lanjutkan pemantauan rutin dan pastikan perubahan status bed diperbarui oleh staf.');
    }
    if (actions.isEmpty) {
      actions.add('Periksa kembali status bed dan konfirmasi data dengan staf bangsal sebelum mengambil keputusan operasional.');
    }

    final summary = total == 0
        ? 'Bangsal ini belum memiliki data bed untuk dianalisis.'
        : 'Bangsal ${ward.name} memiliki $occupied dari $total bed berstatus terisi (BOR ${bor.toStringAsFixed(1)}%). '
            'Tercatat $available bed siap pakai, $booked dibooking, $cleaning perlu/menjalani pembersihan, dan $maintenance dalam perbaikan. '
            'Sebanyak $operationallyUnavailable bed sedang tidak berstatus siap pakai karena booking, pembersihan, atau perbaikan. '
            'Indikator demo menilai risiko kapasitas ${_riskText(risk)} berdasarkan aturan sederhana, bukan prediksi kebutuhan di masa depan.';

    return AiInsightResult(
      wardName: ward.name,
      occupancyRate: bor,
      riskLevel: risk,
      summary: summary,
      recommendedActions: actions,
      limitations: const [
        'Mode demo offline: hasil dibuat oleh aturan deterministik di perangkat, bukan respons LLM dan bukan prediksi tervalidasi.',
        'Data bersifat mock/sintetis. Jangan gunakan hasil ini untuk keputusan klinis atau operasional rumah sakit nyata.',
      ],
      model: 'Offline demo rules (tanpa LLM)',
    );
  }

  String _riskText(String risk) => switch (risk) {
        'high' => 'tinggi',
        'moderate' => 'sedang',
        _ => 'rendah',
      };
}
