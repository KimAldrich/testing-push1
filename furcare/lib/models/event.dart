import 'package:furcare/helpers/dbhelper.dart';

class Event {
  late int id;
  late String title;
  late String dateTime;
  int petId;
  late bool isDone;

  Event({
    required this.id,
    required this.title,
    required this.dateTime,
    this.petId = 0,
    this.isDone = false,
  });

  Event.withoutId({
    this.id = 0,
    required this.title,
    required this.dateTime,
    this.petId = 0,
    this.isDone = false,
  });

  void toggleCheckBox() => isDone = !isDone;

  Map<String, dynamic> toMap() {
    return {
      Dbhelper.eventId: id,
      Dbhelper.eventTitle: title,
      Dbhelper.eventsDate: dateTime,
      Dbhelper.eventPetId: petId,
      Dbhelper.isDone: isDone ? 1 : 0,
    };
  }

  Map<String, dynamic> toMapWithoutId() {
    return {
      Dbhelper.eventTitle: title,
      Dbhelper.eventsDate: dateTime,
      Dbhelper.eventPetId: petId,
      Dbhelper.isDone: isDone ? 1 : 0,
    };
  }
}
