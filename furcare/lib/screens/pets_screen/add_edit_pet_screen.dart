import 'package:flutter/material.dart';
import 'package:furcare/helpers/dbhelper.dart';
import 'package:furcare/models/pet.dart';
import 'package:furcare/screens/pets_screen/view_pet_details_screen.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class AddEditPetScreen extends StatefulWidget {
  const AddEditPetScreen(
      {super.key, required this.pet, required this.operation});

  final Pet? pet;
  final String operation;

  void fetchAddEdit() {
    Dbhelper.fetchEvent();
    Dbhelper.fetchPets();
  }

  @override
  State<AddEditPetScreen> createState() => _AddEditPetScreenState();
}

class _AddEditPetScreenState extends State<AddEditPetScreen> {
  var petNameCtrl = TextEditingController();
  var petBreedCtrl = TextEditingController();
  var petImageCtrl = TextEditingController();
  var petAgeCtrl = TextEditingController();
  var petNoteCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Dbhelper.openDb();
    //edit
    if (widget.operation == 'edit') {
      petNameCtrl.text = widget.pet!.name ?? '';
      petBreedCtrl.text = widget.pet!.breed ?? '';
      petImageCtrl.text = widget.pet!.image ?? '';
      petAgeCtrl.text = widget.pet!.age.toString() ?? '';
      petNoteCtrl.text = widget.pet!.note ?? '';
    }
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
      body: Column(
        children: [
          Gap(20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.amber.shade200,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      '${widget.operation == 'add' ? 'Add' : 'Edit'} Pet',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Gap(10),
                    TextField(
                      controller: petNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Pet Name',
                      ),
                    ),
                    Gap(10),
                    TextField(
                      controller: petAgeCtrl,
                      decoration: InputDecoration(
                        labelText: 'Pet Age',
                      ),
                    ),
                    Gap(10),
                    TextField(
                      controller: petBreedCtrl,
                      decoration: InputDecoration(
                        labelText: 'Pet Breed',
                      ),
                    ),
                    Gap(10),
                    TextField(
                      controller: petImageCtrl,
                      decoration: InputDecoration(
                        labelText: 'Your Pet Picture',
                      ),
                    ),
                    Gap(10),
                    TextField(
                      controller: petNoteCtrl,
                      decoration: InputDecoration(
                        labelText: 'Your Notes',
                      ),
                    ),
                    Gap(8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: widget.operation == 'add'
                              ? addPet
                              : () => editPet(widget.pet?.id ?? 0),
                          child:
                              Text(widget.operation == 'add' ? 'ADD' : 'EDIT'),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void addPet() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (petNameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pet name is required'),
          action: SnackBarAction(
            label: "Ok",
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } else {
      var pet = Pet.withoutId(
        name: petNameCtrl.text,
        breed: petBreedCtrl.text,
        age: petAgeCtrl.text.isEmpty ? 0 : int.parse(petAgeCtrl.text),
        image: petImageCtrl.text.isEmpty ? null : petImageCtrl.text,
        note: petNoteCtrl.text,
      );
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Add Pet'),
          content: Text('Do you want to add this pet?'),
          actions: [
            TextButton(
              onPressed: dissmissDialog,
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Dbhelper.addPet(pet);
                setState(() {
                  widget.fetchAddEdit();
                });
                dissmissDialog();
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        ),
      );
    }
  }

  void dissmissDialog() {
    Navigator.of(context).pop();
  }

  void editPet(int id) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (petNameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pet name is required'),
          action: SnackBarAction(
            label: "Ok",
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } else {
      var pet = Pet(
        id: id,
        name: petNameCtrl.text,
        breed: petBreedCtrl.text,
        age: int.tryParse(petAgeCtrl.text) ?? 0,
        image: petImageCtrl.text,
        note: petNoteCtrl.text,
      );
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Edit Pet'),
          content: Text('Do you want to edit this Pet?'),
          actions: [
            TextButton(
              onPressed: dissmissDialog,
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await Dbhelper.editPet(pet);

                print('Pet edited successfully!');
                dissmissDialog();
                setState(() {
                  widget.fetchAddEdit();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ViewPetDetailsScreen(petId: pet.id),
                    ),
                  );
                });
              },
              child: Text('Yes'),
            ),
          ],
        ),
      );
    }
  }
}
