import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:furcare/components/drawer.dart';
import 'package:furcare/helpers/dbhelper.dart';
import 'package:furcare/models/pet.dart';
import 'package:furcare/screens/pets_screen/add_edit_pet_screen.dart';
import 'package:furcare/screens/pets_screen/view_pet_details_screen.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewPetsScreen extends StatefulWidget {
  const ViewPetsScreen({super.key});

  @override
  State<ViewPetsScreen> createState() => _ViewPetsScreenState();
}

class _ViewPetsScreenState extends State<ViewPetsScreen> {
  final TextEditingController searchCtrl = TextEditingController();
  List<Map<String, dynamic>> allPets = [];
  List<Map<String, dynamic>> filteredPets = [];

  @override
  void initState() {
    super.initState();
    fetchPets().then((pets) {
      setState(() {
        allPets = pets;
        filteredPets = pets;
      });
    });
  }

  Future<List<Map<String, dynamic>>> fetchPets() async {
    return await Dbhelper.fetchPets();
  }

  void filterPets(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      if (lowerCaseQuery.isEmpty) {
        filteredPets = allPets;
      } else {
        filteredPets = allPets.where((pet) {
          final name = pet[Dbhelper.petName]?.toLowerCase() ?? '';
          return name.contains(lowerCaseQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Dbhelper.openDb();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        title: const Text('Fur Care'),
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
                filterPets(value);
              },
              decoration: InputDecoration(
                labelText: 'Search Pets',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const Gap(8),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchPets(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (filteredPets.isEmpty) {
                    return const Center(child: Text('No pets found.'));
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: filteredPets.length,
                    itemBuilder: (context, index) {
                      var pet = filteredPets[index];
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: pet[Dbhelper.petImage] != null &&
                                        pet[Dbhelper.petImage].isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                        child: Image.network(
                                          pet[Dbhelper.petImage],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder:
                                              (context, error, stackTrace) {
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
                                      pet[Dbhelper.petName] ?? 'Unknown',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      pet[Dbhelper.petAge] != 0
                                          ? pet[Dbhelper.petAge].toString()
                                          : "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (_) => AddEditPetScreen(
                pet: Pet.withoutId(name: '', breed: '', age: 0, image: ''),
                operation: 'add',
              ),
            ),
          )
              .then((_) {
            fetchPets().then((pets) {
              setState(() {
                allPets = pets;
                filteredPets = pets;
              });
            });
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
