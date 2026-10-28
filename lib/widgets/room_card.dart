import 'package:flutter/material.dart';
import '../models/room_bed.dart';
import '../services/hospital_state.dart';
import 'bed_tile.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final HospitalState state;
  final Function(BedModel bed) onBedSelected;

  const RoomCard({
    super.key,
    required this.room,
    required this.state,
    required this.onBedSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = state.selectedRoom?.id == room.id;
    final classColor = room.classColor;
    final genderOccupancy = room.currentGenderOccupancy;

    return Container(
      width: 310, // Fixed width matching layout grid; do NOT use room.width
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : const Color(0xFFCBD5E1),
          width: isSelected ? 2.2 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: isSelected ? 10 : 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Room Header (Walls / Door top bar)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                  : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
                      : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
            ),
            child: Row(
              children: [
                // Door symbol
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: classColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.meeting_room_outlined, size: 14, color: classColor),
                ),
                const SizedBox(width: 6),
                // Room Number & Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          Text(
                            room.roomNumber,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: classColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              room.classLabel,
                              style: TextStyle(
                                fontSize: 9.0,
                                fontWeight: FontWeight.bold,
                                color: classColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        room.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                // Multi-bed Gender & Capacity Indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${room.occupiedBeds}/${room.totalBeds} Terisi',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: room.occupiedBeds == room.totalBeds
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF059669),
                      ),
                    ),
                    if (genderOccupancy != null)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.5),
                        decoration: BoxDecoration(
                          color: genderOccupancy == 'L'
                              ? Colors.blue.withOpacity(0.12)
                              : Colors.pink.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          genderOccupancy == 'L'
                              ? '👨 Bangsal Pria'
                              : genderOccupancy == 'P'
                                  ? '👩 Bangsal Wanita'
                                  : '👥 Campur',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            color: genderOccupancy == 'L'
                                ? Colors.blue[800]
                                : Colors.pink[800],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Body: Bed Layout inside the room
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildBedsGrid(context),
          ),

          // Room Footer: Facilities Pills
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 11, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    room.facilities.take(2).join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                  ),
                ),
                Text(
                  'Lt. ${room.floor}',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBedsGrid(BuildContext context) {
    if (room.beds.length == 1) {
      final bed = room.beds.first;
      return BedTile(
        bed: bed,
        room: room,
        state: state,
        onTap: () => onBedSelected(bed),
      );
    } else if (room.beds.length == 2) {
      return Column(
        children: room.beds.map((bed) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: BedTile(
              bed: bed,
              room: room,
              state: state,
              onTap: () => onBedSelected(bed),
            ),
          );
        }).toList(),
      );
    } else {
      // 3 or 4 beds (e.g. Kelas 3 KRIS)
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: BedTile(
                  bed: room.beds[0],
                  room: room,
                  state: state,
                  onTap: () => onBedSelected(room.beds[0]),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: BedTile(
                  bed: room.beds[1],
                  room: room,
                  state: state,
                  onTap: () => onBedSelected(room.beds[1]),
                ),
              ),
            ],
          ),
          if (room.beds.length > 2) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: BedTile(
                    bed: room.beds[2],
                    room: room,
                    state: state,
                    onTap: () => onBedSelected(room.beds[2]),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: room.beds.length > 3
                      ? BedTile(
                          bed: room.beds[3],
                          room: room,
                          state: state,
                          onTap: () => onBedSelected(room.beds[3]),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ],
        ],
      );
    }
  }
}
