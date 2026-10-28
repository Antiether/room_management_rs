class CleaningTaskModel {
  final String bedId;
  final String roomNumber;
  final String wardName;
  final String bedCode;
  String cleanerName;
  DateTime requestedTime;
  DateTime? startedTime;
  int durationSeconds;
  int remainingSeconds;
  bool isInProgress;
  bool isCompleted;

  CleaningTaskModel({
    required this.bedId,
    required this.roomNumber,
    required this.wardName,
    required this.bedCode,
    this.cleanerName = 'Petugas Kebersihan (EVS)',
    required this.requestedTime,
    this.startedTime,
    this.durationSeconds = 45, // Demo default 45s (bisa dipercepat / diselesaikan manual)
    this.remainingSeconds = 45,
    this.isInProgress = false,
    this.isCompleted = false,
  });

  double get progress {
    if (durationSeconds <= 0) return 1.0;
    return (1.0 - (remainingSeconds / durationSeconds)).clamp(0.0, 1.0);
  }

  String get formattedRemaining {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
