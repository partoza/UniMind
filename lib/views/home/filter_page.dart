import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String? selectedGender;
  String? selectedDepartment;
  RangeValues yearRange = const RangeValues(2, 3);

  final List<String> genders = ["Male", "Female", "Other"];
  final List<Map<String, String>> departments = [
  {
    "name": "College of Computing Education",
    "logo": "assets/ccelogo.png",
  },
  {
    "name": "College of Arts and Science Education",
    "logo": "assets/caselogo.png",
  },
  {
    "name": "College of Engineering Education",
    "logo": "assets/ceelogo.png",
  },
];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Apply Filters",
          style: GoogleFonts.montserrat(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gender Dropdown
            Text(
              "Who would you like to study with?",
              style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  "Select Gender",
                  style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey[600]),
                ),
                value: selectedGender,
                items: genders.map((gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(
                      gender,
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedGender = value);
                },
                buttonStyleData: ButtonStyleData(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color.fromARGB(255, 179, 179, 179), width: 1),
                    color: Colors.white,
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(Icons.arrow_drop_down, color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Department Dropdown
            Text(
              "Which college department do you want to connect with?",
              style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  "Select Department",
                  style: GoogleFonts.montserrat(
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                    color: Colors.grey[600],
                  ),
                ),
                value: selectedDepartment,
                items: departments.map((dept) {
                  return DropdownMenuItem<String>(
                    value: dept["name"],
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 🔹 Fixed-size Department Logo
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            dept["logo"]!,
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.03),

                        // 🔹 Department Name (wraps if long)
                        Expanded(
                          child: Text(
                            dept["name"]!,
                            style: GoogleFonts.montserrat(
                              fontSize: MediaQuery.of(context).size.width * 0.035,
                              fontWeight: FontWeight.w500,
                            ),
                            softWrap: true, // ✅ allows line breaks
                            overflow: TextOverflow.visible, // ✅ don’t cut text
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedDepartment = value);
                },

                // Button styling
                buttonStyleData: ButtonStyleData(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // more space
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                    color: Colors.white,
                  ),
                ),

                // Dropdown styling
                dropdownStyleData: DropdownStyleData(
                  maxHeight: MediaQuery.of(context).size.height * 0.5, // taller dropdown
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                ),

                iconStyleData: const IconStyleData(
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                ),
              ),
            ),



            const SizedBox(height: 24),

            // 🔹 Year Level Range Slider
            Text(
              "What year level is your study buddy?",
              style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // 🔹 Year Level Filter Container
            Container(
              padding: const EdgeInsets.all(16), // inner spacing
              decoration: BoxDecoration(
                color: Colors.white, // same background as dropdown
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current selection text
                  Text(
                    "Between ${yearRange.start.toInt()} and ${yearRange.end.toInt()} Year",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  RangeSlider(
                    values: yearRange,
                    min: 1,
                    max: 4,
                    divisions: 3,
                    activeColor: const Color.fromARGB(255, 0, 0, 0),
                    inactiveColor: Colors.grey[300],
                    labels: RangeLabels(
                      "${yearRange.start.toInt()} Year",
                      "${yearRange.end.toInt()} Year",
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        yearRange = RangeValues(
                          values.start.roundToDouble(),
                          values.end.roundToDouble(),
                        );
                      });
                    },
                  ),

                  const SizedBox(height: 6),
                  Text(
                    "Pick a range from freshman to senior, it's up to you!",
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),


            const SizedBox(height: 8),


            const Spacer(),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB41214),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    "gender": selectedGender,
                    "department": selectedDepartment,
                    "yearRange": yearRange,
                  });
                },
                child: Text(
                  "Apply",
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}