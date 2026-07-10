enum ComplaintStatus { pending, inProgress, resolved, rejected }

class Complaint {
  const Complaint({
    required this.id,
    required this.category,
    required this.village,
    required this.description,
    required this.date,
    required this.status,
    required this.officer,
    required this.location,
  });

  final String id;
  final String category;
  final String village;
  final String description;
  final String date;
  final ComplaintStatus status;
  final String officer;
  final String location;

  double? get latitude => _coordinate(0);
  double? get longitude => _coordinate(1);

  double? _coordinate(int index) {
    final parts = location.split(',');
    if (parts.length < 2) return null;
    return double.tryParse(parts[index].trim());
  }
}
