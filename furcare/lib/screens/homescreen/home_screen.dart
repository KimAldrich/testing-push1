import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:furcare/components/drawer.dart';
import 'package:furcare/helpers/dbhelper.dart';
import 'package:furcare/screens/events_screen/events_screen.dart';
import 'package:furcare/screens/pets_screen/view_pet_details_screen.dart';
import 'package:furcare/screens/pets_screen/view_pets_screen.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class PetHomeScreen extends StatefulWidget {
  const PetHomeScreen({super.key});

  @override
  State<PetHomeScreen> createState() => _PetHomeScreenState();
}

class _PetHomeScreenState extends State<PetHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        title: Text(
          'Fur Care',
        ),
        centerTitle: true,
      ),
      drawer: drawer_component(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Gap(4),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12,
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      border: Border.all(
                        color: Colors.deepPurple.shade200,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Schedule',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (_) => EventsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.arrow_forward),
                            ),
                          ],
                        ),
                        FutureBuilder(
                          future: Dbhelper.fetchTodayEvents(),
                          builder: (_, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }
                            if (!snapshot.hasData ||
                                (snapshot.data as List).isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: const Center(
                                  child: Text('No Schedule For Today.'),
                                ),
                              );
                            }

                            var events = snapshot.data;

                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: events == null ? 0 : events.length,
                              itemBuilder: (_, index) {
                                final event = events![index];
                                return Column(
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue.shade800,
                                        child: const Icon(Icons.event,
                                            color: Colors.white),
                                      ),
                                      title: Text(
                                        event[Dbhelper.eventTitle] ??
                                            'No Title',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      subtitle: Text(
                                        event[Dbhelper.eventsDate],
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      trailing: Checkbox(
                                        value: event[Dbhelper.isDone] == 1,
                                        onChanged: (v) {
                                          setState(() {
                                            final updatedEvent =
                                                Map<String, dynamic>.from(
                                                    event);
                                            updatedEvent[Dbhelper.isDone] =
                                                v! ? 1 : 0;

                                            Dbhelper.updateEventStatus(
                                                event[Dbhelper.eventId],
                                                updatedEvent[Dbhelper.isDone]);
                                          });
                                        },
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.deepPurple.shade200,
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Gap(12),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pets',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (_) => ViewPetsScreen()));
                            },
                            icon: const Icon(Icons.arrow_forward),
                          ),
                        ],
                      ),
                      FutureBuilder(
                        future: Dbhelper.fetchPets(),
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          if (!snapshot.hasData ||
                              (snapshot.data as List).isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(bottom: 12.0),
                              child: Center(
                                child: Text('No Pets.'),
                              ),
                            );
                          }

                          var pets = snapshot.data;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                            ),
                            itemCount: pets == null ? 0 : pets.length,
                            itemBuilder: (context, index) {
                              var pet = pets![index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (_) => ViewPetDetailsScreen(
                                        petId: pet[Dbhelper.petId],
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: pet[Dbhelper.petImage] != null &&
                                                pet[Dbhelper.petImage]
                                                    .isNotEmpty
                                            ? ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(8),
                                                  topRight: Radius.circular(8),
                                                ),
                                                child: Image.network(
                                                  pet[Dbhelper.petImage],
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                      Icons.pets,
                                                      size: 48,
                                                      color: Colors.grey,
                                                    );
                                                  },
                                                ),
                                              )
                                            : const Icon(
                                                Icons.pets,
                                                size: 48,
                                                color: Colors.grey,
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              pet[Dbhelper.petName] ??
                                                  'Unknown',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            Text(
                                              pet[Dbhelper.petAge] != 0
                                                  ? pet[Dbhelper.petAge]
                                                      .toString()
                                                  : "",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
