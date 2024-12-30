import 'package:flutter/material.dart';
import 'package:furcare/screens/start/start_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const FurCare());
}

class FurCare extends StatelessWidget {
  const FurCare({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 124, 0, 254),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ).copyWith(
          secondary: Colors.amber,
          surface: Colors.white,
        ),
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.poppins(
              fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500),
          bodyMedium: GoogleFonts.poppins(
              fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
          displayLarge: GoogleFonts.poppins(
              fontSize: 22, color: Colors.black, fontWeight: FontWeight.w600),
          displayMedium: GoogleFonts.poppins(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
          titleLarge: GoogleFonts.poppins(
              fontSize: 22, color: Colors.black, fontWeight: FontWeight.w600),
          titleMedium: GoogleFonts.poppins(
              fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500),
          titleSmall:
              GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.deepPurple,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.deepPurple,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.deepPurple,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.amber,
          titleTextStyle: GoogleFonts.pacifico(
            fontSize: 24,
            color: Color.fromARGB(255, 124, 0, 254),
          ),
        ),
      ),
      home: StartPage(),
    );
  }
}
