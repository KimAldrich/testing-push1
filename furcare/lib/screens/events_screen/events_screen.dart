import 'package:flutter/material.dart';
import 'package:furcare/components/drawer.dart';
import 'package:furcare/helpers/dbhelper.dart';
import 'package:furcare/models/event.dart';
import 'package:furcare/screens/events_screen/event_list_tile_component.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  var titleCtrl = TextEditingController();
  var dateTimeCtrl = TextEditingController();
  var petNameCtrl = TextEditingController();
  var searchCtrl = TextEditingController();
  List<Map<String, dynamic>> allEvents = [];
  List<Map<String, dynamic>> filteredEvents = [];
  String error = "";

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  void fetchEvents() async {
    var events = await Dbhelper.fetchEvent();
    setState(() {
      allEvents = events;
      filteredEvents = events;
    });
  }

  void filterEvents(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredEvents = allEvents;
      } else {
        filteredEvents = allEvents.where((event) {
          final title = event[Dbhelper.eventTitle]?.toLowerCase() ?? '';
          final dateTime = event[Dbhelper.eventsDate]?.toLowerCase() ?? '';
          return title.contains(lowerCaseQuery) ||
              dateTime.contains(lowerCaseQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        title: Text(
          'Fur Care',
          style: GoogleFonts.pacifico(
            color: const Color.fromARGB(255, 124, 0, 254),
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      drawer: drawer_component(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: searchCtrl,
              onChanged: (value) {
                filterEvents(value);
              },
              decoration: InputDecoration(
                labelText: 'Search Schedule',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            Gap(4),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: Future.value(filteredEvents),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  var events = snapshot.data ?? [];
                  if (events.isEmpty) {
                    return const Center(child: Text('No events found.'));
                  }
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      var event = events[index];
                      return Dismissible(
                        key: ValueKey(event[Dbhelper.eventId]),
                        onDismissed: (direction) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text(
                                    'Are you sure you want to delete this event?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {});
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Dbhelper.deleteEvent(event[
                                          Dbhelper.eventId]); // Delete event
                                      setState(() {
                                        allEvents = allEvents
                                            .where((e) =>
                                                e[Dbhelper.eventId] !=
                                                event[Dbhelper.eventId])
                                            .toList();
                                        filteredEvents = filteredEvents
                                            .where((e) =>
                                                e[Dbhelper.eventId] !=
                                                event[Dbhelper.eventId])
                                            .toList();
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: EventListTile(
                          event: event,
                          showEditDialog: showEditDialog,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void showAddDialog() {
    titleCtrl.clear();
    dateTimeCtrl.clear();

    showDialog(
      context: context,
      builder: (_) => addEditDialog('add'),
    );
  }

  void showEditDialog(Event event) async {
    var matchedPet = await Dbhelper.findPetByName(petNameCtrl.text);
    titleCtrl.text = event.title;
    dateTimeCtrl.text = event.dateTime;

    if (matchedPet != null) {
      petNameCtrl.text = matchedPet[Dbhelper.petName];
    }

    showDialog(
      context: context,
      builder: (_) => addEditDialog('edit', event: event),
    );
  }

  Dialog addEditDialog(String operation, {Event? event}) {
    return Dialog(
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${operation == 'add' ? 'Add' : 'Edit'} Event',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const Divider(),
                const Gap(10),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const Gap(10),
                TextField(
                  controller: dateTimeCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Event Date & Time',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: pickDateTime,
                ),
                const Gap(10),
                TextField(
                  controller: petNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Pet Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const Gap(10),
                Text(
                  error,
                  style: TextStyle(color: Colors.red),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        titleCtrl.clear();
                        dateTimeCtrl.clear();
                        petNameCtrl.clear();
                        error = '';
                        dismissDialog();
                      },
                      child: const Text('Cancel'),
                    ),
                    const Gap(16),
                    ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.trim().isEmpty ||
                            dateTimeCtrl.text.toString().isEmpty) {
                          setDialogState(() {
                            error = "Event title and date required";
                          });
                          return;
                        }
                        if (operation == 'add') {
                          addEvent();
                        } else {
                          editEvent(event!.id);
                        }
                      },
                      child: Text(operation == 'add' ? 'Add' : 'Edit'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        String formattedDateTime =
            DateFormat('yyyy-MM-dd HH:mm').format(finalDateTime);
        dateTimeCtrl.text = formattedDateTime;
      }
    }
  }

  void dismissDialog() {
    Navigator.of(context).pop();
  }

  void addEvent() async {
    if (titleCtrl.text.trim().isEmpty || dateTimeCtrl.text.isEmpty) {
      setState(() {
        error = "Event title and date required";
      });
      return;
    }

    if (petNameCtrl.text.isEmpty) {
      Dbhelper.addEvent(Event.withoutId(
        title: titleCtrl.text,
        dateTime: dateTimeCtrl.text,
      ));
    } else {
      var matchedPet = await Dbhelper.findPetByName(petNameCtrl.text);
      if (matchedPet != null) {
        Dbhelper.addEvent(Event.withoutId(
          title: titleCtrl.text,
          dateTime: dateTimeCtrl.text,
          petId: matchedPet[Dbhelper.petId],
        ));
      } else {
        setState(() {
          error = "Pet not found";
        });
        return;
      }
    }

    dismissDialog();
    fetchEvents();
  }

  void editEvent(int id) async {
    if (petNameCtrl.text.isEmpty) {
      Dbhelper.updateEvent(Event(
        id: id,
        title: titleCtrl.text,
        dateTime: dateTimeCtrl.text,
      ));
    } else {
      var matchedPet = await Dbhelper.findPetByName(petNameCtrl.text);

      if (matchedPet != null) {
        Dbhelper.updateEvent(Event(
          id: id,
          title: titleCtrl.text,
          dateTime: dateTimeCtrl.text,
          petId: matchedPet[Dbhelper.petId],
        ));
      } else {
        setState(() {
          error = "Pet not found";
        });
        return;
      }
    }

    dismissDialog();
    fetchEvents();
  }
}
