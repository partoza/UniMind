import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart' as img_picker;
import 'dart:io';
// 💡 Import the new service file
import 'package:unimind/services/ibb_service.dart'; // Adjust path as needed

class AvatarSelect extends StatefulWidget {
  // 💡 Added departmentCode to determine the default avatar asset
  const AvatarSelect({
    super.key, 
    required this.onSelect, 
    required this.departmentCode,
  });

  // The parent (SelectionPage) expects the final path/URL: 
  // String for default asset path OR String for uploaded URL.
  final ValueChanged<String?> onSelect;
  final String departmentCode;

  @override
  State<AvatarSelect> createState() => _AvatarSelectState();
}

class _AvatarSelectState extends State<AvatarSelect> {
  // Use a string to hold the final path/URL selected by the user
  String? _selectedImagePathOrUrl; 
  
  // Use a temporary File to hold the local image picked from the gallery
  File? _tempPickedFile; 
  
  final img_picker.ImagePicker _picker = img_picker.ImagePicker();
  
  // 💡 Getter for the current default avatar path based on departmentCode
  String get _defaultAvatarPath {
    // Uses the file structure you provided: assets/avatar/cceavatar.png
    return "assets/avatar/${widget.departmentCode.toLowerCase()}avatar.png";
  }

  @override
  void initState() {
    super.initState();
    // 💡 Initialize with the department's default avatar asset path
    _selectedImagePathOrUrl = _defaultAvatarPath;

    // Notify parent that default avatar is selected initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSelect(_selectedImagePathOrUrl);
    });
  }

  // 💡 Updates to select the default avatar
  void _selectDefaultAvatar() {
    setState(() {
      _selectedImagePathOrUrl = _defaultAvatarPath;
      _tempPickedFile = null; // Clear temporary file
    });
    widget.onSelect(_selectedImagePathOrUrl);
  }

  // 💡 Updates for image upload using the API service
  Future<void> _uploadImage() async {
    try {
      final img_picker.XFile? image = await _picker.pickImage(
        source: img_picker.ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      
      if (image != null) {
        final pickedFile = File(image.path);
        
        // 1. Show the picked image locally while uploading
        setState(() {
          _tempPickedFile = pickedFile;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading image...')),
        );
        
        // 2. Call the IBB Service to upload
        final imageUrl = await IBBService.uploadImage(pickedFile);

        if (imageUrl != null) {
          // 3. Update state with the final URL from IBB
          setState(() {
            _selectedImagePathOrUrl = imageUrl;
            // Note: _tempPickedFile remains non-null to display the image 
            // until the parent widget handles navigation.
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully!')),
          );

          // 4. Notify parent with the public URL
          widget.onSelect(_selectedImagePathOrUrl);
          
        } else {
          // Upload failed, revert to default avatar/no selection
          setState(() {
            _tempPickedFile = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image upload failed. Please try again.')),
          );
          // Re-select default if the upload failed
          _selectDefaultAvatar();
        }
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
        horizontal: size.width * 0.05,
        vertical: isSmallScreen ? 10 : 20,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 100, // Adjusted height
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
                    "Choose the default department avatar or upload your own image",
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
                  _selectedImagePathOrUrl == _defaultAvatarPath
                    ? "Default Program Avatar" 
                    : "Your Custom Image",
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

            // Default Avatar Section (Now a simple button to revert)
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
                          color: _selectedImagePathOrUrl == _defaultAvatarPath
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
                        // 💡 Use the computed default path
                        image: DecorationImage(
                          image: AssetImage(_defaultAvatarPath),
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

  // 💡 Updated to handle local file (during upload) or the final URL/Asset path
  Widget _buildResponsiveSelectedAvatar(Size size) {
    final isVerySmallScreen = size.height < 600;
    final isSmallScreen = size.height < 700;
    final avatarRadius = isVerySmallScreen ? 100.0 : (isSmallScreen ? 110.0 : 130.0);

    // 1. Show the locally picked image while upload is in progress
    if (_tempPickedFile != null) {
      return CircleAvatar(
        backgroundColor: Colors.grey[200],
        backgroundImage: FileImage(_tempPickedFile!),
        radius: avatarRadius,
      );
    } 
    // 2. Show the department's default avatar
    else if (_selectedImagePathOrUrl == _defaultAvatarPath) {
      return CircleAvatar(
        backgroundColor: Colors.grey[200],
        backgroundImage: AssetImage(_defaultAvatarPath),
        radius: avatarRadius,
      );
    } 
    // 3. Show the uploaded image (from URL)
    else if (_selectedImagePathOrUrl != null) {
      return CircleAvatar(
        backgroundColor: Colors.grey[200],
        // Use NetworkImage for the URL returned by IBB
        backgroundImage: NetworkImage(_selectedImagePathOrUrl!),
        radius: avatarRadius,
      );
    }
    // Fallback (Should not happen if initialized correctly)
    else {
      return Container(
        width: avatarRadius * 2,
        height: avatarRadius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: Icon(
          Icons.person,
          size: isVerySmallScreen ? 60 : 80,
          color: Colors.grey[600],
        ),
      );
    }
  }
}