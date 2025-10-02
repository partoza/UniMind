import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String selectedGender = "Male";
  String selectedYear = "3rd Year";
  String selectedDepartment = "College of Computing Education";
  String selectedProgram = "BSIT";
  String selectedBuilding = "PS";

  List<String> skills = ["Coding", "UI/UX Design", "Math", "Video Editing", "Research Writing"];
  List<String> betterSkills = ["Coding", "UI/UX Design", "Math", "Video Editing", "Research Writing"];
  List<String> selectedSkills = ["Coding", "UI/UX Design"];
  List<String> selectedBetterSkills = ["Coding", "UI/UX Design"];

  final Color primaryRed = const Color(0xFFB41214);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage("assets/profile.jpg"), // Replace with your asset
                  ),
                  SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text("Change Profile Picture", style: GoogleFonts.montserrat(color: Colors.black)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            _buildTextField("First Name", "John Rex"),
            _buildTextField("Last Name", "Partoza"),

            _buildDropdown("Gender", ["Male", "Female"], selectedGender, (val) {
              setState(() => selectedGender = val!);
            }),

            _buildDropdown("Year Level", ["1st Year", "2nd Year", "3rd Year", "4th Year"], selectedYear, (val) {
              setState(() => selectedYear = val!);
            }),

            _buildDropdown("College Department", [
              "College of Computing Education",
              "College of Business",
              "College of Arts"
            ], selectedDepartment, (val) {
              setState(() => selectedDepartment = val!);
            }),

            _buildDropdown("Program", ["BSIT", "BSCS", "BSEMC"], selectedProgram, (val) {
              setState(() => selectedProgram = val!);
            }),

            _buildSectionTitle("My Top Skills :"),
            Wrap(
              spacing: 10,
              children: skills.map((skill) {
                final isSelected = selectedSkills.contains(skill);
                return ChoiceChip(
                  label: Text(
                    skill,
                    style: GoogleFonts.montserrat(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      isSelected ? selectedSkills.remove(skill) : selectedSkills.add(skill);
                    });
                  },
                  selectedColor: primaryRed,
                  checkmarkColor: Colors.white, // ✅ White checkmark
                  backgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                );
              }).toList(),
            ),
            SizedBox(height: 15),

            _buildSectionTitle("Things I'd like to get better at:"),
            Wrap(
              spacing: 10,
              children: betterSkills.map((skill) {
                final isSelected = selectedBetterSkills.contains(skill);
                return ChoiceChip(
                  label: Text(
                    skill,
                    style: GoogleFonts.montserrat(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      isSelected ? selectedBetterSkills.remove(skill) : selectedBetterSkills.add(skill);
                    });
                  },
                  selectedColor: primaryRed,
                  checkmarkColor: Colors.white, // ✅ White checkmark
                  backgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            _buildDropdown("Building", ["PS", "CS", "ENG"], selectedBuilding, (val) {
              setState(() => selectedBuilding = val!);
            }),

            SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Save Changes", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.montserrat(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFB41214), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String selectedValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.montserrat(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFB41214), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          focusColor: Color(0xFFB41214),
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: GoogleFonts.montserrat()))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }
}
