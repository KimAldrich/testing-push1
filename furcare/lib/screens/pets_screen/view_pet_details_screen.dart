import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:furcare/helpers/dbhelper.dart';
import 'package:furcare/models/pet.dart';
import 'package:furcare/screens/pets_screen/add_edit_pet_screen.dart';
import 'package:furcare/screens/pets_screen/view_pets_screen.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewPetDetailsScreen extends StatefulWidget {
  const ViewPetDetailsScreen({super.key, required this.petId});

  final int petId;

  @override
  State<ViewPetDetailsScreen> createState() => _ViewPetDetailsScreenState();
}

class _ViewPetDetailsScreenState extends State<ViewPetDetailsScreen> {
  Pet? pet;
  String? errorMessage;

  var noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPetDetails();
  }

  Future<void> _fetchPetDetails() async {
    try {
      final petData = await Dbhelper.fetchPetById(widget.petId);
      if (petData != null) {
        setState(() {
          pet = Pet(
            id: petData['id'],
            name: petData['name'],
            breed: petData['breed'],
            age: petData['age'],
            image: petData['imageUrl'],
            note: petData['notes'],
          );
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => ViewPetsScreen(),
              ),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          'Fur Care',
          style: GoogleFonts.pacifico(
            color: const Color.fromARGB(255, 124, 0, 254),
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          if (pet != null)
            IconButton(
              onPressed: () {
                setState(() {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Delete Pet'),
                      content:
                          Text('Are you sure you want to delete ${pet!.name}?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                int id = pet!.id;
                                Dbhelper.deletePet(id);
                                Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (_) => ViewPetsScreen(),
                                ));
                              });
                            },
                            child: Text('Delete')),
                      ],
                    ),
                  );
                });
              },
              icon: const Icon(Icons.delete_forever),
            ),
        ],
      ),
      body: pet == null
          ? Center(
              child: errorMessage != null
                  ? Text(errorMessage!)
                  : const CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          pet!.image != null && pet!.image!.isNotEmpty
                              ? Image.network(
                                  pet!.image!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 420,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 420,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(Icons.pets,
                                            size: 80, color: Colors.white),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  height: 420,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.pets,
                                        size: 80, color: Colors.white),
                                  ),
                                ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${pet!.name[0].toUpperCase()}${pet!.name.substring(1)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                  Container(
                    padding: EdgeInsets.all(8),
                    color: Colors.amber.shade100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: (screenWidth / 2) - 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Breed: ${pet!.breed}',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: (screenWidth / 2) - 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Age: ${pet!.age}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Gap(4),
                        Text(
                          "Pet Note",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          '${pet!.note != null ? pet!.note : ""}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Events",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),
                  FutureBuilder(
                    future: Dbhelper.fetchPetEvents(widget.petId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData ||
                          (snapshot.data as List).isEmpty) {
                        return const Center(child: Text('No events found.'));
                      }
                      var events = snapshot.data as List<Map<String, dynamic>>;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          var event = events[index];
                          return Dismissible(
                            key: ValueKey(event[Dbhelper.eventId]),
                            onDismissed: (direction) {
                              Dbhelper.deleteEvent(event[Dbhelper.eventId]);
                              setState(() {});
                            },
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade800,
                                  child: const Icon(Icons.event,
                                      color: Colors.white),
                                ),
                                title: Text(
                                  event[Dbhelper.eventTitle],
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                subtitle: Text(
                                  event[Dbhelper.eventsDate],
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                trailing: Checkbox(
                                  value: event[Dbhelper.isDone] == 1,
                                  onChanged: (v) {
                                    setState(() {
                                      final updatedEvent =
                                          Map<String, dynamic>.from(event);
                                      updatedEvent[Dbhelper.isDone] =
                                          v! ? 1 : 0;

                                      Dbhelper.updateEventStatus(
                                          event[Dbhelper.eventId],
                                          updatedEvent[Dbhelper.isDone]);
                                    });
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  Gap(70),
                ],
              ),
            ),
      floatingActionButton: pet != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddEditPetScreen(
                      pet: pet!,
                      operation: 'edit',
                    ),
                  ),
                );
              },
              child: const Icon(Icons.edit_outlined),
            )
          : null,
    );
  }
}
