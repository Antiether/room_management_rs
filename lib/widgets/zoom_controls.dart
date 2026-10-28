import 'package:flutter/material.dart';

class ZoomControls extends StatelessWidget {
  final TransformationController transformationController;
  final VoidCallback onReset;

  const ZoomControls({
    super.key,
    required this.transformationController,
    required this.onReset,
  });

  void _zoom(double factor) {
    final matrix = transformationController.value;
    final currentScale = matrix.getMaxScaleOnAxis();
    final newScale = (currentScale * factor).clamp(0.4, 2.5);
    final ratio = newScale / currentScale;

    // Zoom towards center
    final zoomedMatrix = matrix.clone()..scaleByDouble(ratio, ratio, 1.0, 1.0);
    transformationController.value = zoomedMatrix;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Matrix4>(
      valueListenable: transformationController,
      builder: (context, matrix, _) {
        final currentScale = (matrix.getMaxScaleOnAxis() * 100).toInt();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Zoom In (+)
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                tooltip: 'Perbesar Peta (Zoom In)',
                onPressed: () => _zoom(1.2),
              ),
              // Current Zoom %
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  '$currentScale%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              // Zoom Out (-)
              IconButton(
                icon: const Icon(Icons.remove, size: 20),
                tooltip: 'Perkecil Peta (Zoom Out)',
                onPressed: () => _zoom(0.8),
              ),
              const Divider(height: 1, indent: 6, endIndent: 6),
              // Reset
              IconButton(
                icon: const Icon(Icons.filter_center_focus_rounded, size: 18),
                tooltip: 'Reset Skala (100%)',
                onPressed: onReset,
              ),
            ],
          ),
        );
      },
    );
  }
}
