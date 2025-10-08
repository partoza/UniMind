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
  
  // Use existing avatar asset
  final String _defaultAvatar = "assets/avatar1.jpg"; // Use existing avatar

  @override
  void initState() {
    super.initState();
    // Notify parent that default avatar is selected initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSelect(File(_defaultAvatar)); // Notify parent with default avatar
    });
  }

  void _selectDefaultAvatar() {
    setState(() {
      _selectedAvatar = 0; // 0 for default avatar
      _uploadedImage = null; // Clear uploaded image when selecting default
    });
    // Notify parent about the selection
    widget.onSelect(File(_defaultAvatar));
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
        // Notify parent about the uploaded image
        widget.onSelect(_uploadedImage);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isVerySmallScreen = size.height < 600;

    return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05, // Reduced padding for small screens
            vertical: isSmallScreen ? 10 : 20,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Title Section
                Column(
                  children: [
                    Text(
                      "Add Profile Picture",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: isVerySmallScreen ? 18 : 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB41214),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                      child: Text(
                        "Choose the default avatar or upload your own image",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: isVerySmallScreen ? 11 : 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),

                // Selected Avatar Section
                Column(
                  children: [
                    SizedBox(height: isSmallScreen ? 20 : 30),
                    _buildResponsiveSelectedAvatar(size),
                    const SizedBox(height: 15),
                    Text(
                      _uploadedImage != null 
                        ? "Your Uploaded Image" 
                        : _selectedAvatar == 0 
                          ? "Default Program Avatar" 
                          : "No Image Selected",
                      style: GoogleFonts.montserrat(
                        fontSize: isVerySmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                // Upload Button Section
                Column(
                  children: [
                    SizedBox(height: isSmallScreen ? 20 : 30),
                    SizedBox(
                      width: double.infinity,
                      height: isSmallScreen ? 45 : 50,
                      child: ElevatedButton.icon(
                        onPressed: _uploadImage,
                        icon: Icon(
                          Icons.photo, 
                          color: Colors.white,
                          size: isSmallScreen ? 18 : 20,
                        ),
                        label: Text(
                          "Upload Your Own Image",
                          style: GoogleFonts.montserrat(
                            fontSize: isVerySmallScreen ? 12 : 14,
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
                  ],
                ),

                // Divider Section
                Column(
                  children: [
                    SizedBox(height: isSmallScreen ? 15 : 20),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Colors.grey)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            "OR",
                            style: GoogleFonts.montserrat(
                              fontSize: isVerySmallScreen ? 10 : 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),

                // Default Avatar Section
                Column(
                  children: [
                    SizedBox(height: isSmallScreen ? 15 : 20),
                    Center(
                      child: GestureDetector(
                        onTap: _selectDefaultAvatar,
                        child: Container(
                          width: isSmallScreen ? 80 : 100,
                          height: isSmallScreen ? 80 : 100,
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
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            image: DecorationImage(
                              image: AssetImage(_defaultAvatar),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Use Default Avatar",
                      style: GoogleFonts.montserrat(
                        fontSize: isVerySmallScreen ? 10 : 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isSmallScreen ? 20 : 30),
              ],
            ),
          ),
    );
  }

  Widget _buildResponsiveSelectedAvatar(Size size) {
    final isSmallScreen = size.height < 700;
    final isVerySmallScreen = size.height < 600;
    final avatarRadius = isVerySmallScreen ? 100.0 : (isSmallScreen ? 110.0 : 130.0);

    if (_uploadedImage != null) {
      return CircleAvatar(
        backgroundColor: Colors.grey[200],
        backgroundImage: FileImage(_uploadedImage!),
        radius: avatarRadius,
      );
    } else if (_selectedAvatar == 0) {
      return CircleAvatar(
        backgroundColor: Colors.grey[200],
        backgroundImage: AssetImage(_defaultAvatar),
        radius: avatarRadius,
      );
    } else {
      return Container(
        width: avatarRadius * 2,
        height: avatarRadius * 2,
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
          size: isVerySmallScreen ? 60 : (isSmallScreen ? 80 : 100),
          color: Colors.grey[600],
        ),
      );
    }
  }
}