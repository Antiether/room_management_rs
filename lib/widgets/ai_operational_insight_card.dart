import 'package:flutter/material.dart';
import '../models/room_bed.dart';
import '../services/ai_insight_service.dart';

class AiOperationalInsightCard extends StatefulWidget {
  final WardModel ward;
  const AiOperationalInsightCard({super.key, required this.ward});

  @override
  State<AiOperationalInsightCard> createState() => _AiOperationalInsightCardState();
}

class _AiOperationalInsightCardState extends State<AiOperationalInsightCard> {
  final AiInsightService _service = AiInsightService();
  AiInsightResult? _result;
  bool _loading = false;
  String? _error;

  Future<void> _generate() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _service.generateInsight(widget.ward);
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void didUpdateWidget(covariant AiOperationalInsightCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ward.id != widget.ward.id) {
      setState(() { _result = null; _error = null; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskColor = switch (_result?.riskLevel) {
      'high' => const Color(0xFFDC2626),
      'moderate' => const Color(0xFFD97706),
      _ => const Color(0xFF0F766E),
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.auto_awesome, color: Color(0xFF0F766E)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('AI Operational Insight', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              const Text('Simulasi analisis kapasitas, berjalan offline', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ])),
            const SizedBox(width: 6),
            const Chip(label: Text('OFFLINE DEMO', style: TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact),
          ]),
          const SizedBox(height: 12),
          const Text('Hanya angka agregat status bed yang dikirim. Nama pasien dan diagnosis tidak dikirim ke LLM.', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _generate,
              icon: _loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(_loading ? 'Menyiapkan analisis demo...' : (_result == null ? 'Jalankan analisis demo' : 'Perbarui analisis demo')),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
              child: Text('Analisis demo belum tersedia: $_error', style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B))),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              Chip(label: Text('BOR terisi: ${_result!.occupancyRate.toStringAsFixed(1)}%')),
              Chip(label: Text('Risiko: ${_riskLabel(_result!.riskLevel)}'), backgroundColor: riskColor.withOpacity(.12), labelStyle: TextStyle(color: riskColor, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 8),
            Text(_result!.summary, style: const TextStyle(fontSize: 13, height: 1.45)),
            if (_result!.recommendedActions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Pemeriksaan yang disarankan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              ..._result!.recommendedActions.map((action) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.check_circle_outline, size: 17, color: Color(0xFF0F766E)),
                  const SizedBox(width: 7),
                  Expanded(child: Text(action, style: const TextStyle(fontSize: 12, height: 1.35))),
                ]),
              )),
            ],
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(8)),
              child: Text('Batasan: ${_result!.limitations.join(' ')}', style: const TextStyle(fontSize: 11, color: Color(0xFF92400E), height: 1.4)),
            ),
            const SizedBox(height: 6),
            Text('Mode: ${_result!.model} · Data: sintetis', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          ],
        ]),
      ),
    );
  }

  String _riskLabel(String risk) => switch (risk) {
        'high' => 'Tinggi',
        'moderate' => 'Sedang',
        _ => 'Rendah',
      };
}
