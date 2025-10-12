import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterPage extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;

  const FilterPage({super.key, this.initialFilters});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

String getOrdinal(int number) {
  switch (number) {
    case 1:
      return "1st";
    case 2:
      return "2nd";
    case 3:
      return "3rd";
    case 4:
      return "4th";
    default:
      return number.toString();
  }
}

class _FilterPageState extends State<FilterPage> {
  String? selectedGender;
  String? selectedDepartment;
  RangeValues yearRange = const RangeValues(1, 4);

  final List<String> genders = ["Male", "Female", "Other"];
  final List<Map<String, String>> departments = [
    {
      "name": "College of Accounting Education",
      "logo": "assets/depLogo/caelogo.png",
    },
    {
      "name": "College of Architecture and Fine Arts Education",
      "logo": "assets/depLogo/cafaelogo.png",
    },
    {
      "name": "College of Arts and Sciences Education",
      "logo": "assets/depLogo/caselogo.png",
    },
    {
      "name": "College of Business Administration Education",
      "logo": "assets/depLogo/cbaelogo.png",
    },
    {
      "name": "College of Computing Education",
      "logo": "assets/depLogo/ccelogo.png",
    },
    {
      "name": "College of Criminal Justice Education",
      "logo": "assets/depLogo/ccjelogo.png",
    },
    {
      "name": "College of Engineering Education",
      "logo": "assets/depLogo/ceelogo.png",
    },
    {
      "name": "College of Hospitality Education",
      "logo": "assets/depLogo/chelogo.png",
    },
    {
      "name": "College of Health and Sciences Education",
      "logo": "assets/depLogo/chselogo.png",
    },
    {
      "name": "College of Teachers Education",
      "logo": "assets/depLogo/ctelogo.png",
    },
  ];

  @override
  void initState() {
    super.initState();

    // Initialize with provided filters or defaults
    if (widget.initialFilters != null) {
      selectedGender = widget.initialFilters!['gender'];
      selectedDepartment = widget.initialFilters!['department'];
      yearRange =
          widget.initialFilters!['yearRange'] ?? const RangeValues(1, 4);
    }
  }

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
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  "Select Gender",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                value: selectedGender,
                items: genders.map((gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(
                      gender,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.black,
                      ),
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
                    border: Border.all(
                      color: const Color.fromARGB(255, 179, 179, 179),
                      width: 1,
                    ),
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
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Department Dropdown
            Text(
              "Which college department do you want to connect with?",
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
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
                        // Department Logo
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            dept["logo"]!,
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.03,
                        ),
                        // Department Name
                        Expanded(
                          child: Text(
                            dept["name"]!,
                            style: GoogleFonts.montserrat(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                              fontWeight: FontWeight.w500,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedDepartment = value);
                },
                buttonStyleData: ButtonStyleData(
                  height: 70,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                    color: Colors.white,
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
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

            // Year Level Range Slider
            Text(
              "What year level is your study buddy?",
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Year Level Filter Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current selection text
                  Text(
                    "Between ${getOrdinal(yearRange.start.toInt())} and ${getOrdinal(yearRange.end.toInt())} Year",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RangeSlider(
                    values: yearRange,
                    min: 1,
                    max: 4,
                    divisions: 3,
                    activeColor: const Color(0xFFB41214),
                    inactiveColor: Colors.grey[300],
                    labels: RangeLabels(
                      "${getOrdinal(yearRange.start.toInt())} Year",
                      "${getOrdinal(yearRange.end.toInt())} Year",
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        yearRange = values;
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

            // Clear Filters Button (only show if any filters are active)
            if (selectedGender != null ||
                selectedDepartment != null ||
                yearRange.start > 1 ||
                yearRange.end < 4)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      icon: const Icon(
                        Icons.refresh,
                        size: 20,
                      ), // Add a clear/reset icon
                      label: Text(
                        "Clear All Filters",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700, // Subtler color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedGender = null;
                          selectedDepartment = null;
                          yearRange = const RangeValues(1, 4);
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

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
                  "Apply Filters",
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
