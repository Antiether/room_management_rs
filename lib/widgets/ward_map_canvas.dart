import 'dart:math';
import 'package:flutter/material.dart';
import '../models/room_bed.dart';
import '../services/hospital_state.dart';
import 'room_card.dart';
import 'zoom_controls.dart';

/// Layout helper that computes dynamic room positions and canvas size
/// based on the number of rooms in a ward, avoiding any overlap.
class _WardLayout {
  /// Rooms placed in the upper row
  final List<RoomModel> upperRooms;

  /// Rooms placed in the lower row
  final List<RoomModel> lowerRooms;

  /// Computed positions: room.id -> Offset(x, y)
  final Map<String, Offset> positions;

  /// Total canvas dimensions needed
  final double canvasWidth;
  final double canvasHeight;

  /// Corridor facility positions (centered in gap between rows)
  final double corridorY;
  final double corridorHeight;

  /// Positions for corridor facilities
  final Offset liftPos;
  final Offset nurseStationPos;
  final Offset doctorOfficePos;
  final Offset pharmacyPos;

  _WardLayout({
    required this.upperRooms,
    required this.lowerRooms,
    required this.positions,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.corridorY,
    required this.corridorHeight,
    required this.liftPos,
    required this.nurseStationPos,
    required this.doctorOfficePos,
    required this.pharmacyPos,
  });

  /// Compute an optimal layout for the given ward.
  ///
  /// Layout strategy:
  /// - Split rooms into 2 rows (upper + lower)
  /// - Each room gets a fixed card width [cardWidth] with [gap] spacing
  /// - A corridor gap of [corridorGap] separates the two rows
  /// - Corridor facilities (Lift, Nurse Station, Doctor Office, Pharmacy)
  ///   are placed horizontally within the corridor gap
  factory _WardLayout.compute(WardModel ward) {
    final rooms = ward.rooms;
    final int totalRooms = rooms.length;

    // Split into two rows: first half upper, second half lower
    final int upperCount = (totalRooms / 2).ceil();
    final upperRooms = rooms.sublist(0, upperCount);
    final lowerRooms = rooms.sublist(upperCount);

    // Layout constants. Match RoomCard's real width (310 logical pixels).
    const double cardWidth = 310.0;
    const double gap = 30.0;
    const double margin = 40.0;
    const double corridorTopSpacing = 30.0;
    const double extraCanvasRight = 300.0;
    const double extraCanvasBottom = 200.0;

    // Estimate card height dynamically from the largest bed count in this ward.
    // RoomCard lays out beds in one or two rows.
    final int maxBedsPerRoom = rooms.fold<int>(
      0,
      (maxBeds, room) => max(maxBeds, room.beds.length),
    );
    final double cardHeight = 100.0 + ((maxBedsPerRoom + 1) ~/ 2) * 55.0;
    const double facilityHeight = 74.0;
    const double corridorGap = facilityHeight + 32.0;
    const double upperY = margin;
    final double corridorY = upperY + cardHeight + corridorTopSpacing;
    final double lowerY = corridorY + corridorGap;

    // Compute positions
    final Map<String, Offset> positions = {};

    // Upper row
    for (int i = 0; i < upperRooms.length; i++) {
      final x = margin + i * (cardWidth + gap);
      positions[upperRooms[i].id] = Offset(x, upperY);
    }

    // Lower row
    for (int i = 0; i < lowerRooms.length; i++) {
      final x = margin + i * (cardWidth + gap);
      positions[lowerRooms[i].id] = Offset(x, lowerY);
    }

    // Keep enough room for both the room rows and the wider corridor facilities.
    final int maxCols = max(upperRooms.length, lowerRooms.length);
    final double roomRowWidth = maxCols == 0
        ? 0
        : maxCols * cardWidth + (maxCols - 1) * gap;
    final double canvasHeight = lowerY + cardHeight + margin + extraCanvasBottom;

    // Corridor facilities: spread evenly across the corridor
    // Corridor y-center
    final double facilityCenterY =
        corridorY + (corridorGap / 2) - 22; // center the ~44px tall boxes

    const double facilityWidths = 220 + 300 + 260 + 240; // approx total
    final double facilityGap = max(20, (roomRowWidth - facilityWidths) / 5);
    final double facilityRowWidth = facilityWidths + facilityGap * 5;
    final double canvasWidth =
        margin * 2 + max(roomRowWidth, facilityRowWidth) + extraCanvasRight;

    double facilityX = margin + facilityGap;
    final liftPos = Offset(facilityX, facilityCenterY);
    facilityX += 220 + facilityGap;
    final nurseStationPos = Offset(facilityX, facilityCenterY);
    facilityX += 300 + facilityGap;
    final doctorOfficePos = Offset(facilityX, facilityCenterY);
    facilityX += 260 + facilityGap;
    final pharmacyPos = Offset(facilityX, facilityCenterY);

    return _WardLayout(
      upperRooms: upperRooms,
      lowerRooms: lowerRooms,
      positions: positions,
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
      corridorY: corridorY,
      corridorHeight: corridorGap,
      liftPos: liftPos,
      nurseStationPos: nurseStationPos,
      doctorOfficePos: doctorOfficePos,
      pharmacyPos: pharmacyPos,
    );
  }
}

