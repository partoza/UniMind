import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ProgramYearSelect extends StatefulWidget {
  // 💡 Updated callback to include programAcronym and automatically determined place
  final Function(String?, String?, int?, String?) onSelect;
  final String departmentCode;

  const ProgramYearSelect({
    super.key,
    required this.onSelect,
    required this.departmentCode,
  });

  @override
  State<ProgramYearSelect> createState() => _ProgramYearSelectState();
}

class _ProgramYearSelectState extends State<ProgramYearSelect> {
  String? selectedProgram;
  String? selectedProgramAcronym; // 💡 New state for the acronym
  int? selectedYear;
  String? selectedPlace; // 💡 New state for the place (auto-determined)

  // 💡 Comprehensive map updated with 'place' and restructured 'programs' to include acronyms
  final Map<String, Map<String, dynamic>> _departmentData = {
    "CAE": {
      "name": "College of Accounting Education",
      "place": "BE Building",
      "programs": {
        "Bachelor of Science in Accountancy": "BSA",
        "Bachelor of Science in Accounting Information System": "BSAIS",
        "Bachelor of Science in Internal Audit": "BSIA",
        "Bachelor of Science in Management Accounting": "BSMA",
      }
    },
    "CAFAE": {
      "name": "College of Architecture and Fine Arts Education",
      "place": "DPT Building",
      "programs": {
        "Bachelor of Science in Architecture": "BS Arch",
        "Bachelor of Fine Arts (Major in Painting)": "BFA",
        "Bachelor of Science in Urban and Regional Planning": "BSURP",
        "Bachelor of Science in Interior Design": "BSID",
      }
    },
    "CBAE": {
      "name": "College of Business Administration Education",
      "place": "Bolton Campus",
      "programs": {
        "Bachelor of Science in Business Administration Major in Financial Management": "BSBA-FM",
        "Bachelor of Science in Business Administration Major in Human Resource Management": "BSBA-HRM",
        "Bachelor of Science in Business Administration Major in Marketing Management": "BSBA-MM",
        "Bachelor of Science in Business Administration Major in Business Economics": "BSBA-BE",
        "Bachelor of Science in Entrepreneurship": "BSEnt",
        "Bachelor of Science in Legal Management": "BSLM",
        "Bachelor of Science in Real Estate Management": "BSREM",
      }
    },
    "CCE": {
      "name": "College of Computing Education",
      "place": "PS Building",
      "programs": {
        "Bachelor of Science in Information Technology": "BSIT",
        "Bachelor of Science in Information Systems": "BSIS",
        "Bachelor of Science in Computer Science": "BSCS",
        "Bachelor of Science in Entertainment and Multimedia Computing (Game Development)": "BSEMC-GD",
        "Bachelor of Science in Entertainment and Multimedia Computing (Digital Animation Technology)": "BSEMC-DA",
        "Bachelor of Library and Information Science": "BLIS",
        "Bachelor of Multimedia Arts": "BMA",
      }
    },
    "CHE": {
      "name": "College of Hospitality Education",
      "place": "FEA Building",
      "programs": {
        "Bachelor of Science in Hospitality Management": "BSHM",
        "Bachelor of Science in Tourism Management": "BSTM",
      }
    },
    "CCJE": {
      "name": "College of Criminal Justice Education",
      "place": "GET Building",
      "programs": {
        "Bachelor of Science in Criminology": "BSCrim",
        "Bachelor of Science in Industrial Security": "BSISec",
      }
    },
    "CASE": {
      "name": "College of Arts and Sciences Education",
      "place": "DPT Building",
      "programs": {
        "Bachelor of Arts in Communication": "BA Comm",
        "Bachelor of Arts in English Language": "BA English",
        "Bachelor of Arts in Political Science": "BA PolSci",
        "Bachelor of Arts in Broadcasting": "BA Broadcasting",
        "Bachelor of Public Administration": "BPA",
        "Bachelor of Arts in Multimedia Arts": "BA MMA",
        "Bachelor of Science in Psychology": "BS Psych",
        "Bachelor of Science in Environmental Science": "BS EnvSci",
        "Bachelor of Science in Forestry": "BS Forestry",
        "Bachelor of Science in Agroforestry": "BS Agroforestry",
        "Bachelor of Science in Biology": "BS Bio", // Removed majors for simplicity in the list
        "Bachelor of Science in Mathematics": "BS Math",
        "Bachelor of Science in Social Work": "BSSW",
      }
    },
    "CEE": {
      "name": "College of Engineering Education",
      "place": "BE Building",
      "programs": {
        "Bachelor of Science in Chemical Engineering": "BSChE",
        "Bachelor of Science in Civil Engineering": "BSCE",
        "Bachelor of Science in Computer Engineering": "BSCpE",
        "Bachelor of Science in Electrical Engineering": "BSEE",
        "Bachelor of Science in Electronics Engineering": "BSECE",
        "Bachelor of Science in Mechanical Engineering": "BSME",
      }
    },
    "CHSE": {
      "name": "College of Health Sciences Education",
      "place": "DPT Building",
      "programs": {
        "Bachelor of Science in Medical Laboratory Science": "BSMLS/BSMT",
        "Bachelor of Science in Nursing": "BSN",
        "Bachelor of Science in Nutrition and Dietetics": "BSND",
        "Bachelor of Science in Pharmacy": "BSP",
      }
    },
    "CTE": {
      "name": "College of Teacher Education",
      "place": "GET Building",
      "programs": {
        "Bachelor of Early Childhood Education": "BECEd",
        "Bachelor of Elementary Education": "BEEd",
        "Bachelor of Secondary Education": "BSEd",
        "Bachelor of Special Education": "BSEd-SPED",
        "Bachelor of Physical Education": "BPEd",
      }
    },
  };

