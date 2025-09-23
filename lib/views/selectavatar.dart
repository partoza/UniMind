import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart' as img_picker;
import 'dart:io';

class AvatarSelect extends StatefulWidget {
  const AvatarSelect({super.key, required this.onSelect});

  final ValueChanged<File?> onSelect;

  @override
  State<AvatarSelect> createState() => _AvatarSelectState();
}

class _AvatarSelectState extends State<AvatarSelect> {
  int _selectedAvatar = 0; // Changed from -1 to 0 (auto-select default avatar)
  File? _uploadedImage;
  final img_picker.ImagePicker _picker = img_picker.ImagePicker();
  
  // Single default avatar based on program
  final String _defaultAvatar = "assets/CCE_default_avatar.png"; // Program-based avatar

  void _selectDefaultAvatar() {
    setState(() {
      _selectedAvatar = 0; // 0 for default avatar
      _uploadedImage = null; // Clear uploaded image when selecting default
    });
  }

  Future<void> _uploadImage() async {
    try {
      final img_picker.XFile? image = await _picker.pickImage(
        source: img_picker.ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _uploadedImage = File(image.path);
          _selectedAvatar = -1; // Clear predefined selection when uploading
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Widget _buildSelectedAvatar() {
    if (_uploadedImage != null) {
      return CircleAvatar(
        backgroundColor: Colors.grey[200],
        backgroundImage: FileImage(_uploadedImage!),
        radius: 130,
      );
    } else if (_selectedAvatar == 0) {
      return CircleAvatar(
        backgroundColor: Colors.grey[200],
        backgroundImage: AssetImage(_defaultAvatar),
        radius: 130,
      );
    } else {
      return Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
          border: Border.all(
            color: const Color(0xFFB41214),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.person,
          size: 100,
          color: Colors.grey[600],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Title
            Text(
              "Add Profile Picture",
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB41214),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Choose the default avatar or upload your own image",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            // Selected Avatar in Center
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSelectedAvatar(),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    _uploadedImage != null 
                      ? "Your Uploaded Image" 
                      : _selectedAvatar == 0 
                        ? "Default Program Avatar" 
                        : "No Image Selected",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Upload Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _uploadImage,
                icon: const Icon(Icons.upload, color: Colors.white),
                label: Text(
                  "Upload Your Own Image",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB41214),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Divider with "OR" text
            Row(
              children: [
                const Expanded(child: Divider(color: Colors.grey)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "OR",
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: Colors.grey)),
              ],
            ),

            const SizedBox(height: 20),

            // Single Default Avatar Option
            Center(
              child: GestureDetector(
                onTap: _selectDefaultAvatar,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedAvatar == 0
                          ? const Color(0xFFB41214)
                          : Colors.grey[400]!,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    image: DecorationImage(
                      image: AssetImage(_defaultAvatar),
                      fit: BoxFit.cover, // This fills the entire circle without gaps
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}