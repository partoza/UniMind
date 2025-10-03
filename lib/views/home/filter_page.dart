import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterPage extends StatelessWidget {
  const FilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter', style: GoogleFonts.montserrat()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list, size: 120, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text('Filter Page', style: GoogleFonts.montserrat(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Add filter controls here.',
                style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