class WardMapCanvas extends StatefulWidget {
  final HospitalState state;
  final Function(BedModel bed, RoomModel room) onBedTapped;
  final bool isMobile;

  const WardMapCanvas({
    super.key,
    required this.state,
    required this.onBedTapped,
    this.isMobile = false,
  });

  @override
  State<WardMapCanvas> createState() => _WardMapCanvasState();
}

class _WardMapCanvasState extends State<WardMapCanvas> {
  late TransformationController _transformationController;
  late _WardLayout _cachedLayout;
  String? _cachedWardId;
  int _cachedRoomStructure = -1;

  int _roomStructureSignature(WardModel ward) => ward.rooms.fold<int>(
        17,
        (value, room) => value * 31 + room.id.hashCode * 7 + room.beds.length,
      );

  void _ensureLayout(WardModel ward) {
    final signature = _roomStructureSignature(ward);
    if (_cachedWardId != ward.id || _cachedRoomStructure != signature) {
      _cachedLayout = _WardLayout.compute(ward);
      _cachedWardId = ward.id;
      _cachedRoomStructure = signature;
    }
  }

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _ensureLayout(widget.state.currentWard);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyInitialScale();
    });
  }

  void _applyInitialScale() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    final isMobile = widget.isMobile || size.width < 900;
    _ensureLayout(widget.state.currentWard);
    final layout = _cachedLayout;

    // Fit canvas into viewport
    final scaleX = (size.width - 40) / layout.canvasWidth;
    final scaleY = (size.height - 120) / layout.canvasHeight;
    final fitScale = min(scaleX, scaleY);
    final initialScale = isMobile
        ? fitScale.clamp(0.22, 0.55)
        : fitScale.clamp(0.45, 1.0);

    final matrix = Matrix4.identity()..scale(initialScale, initialScale);
    _transformationController.value = matrix;
  }

  @override
  void didUpdateWidget(covariant WardMapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentWard.id != widget.state.currentWard.id) {
      _resetZoom();
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    // Reset control means exactly 100% zoom and origin position.
    _transformationController.value = Matrix4.identity();
  }

  void _showLegendBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.palette_outlined,
                    size: 20,
                    color: Color(0xFF0F766E),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Legenda Status Bed & Kamar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20),
              _buildLegendRow(
                const Color(0xFF10B981),
                'Tersedia',
                'Bed bersih, steril, dan siap digunakan pasien baru.',
              ),
              const SizedBox(height: 10),
              _buildLegendRow(
                const Color(0xFFF59E0B),
                'Dibooking',
                'Sudah dialokasikan untuk pasien yang sedang transit dari IGD/Poli.',
              ),
              const SizedBox(height: 10),
              _buildLegendRow(
                const Color(0xFFEF4444),
                'Terisi',
                'Sedang ditempati oleh pasien rawat inap aktif.',
              ),
              const SizedBox(height: 10),
              _buildLegendRow(
                const Color(0xFFEA580C),
                'Perlu Pembersihan',
                'Pasien baru saja pulang/pindah. Menunggu tim EVS.',
              ),
              const SizedBox(height: 10),
              _buildLegendRow(
                const Color(0xFF0284C7),
                'Sedang Dibersihkan',
                'Petugas kebersihan sedang melakukan sterilisasi (ada timer).',
              ),
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendRow(Color color, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ward = widget.state.currentWard;
    final filteredRooms = widget.state.filteredRooms;
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = widget.isMobile || screenWidth < 900;

    // Compute dynamic layout
    _ensureLayout(ward);
    final layout = _cachedLayout;
    final visibleRoomIds = filteredRooms.map((room) => room.id).toSet();

    return Stack(
      children: [
        // Interactive Architectural Floor Canvas
        Positioned.fill(
          child: Container(
            color: const Color(0xFFF8FAFC),
            child: InteractiveViewer(
              transformationController: _transformationController,
              // The floor plan is intentionally larger than the visible viewport.
              // Keep its real canvas dimensions so hit-testing for room cards and
              // bed InkWells stays aligned with the transformed content on narrow
              // browser windows as well as desktop.
              constrained: false,
              alignment: Alignment.topLeft,
              minScale: 0.15,
              maxScale: 3.0,
              boundaryMargin: const EdgeInsets.all(800),
              child: SizedBox(
                width: layout.canvasWidth,
                height: layout.canvasHeight,
                child: CustomPaint(
                  painter: _FloorPlanBackgroundPainter(
                    corridorTopY: layout.corridorY,
                    corridorBottomY: layout.corridorY + layout.corridorHeight,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ── Corridor Facilities ──
                      // 1. Lift & Tangga Darurat
                      Positioned(
                        left: layout.liftPos.dx,
                        top: layout.liftPos.dy,
                        child: _buildCorridorExit(),
                      ),

                      // 2. Pos Perawat / Nurse Station
                      Positioned(
                        left: layout.nurseStationPos.dx,
                        top: layout.nurseStationPos.dy,
                        child: _buildNurseStation(ward),
                      ),

                      // 3. Ruang Dokter & Konsultasi
                      Positioned(
                        left: layout.doctorOfficePos.dx,
                        top: layout.doctorOfficePos.dy,
                        child: _buildDoctorOffice(),
                      ),

                      // 4. Depo Farmasi & Linen
                      Positioned(
                        left: layout.pharmacyPos.dx,
                        top: layout.pharmacyPos.dy,
                        child: _buildPharmacyDepot(),
                      ),

                      // ── Room Cards ──
                      ...ward.rooms.map((room) {
                        final pos = layout.positions[room.id];
                        if (pos == null) return const SizedBox.shrink();

                        final isVisible = visibleRoomIds.contains(room.id);

                        return Positioned(
                          left: pos.dx,
                          top: pos.dy,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            opacity: isVisible ? 1.0 : 0.15,
                            child: RepaintBoundary(
                              child: SizedBox(
                                width: 310,
                                child: RoomCard(
                                  room: room,
                                  state: widget.state,
                                  onBedSelected: (bed) {
                                    widget.onBedTapped(bed, room);
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Floor Plan Header Badge (only on Desktop)
        if (!isNarrow)
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.apartment_rounded,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ward.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        ward.description,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        // Map Legend: Full on Desktop, Collapsible Pill on Mobile
        if (!isNarrow)
          Positioned(
            bottom: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Status Bed & Kamar',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      _buildLegendItem(const Color(0xFF10B981), 'Tersedia'),
                      _buildLegendItem(const Color(0xFFF59E0B), 'Dibooking'),
                      _buildLegendItem(const Color(0xFFEF4444), 'Terisi'),
                      _buildLegendItem(const Color(0xFFEA580C), 'Kotor (EVS)'),
                      _buildLegendItem(
                        const Color(0xFF0284C7),
                        'Sedang Disteril',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        else
          Positioned(
            bottom: 14,
            left: 14,
            child: InkWell(
              onTap: () => _showLegendBottomSheet(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      size: 14,
                      color: Color(0xFF0F766E),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Legenda Status',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Zoom Controls (Bottom-Right)
        Positioned(
          bottom: 14,
          right: 14,
          child: ZoomControls(
            transformationController: _transformationController,
            onReset: _resetZoom,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF334155)),
        ),
      ],
    );
  }

  Widget _buildNurseStation(WardModel ward) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF818CF8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_hospital_rounded,
            size: 22,
            color: Color(0xFF4338CA),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'POS PERAWAT (NURSE STATION)',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF312E81),
                  ),
                ),
                Text(
                  'Monitoring Sentral & Panggilan Darurat',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9, color: Color(0xFF4338CA)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorridorExit() {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.elevator_rounded, size: 18, color: Color(0xFF166534)),
          SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LIFT & TANGGA DARURAT',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF166534),
                  ),
                ),
                Text(
                  'Jalur Evakuasi Utama',
                  style: TextStyle(fontSize: 8, color: Color(0xFF166534)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorOffice() {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.medical_information_outlined,
            size: 18,
            color: Color(0xFF92400E),
          ),
          SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'RUANG DOKTER & KONSULTASI',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                Text(
                  'Edukasi Keluarga & Visite DPJP',
                  style: TextStyle(fontSize: 8, color: Color(0xFF78350F)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyDepot() {
    return Container(
      width: 240,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF7DD3FC)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 18, color: Color(0xFF0369A1)),
          SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DEPO FARMASI & LINEN STERIL',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0369A1),
                  ),
                ),
                Text(
                  'Distribusi Obat & Logistik EVS',
                  style: TextStyle(fontSize: 8, color: Color(0xFF075985)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloorPlanBackgroundPainter extends CustomPainter {
  final double corridorTopY;
  final double corridorBottomY;

  _FloorPlanBackgroundPainter({
    required this.corridorTopY,
    required this.corridorBottomY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.8;

    const double step = 30.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintGrid);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    // Corridor highlight background
    final corridorFill = Paint()
      ..color = const Color(0xFFF1F5F9).withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(20, corridorTopY, size.width - 20, corridorBottomY),
      corridorFill,
    );

    // Corridor boundary lines
    final corridorPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(20, corridorTopY),
      Offset(size.width - 20, corridorTopY),
      corridorPaint,
    );
    canvas.drawLine(
      Offset(20, corridorBottomY),
      Offset(size.width - 20, corridorBottomY),
      corridorPaint,
    );

    // Corridor label
    final labelPainter = TextPainter(
      text: const TextSpan(
        text: '← KORIDOR UTAMA →',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFFCBD5E1),
          letterSpacing: 4,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    final cx = (size.width - labelPainter.width) / 2;
    final cy = corridorBottomY - 18;
    labelPainter.paint(canvas, Offset(cx, cy));
  }

  @override
  bool shouldRepaint(covariant _FloorPlanBackgroundPainter oldDelegate) {
    return oldDelegate.corridorTopY != corridorTopY ||
        oldDelegate.corridorBottomY != corridorBottomY;
  }
}
