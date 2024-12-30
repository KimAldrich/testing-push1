import 'package:flutter/material.dart';
import 'package:furcare/screens/homescreen/home_screen.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              "https://r1.ilikewallpaper.net/iphone-11-wallpapers/download-105668/black-pug-with-gray-knit-scarf.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 100,
            bottom: 42,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "Fur Care",
                  style: GoogleFonts.pacifico(
                    color: const Color.fromARGB(255, 124, 0, 254),
                    fontSize: 42,
                  ),
                ),
                const Gap(20),
                Text(
                  "Let's start making\nyour pet's lives better.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => PetHomeScreen()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(40)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 28,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
