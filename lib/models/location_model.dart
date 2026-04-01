class LocationModel {
  final int id;
  final String name;
  final String spots;
  final String statusColor;

  LocationModel({
    required this.id,
    required this.name,
    required this.spots,
    required this.statusColor,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      name: json['name'],
      spots: json['spots'],
      statusColor: json['status_color'],
    );
  }
}