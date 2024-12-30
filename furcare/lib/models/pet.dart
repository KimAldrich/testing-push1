import 'package:furcare/helpers/dbhelper.dart';

class Pet {
  late int id;
  late String name;
  late String breed;
  late int age;
  String? note;
  String? image;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    this.note,
    this.image,
  });

  Pet.withoutId({
    this.id = 0,
    required this.name,
    required this.breed,
    required this.age,
    this.note,
    this.image,
  });

  Map<String, dynamic> toMapWithoutId() {
    return {
      Dbhelper.petName: name,
      Dbhelper.petBreed: breed,
      Dbhelper.petAge: age,
      Dbhelper.petNotes: note,
      Dbhelper.petImage: image,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      Dbhelper.petId: id,
      Dbhelper.petName: name,
      Dbhelper.petBreed: breed,
      Dbhelper.petAge: age,
      Dbhelper.petNotes: note,
      Dbhelper.petImage: image,
    };
  }
}
