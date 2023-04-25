class ShiftType {
  final String description;
  final String id;

  const ShiftType({
    required this.description,
    required this.id,
  });

  Map toJson() => {
        'description': description,
        'id': id,
      };

  static ShiftType fromJson(Map<String, dynamic> json) =>
      ShiftType(description: json['description'], id: json['id']);
}
