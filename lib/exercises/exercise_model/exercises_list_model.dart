


class ExerciseModel {
  final String id;
  final String name;
  final String bodyPartId;
  final String image;
  final List<String>? instructions;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.bodyPartId,
    required this.image,
    this.instructions,
  });

  // Factory to create Exercise object from JSON (from Node.js)
  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['_id'] ?? '', // MongoDB uses _id
      name: json['name'] ?? '',
      bodyPartId: json['bodyPartId'] ?? '',
      image: json['image'] ?? '',
      instructions: json['instructions'] != null
          ? List<String>.from(json['instructions'])
          : [],
    );
  }
}