import 'package:flutter/material.dart';



class BodyPart {
  final String id;
  final String name;
  final String image;

  BodyPart({
    required this.id,
    required this.name,
    required this.image,
  });
}
final List<BodyPart> bodyParts = [
  BodyPart(
    id: "chest",
    name: "Chest",
    image: "assets/images/body_part_image/chest.png",
  ),
  BodyPart(id: "back", name: "Back",  image: "assets/images/body_part_image/chest.png",),
  BodyPart(id: "legs", name: "Legs",   image: "assets/images/body_part_image/chest.png",),
  BodyPart(id: "shoulders", name: "Shoulders",   image: "assets/images/body_part_image/chest.png",),
  BodyPart(id: "arms", name: "Arms",  image: "assets/images/body_part_image/chest.png",),
  BodyPart(id: "core", name: "Core",   image: "assets/images/body_part_image/chest.png",),
];