  final List<String> years = [
    "1st Year College",
    "2nd Year College",
    "3rd Year College",
    "4th Year College",
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the place based on the departmentCode immediately
    selectedPlace = _departmentData[widget.departmentCode]?["place"];
  }

  void _updateSelection() {
    // 💡 Notify parent with all four pieces of data
    widget.onSelect(
      selectedProgram,
      selectedProgramAcronym,
      selectedYear,
      selectedPlace,
    );
  }

  String get _departmentName => _departmentData[widget.departmentCode]?["name"] ?? "College Department";

  Map<String, String> get _departmentPrograms => _departmentData[widget.departmentCode]?["programs"]?.cast<String, String>() ?? {};

  String get _logoPath => "assets/depLogo/${widget.departmentCode.toLowerCase()}logo.png";

  String _getProgramLabel(String programName, String acronym) {
    return "$programName ($acronym)";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final filteredPrograms = _departmentPrograms;

    // Define the shared dropdown styles
    final buttonStyle = ButtonStyleData(
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFFB41214)),
        color: Colors.white,
      ),
    );

    final menuStyle = DropdownStyleData(
      maxHeight: 200,
      padding: null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
    );

    const menuItemStyle = MenuItemStyleData(
      height: 50,
    );


    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Text(
              "Choose a Program and\nYear Level",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB41214),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "What program do you belong to in $_departmentName and year level?",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),

            // Department Badge
            Container(
              width: size.width * 0.8,
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFB41214),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Image.asset(_logoPath, width: 36, height: 36, fit: BoxFit.cover),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _departmentName,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Automatic Place According to Department
            if (selectedPlace != null) ...[
              const SizedBox(height: 10),
              Text(
                "Located in: $selectedPlace",
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],

            const SizedBox(height: 30),

            // Year Level Dropdown
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select a Year Level",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text("Choose Year",
                    style: GoogleFonts.montserrat(
                        fontSize: 14, color: Colors.grey[600])),
                value: selectedYear != null ? years[selectedYear! - 1] : null,
                items: years.map((year) {
                  return DropdownMenuItem<String>(
                    value: year,
                    child: Text(year,
                        style: GoogleFonts.montserrat(
                            fontSize: 14, color: Colors.black)),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedYear = value != null ? years.indexOf(value) + 1 : null;
                  });
                  _updateSelection();
                },
                // Applied common button style
                buttonStyleData: buttonStyle,
                // Added common menu item and dropdown styles
                menuItemStyleData: menuItemStyle,
                dropdownStyleData: menuStyle,
              ),
            ),

            const SizedBox(height: 25),

            // Program Dropdown
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select a Program",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text("Choose Program",
                    style: GoogleFonts.montserrat(
                        fontSize: 14, color: Colors.grey[600])),
                value: selectedProgram,
                items: filteredPrograms.entries.map((entry) {
                  final programName = entry.key;
                  final acronym = entry.value;
                  return DropdownMenuItem<String>(
                    value: programName,
                    child: Text(_getProgramLabel(programName, acronym),
                        style: GoogleFonts.montserrat(
                            fontSize: 14, color: Colors.black)),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedProgram = value;
                    // Store Program Acronym
                    selectedProgramAcronym = value != null ? filteredPrograms[value] : null;
                  });
                  _updateSelection();
                },
                // Applied common button style
                buttonStyleData: buttonStyle,
                // Using common menu item and dropdown styles
                menuItemStyleData: menuItemStyle,
                dropdownStyleData: menuStyle,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}