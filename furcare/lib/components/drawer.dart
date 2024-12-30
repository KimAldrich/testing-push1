import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:furcare/screens/events_screen/events_screen.dart';
import 'package:furcare/screens/homescreen/home_screen.dart';
import 'package:furcare/screens/pets_screen/view_pets_screen.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class drawer_component extends StatelessWidget {
  const drawer_component({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 124, 0, 254),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Fur Care",
                  style: GoogleFonts.pacifico(
                    color: Colors.white,
                    fontSize: 42,
                  ),
                ),
                const Gap(8),
                Text(
                  "Manage your pets easily",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => PetHomeScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.pets),
            title: const Text("My Pets"),
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => ViewPetsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text("Schedule"),
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => EventsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
