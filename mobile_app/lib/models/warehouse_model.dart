class Warehouse {
  final String id;
  final String name;
  final String location;
  final int capacity;
  final bool active;

  Warehouse({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    required this.active,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] ?? '',
      name: json['name'] ?? 'N/A',
      location: json['location'] ?? 'N/A',
      capacity: json['capacity'] ?? 0,
      active: json['active'] ?? true,
    );
  }
}
