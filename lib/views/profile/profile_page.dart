import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimind/views/auth/login_page.dart';
import 'package:unimind/views/follow_request/follow_page.dart';
import 'package:unimind/views/profile/edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> signOutUser(BuildContext context) async {
  final googleSignIn = GoogleSignIn();

  // Navigate to full-screen signing out page
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const _SignOutPage()),
  );

  // The sign out logic will be handled in the _SignOutPage widget
}

// A class to handle all department-related data and logic.
class DepartmentData {
  // Department color map
  static const Map<String, String> _colorHexMap = {
    'CAE': '#30E8FD',
    'CAFAE': '#6D6D6D',
    'CBAE': '#FFDD00',
    'CCE': '#FFDE00',
    'CHE': '#AA00FF',
    'CCJE': '#FF3700',
    'CASE': '#299504',
    'CEE': '#FF9D00',
    'CHSE': '#75B8FF',
    'CTE': '#1E05FF',
  };

  // Converts a hex string to a Flutter Color object.
  static Color _hexToColor(String hexString) {
    final hex = hexString.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  // Generates a lighter shade of the primary color for the gradient end.
  static Color _getLighterShade(Color color) {
    return Color.fromARGB(
      255,
      (color.red + (255 - color.red) * 0.5).round(),
      (color.green + (255 - color.green) * 0.5).round(),
      (color.blue + (255 - color.blue) * 0.5).round(),
    );
  }

  // Returns the start and end colors for the LinearGradient.
  static List<Color> getGradientColors(String department) {
    final hexColor =
        _colorHexMap[department.toUpperCase()] ?? '#B0B0B0'; // Default gray
    final primaryColor = _hexToColor(hexColor);
    final lightColor = _getLighterShade(primaryColor);
    return [primaryColor, lightColor];
  }

  // Returns the asset path for the department logo.
  static String getDepartmentLogoPath(String department) {
    final String code = department.toUpperCase();
    switch (code) {
      case 'CAE':
        return 'assets/depLogo/caelogo.png';
      case 'CAFAE':
        return 'assets/depLogo/cafaelogo.png';
      case 'CBAE':
        return 'assets/depLogo/cbaelogo.png';
      case 'CCE':
        return 'assets/depLogo/ccelogo.png';
      case 'CHE':
        return 'assets/depLogo/chelogo.png';
      case 'CCJE':
        return 'assets/depLogo/ccjelogo.png';
      case 'CASE':
        return 'assets/depLogo/caselogo.png';
      case 'CEE':
        return 'assets/depLogo/ceelogo.png';
      case 'CHSE':
        return 'assets/depLogo/chselogo.png';
      case 'CTE':
        return 'assets/depLogo/ctelogo.png';
      default:
        return 'assets/depLogo/defaultlogo.png'; // Fallback
    }
  }
}

// Helper widget to build consistent, modern text fields with a toggle eye icon
// NOTE: This must be defined inside your _EditProfilePageState class or as a private stateful widget.

class _PasswordTextFieldWithToggle extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;

  const _PasswordTextFieldWithToggle({
    required this.controller,
    required this.labelText,
    this.validator,
  });

  @override
  __PasswordTextFieldWithToggleState createState() =>
      __PasswordTextFieldWithToggleState();
}

class __PasswordTextFieldWithToggleState
    extends State<_PasswordTextFieldWithToggle> {
  // State to manage password visibility
  bool _isObscure = true;

  // Hardcoded colors
  static const Color primaryRed = Color(0xFFB41214);
  static const Color textPrimary = Color(0xFF1A1D1F);
  static const Color textSecondary = Color(0xFF6F767E);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: widget.controller,
        // Use the local state to determine obscurity
        obscureText: _isObscure,
        validator: widget.validator,
        style: GoogleFonts.montserrat(color: textPrimary, fontSize: 14),
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: GoogleFonts.montserrat(color: textSecondary),
          filled: true,
          fillColor: Colors.white,
          // 1. SMALLER PLACEHOLDER: Reduced vertical padding from 14 to 10
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryRed, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          // 2. FUNCTIONAL EYE ICON: Trailing widget to toggle visibility
          suffixIcon: IconButton(
            icon: Icon(
              _isObscure
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: textSecondary,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isObscure = !_isObscure;
              });
            },
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String? userId; // If null, shows current user's profile

  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // ADDED: GoogleSignIn instance for account linking
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Use provided userId or current user's ID
  String get _targetUserId => widget.userId ?? _auth.currentUser!.uid;
  bool get _isCurrentUser =>
      widget.userId == null || widget.userId == _auth.currentUser?.uid;

  User? get currentUser => _auth.currentUser;

  // ADDED: State management for follow functionality
  bool _isFollowing = false;
  bool _isFollowLoading = false;

  // ADDED: State management for account linking and password changes
  bool _isLinkingGoogle = false;
  bool _isSettingPassword = false;
  bool _isChangingPassword = false;

  // ADDED: Getter to check if user has a password provider
  bool get _hasPasswordProvider {
    if (currentUser == null) return false;
    return currentUser!.providerData.any(
      (provider) => provider.providerId == 'password',
    );
  }

  // ADDED: Getter to check if user has a Google provider
  bool get _hasGoogleProvider {
    if (currentUser == null) return false;
    return currentUser!.providerData.any(
      (provider) => provider.providerId == 'google.com',
    );
  }

  @override
  void initState() {
    super.initState();
    // ADDED: Check follow status if viewing another user's profile
    if (!_isCurrentUser && currentUser != null) {
      _checkFollowStatus();
    }
  }

  // ADDED: Function to check if the current user is following the target user
  Future<void> _checkFollowStatus() async {
    if (currentUser == null) return;
    try {
      final followDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('following')
          .doc(_targetUserId)
          .get();
      setState(() {
        _isFollowing = followDoc.exists;
      });
    } catch (e) {
      print("Error checking follow status: $e");
    }
  }

  // ADDED: Function to link a Google account
  Future<void> _linkGoogleAccount() async {
    if (_isLinkingGoogle || currentUser == null) return;
    setState(() => _isLinkingGoogle = true);

    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLinkingGoogle = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await currentUser!.linkWithCredential(credential);

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      final Map<String, dynamic>? currentUserData = userDoc.data();

      Map<String, dynamic> updateData = {};

      final currentDisplayName = currentUserData?['displayName'] as String?;
      if (currentDisplayName == null || currentDisplayName.isEmpty) {
        updateData['displayName'] =
            currentUser!.displayName ?? googleUser.displayName;
      }

      final currentAvatarPath = currentUserData?['avatarPath'] as String?;
      if (currentAvatarPath == null || currentAvatarPath.isEmpty) {
        updateData['avatarPath'] = currentUser!.photoURL ?? googleUser.photoUrl;
      }

      if (updateData.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .update(updateData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google account linked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to link Google account.';
      if (e.code == 'provider-already-linked') {
        errorMessage = 'This Google account is already linked to another user.';
      } else if (e.code == 'credential-already-in-use') {
        errorMessage = 'This Google account is already in use by another user.';
      }
      await _googleSignIn.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("Error linking Google account: $e");
      await _googleSignIn.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to link Google account. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLinkingGoogle = false);
      }
    }
  }

  // ADDED: Function to set a password for a Google-only user
  Future<void> _setPassword() async {
    // NOTE: Hardcoded colors used throughout the function (copied from _changePassword).
    const Color primaryRed = Color(0xFFB41214);
    const Color textPrimary = Color(0xFF1A1D1F);
    const Color textSecondary = Color(0xFF6F767E);
    const Color backgroundColor = Color(0xFFF8F9FA);

    if (_isSettingPassword || currentUser == null) return;

    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.only(bottom: viewInsets),
          child: Container(
            constraints: BoxConstraints(
              // Allow it to take up a maximum of 90% of the screen height
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: const BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar (The small gray indicator at the top)
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Title
                    Text(
                      'Set Your Password',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: primaryRed,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Set a password to enable email/password login for your account. This will secure your Google-linked account.',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // 1. New Password Field (using the new widget)
                    _PasswordTextFieldWithToggle(
                      controller: newPasswordController,
                      labelText: 'New Password',
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters.';
                        }
                        return null;
                      },
                    ),

                    // 2. Confirm New Password Field (using the new widget)
                    _PasswordTextFieldWithToggle(
                      controller: confirmPasswordController,
                      labelText: 'Confirm Password',
                      validator: (value) {
                        if (value != newPasswordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 10),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: TextButton.styleFrom(
                              foregroundColor: textSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                // If validation passes, pop true to proceed with update
                                Navigator.pop(context, true);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Set Password',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // ... (The Firebase logic below this point remains the same as your original _setPassword)

    if (result == true) {
      setState(() => _isSettingPassword = true);
      try {
        final AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser!.email!,
          password: newPasswordController.text, // Use newPasswordController
        );
        await currentUser!.linkWithCredential(credential);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password set successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Failed to set password.';
        if (e.code == 'provider-already-linked') {
          errorMessage = 'Password is already set for this account.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'This email is already in use by another account.';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: primaryRed),
          );
        }
      } catch (e) {
        print("Error setting password: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to set password. Please try again.'),
              backgroundColor: primaryRed,
            ),
          );
        }
      } finally {
        // Dispose controllers and reset state
        newPasswordController.dispose();
        confirmPasswordController.dispose();
        if (mounted) {
          setState(() => _isSettingPassword = false);
        }
      }
    }
  }

  Future<void> _changePassword() async {
    // NOTE: Hardcoded colors used throughout the function.
    const Color primaryRed = Color(0xFFB41214);
    const Color textPrimary = Color(0xFF1A1D1F);
    const Color textSecondary = Color(0xFF6F767E);
    const Color backgroundColor = Color(0xFFF8F9FA);

    if (_isChangingPassword || currentUser == null || !_hasPasswordProvider) {
      return;
    }

    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    // NOTE: The _buildPasswordTextField helper is replaced by the stateful
    // _PasswordTextFieldWithToggle widget defined above.

    bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.only(bottom: viewInsets),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: const BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    Text(
                      'Change Your Password',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: primaryRed,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'You must re-authenticate with your current password for security before setting a new one.',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // 1. Current Password Field (using the new widget)
                    _PasswordTextFieldWithToggle(
                      controller: currentPasswordController,
                      labelText: 'Current Password',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your current password.';
                        }
                        return null;
                      },
                    ),

                    // 2. New Password Field (using the new widget)
                    _PasswordTextFieldWithToggle(
                      controller: newPasswordController,
                      labelText: 'New Password',
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'New password must be at least 6 characters.';
                        }
                        return null;
                      },
                    ),

                    // 3. Confirm New Password Field (using the new widget)
                    _PasswordTextFieldWithToggle(
                      controller: confirmPasswordController,
                      labelText: 'Confirm New Password',
                      validator: (value) {
                        if (value != newPasswordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: TextButton.styleFrom(
                              foregroundColor: textSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                Navigator.pop(context, true);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Update Password',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // ... (rest of the Firebase logic remains the same)
    if (result == true) {
      setState(() => _isChangingPassword = true);
      try {
        final AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser!.email!,
          password: currentPasswordController.text,
        );
        await currentUser!.reauthenticateWithCredential(credential);

        await currentUser!.updatePassword(newPasswordController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Failed to change password.';
        // ... (error handling logic)

        if (e.code == 'wrong-password') {
          errorMessage = 'The current password you entered is incorrect.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'The new password is too weak.';
        } else if (e.code == 'requires-recent-login') {
          errorMessage = 'Please log in again to change your password.';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: primaryRed),
          );
        }
      } catch (e) {
        print("Error changing password: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An unexpected error occurred. Please try again.'),
              backgroundColor: primaryRed,
            ),
          );
        }
      } finally {
        currentPasswordController.dispose();
        newPasswordController.dispose();
        confirmPasswordController.dispose();
        if (mounted) {
          setState(() => _isChangingPassword = false);
        }
      }
    }
  }

  // --- START: New Helper Widget for UI Consistency (Color Hardcoded) ---
  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required VoidCallback? onPressed,
    String? statusText,
    int? statusColorValue, // Use int for Color(value)
    bool isLoading = false,
    Widget? leadingWidget,
  }) {
    // NOTE: These colors are hardcoded as requested.
    final Color primaryRed = const Color(0xFFB41214);
    final Color textPrimary = const Color(0xFF1A1D1F);
    final Color textSecondary = const Color(0xFF6F767E);
    final Color surfaceColor = Colors.white;

    final Color statusColor = statusColorValue != null
        ? Color(statusColorValue)
        : textSecondary;

    return Padding(
      // Added vertical padding here to space out the individual "cards"
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(
          15,
        ), // Slightly larger radius for the ink well effect
        child: Material(
          color: surfaceColor,
          // Using slight elevation to give a modern "lifted" card effect
          elevation: 1.0,
          borderRadius: BorderRadius.circular(15),
          shadowColor: Colors.black.withOpacity(0.1),
          child: Container(
            // Adjusted padding to be symmetrical inside the card
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              // Light border when enabled, stronger border if disabled or error state (optional)
              border: Border.all(
                color: onPressed == null
                    ? Colors.grey.shade200
                    : Colors
                          .transparent, // Border is usually removed when elevation is used
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Leading Icon or Widget
                leadingWidget ??
                    Icon(
                      icon,
                      color: onPressed == null ? Colors.grey : primaryRed,
                      size: 24,
                    ),
                const SizedBox(width: 16),

                // Title and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      if (statusText != null)
                        Text(
                          statusText,
                          style: GoogleFonts.montserrat(
                            color: statusColor,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),

                // Trailing Indicator (Loading or Arrow)
                isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(primaryRed),
                        ),
                      )
                    : Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: onPressed == null
                            ? Colors.grey[400]
                            : textSecondary,
                        size: 16,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // --- END: New Helper Widget ---

  // ADDED: Function to build the entire account linking UI section
  // NOTE: This version removes the dependency on the external _buildCard widget.
  Widget _buildAccountLinkingSection() {
    // NOTE: These colors are hardcoded as requested.
    final Color primaryRed = const Color(0xFFB41214);
    final Color textPrimary = const Color(0xFF1A1D1F);
    final Color textSecondary = const Color(0xFF6F767E);

    // Use a simplified version of _sectionTitle for consistency
    Widget _sectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
      );
    }

    if (!_isCurrentUser || currentUser == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _sectionTitle("Account Security & Linking"),

        // 1. Change Password (for email/password users)
        if (_hasPasswordProvider)
          _buildSecurityOption(
            icon: Icons.lock_reset_rounded,
            title: "Change Password",
            statusText: "Update your current login password",
            onPressed: _isChangingPassword ? null : _changePassword,
            isLoading: _isChangingPassword,
          ),

        // 2. Link Google Account (for email/password users)
        if (!_hasGoogleProvider && _hasPasswordProvider)
          _buildSecurityOption(
            icon: Icons.link_rounded,
            title: "Link Google Account",
            statusText: "Enable one-tap login with Google",
            statusColorValue: 0xFF4285F4, // Google Blue
            onPressed: _isLinkingGoogle ? null : _linkGoogleAccount,
            isLoading: _isLinkingGoogle,
            // Use the custom leading widget for the Google icon
            leadingWidget: Image.asset(
              "assets/google icon.png",
              height: 24,
              width: 24,
            ),
          ),

        // 3. Set Password (for Google users)
        if (!_hasPasswordProvider && _hasGoogleProvider)
          _buildSecurityOption(
            icon: Icons.lock_outline_rounded,
            title: "Set Password",
            statusText: "Add a password for email login access",
            onPressed: _isSettingPassword ? null : _setPassword,
            isLoading: _isSettingPassword,
          ),

        // 4. Show current linked providers (Enhanced visualization)
        if (_hasGoogleProvider || _hasPasswordProvider)
          Padding(
            // Use padding to separate this info block from the buttons above
            padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // Use a very light background to distinguish it from the elevated buttons
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Active Login Methods:",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (_hasPasswordProvider)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: _hasGoogleProvider ? 6.0 : 0.0,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.email_rounded,
                            size: 20,
                            color: FollowPage.primaryRed,
                          ), // Green for Email
                          const SizedBox(width: 8),
                          Text(
                            "Email/Password",
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_hasGoogleProvider)
                    Row(
                      children: [
                        Image.asset(
                          "assets/google icon.png",
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Google Account",
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ADDED: Function to toggle follow/unfollow status
  Future<void> _toggleFollow() async {
    if (currentUser == null) return;
    setState(() {
      _isFollowLoading = true;
    });
    try {
      final currentUserRef = _firestore
          .collection('users')
          .doc(currentUser!.uid);
      final targetUserRef = _firestore.collection('users').doc(_targetUserId);
      final followRef = currentUserRef
          .collection('following')
          .doc(_targetUserId);

      if (_isFollowing) {
        // Unfollow
        await followRef.delete();
        await targetUserRef.update({'followerCount': FieldValue.increment(-1)});
        await currentUserRef.update({
          'followingCount': FieldValue.increment(-1),
        });
        setState(() {
          _isFollowing = false;
        });
      } else {
        // Follow
        await followRef.set({
          'followedAt': FieldValue.serverTimestamp(),
          'targetUserId': _targetUserId,
        });
        await targetUserRef.update({'followerCount': FieldValue.increment(1)});
        await currentUserRef.update({
          'followingCount': FieldValue.increment(1),
        });
        setState(() {
          _isFollowing = true;
        });
      }
    } catch (e) {
      print("Error toggling follow: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isFollowLoading = false;
      });
    }
  }

  // ADDED: Function to build the follow/following button
  Widget _buildFollowButton() {
    return _isFollowLoading
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          )
        : OutlinedButton(
            onPressed: _toggleFollow,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _isFollowing ? Colors.white70 : Colors.white,
              ),
              backgroundColor: _isFollowing ? Colors.white : Colors.transparent,
              foregroundColor: _isFollowing ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _isFollowing ? "Following" : "Follow",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
  }

  // ADDED: Function to build the back button
  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  String _getYearLevelString(dynamic yearLevel) {
    try {
      int level;
      if (yearLevel is int) {
        level = yearLevel;
      } else if (yearLevel is String) {
        final match = RegExp(r'\d+').firstMatch(yearLevel);
        level = match != null ? int.parse(match.group(0)!) : 1;
      } else {
        level = 1; // default
      }

      switch (level) {
        case 1:
          return '1st Year Student';
        case 2:
          return '2nd Year Student';
        case 3:
          return '3rd Year Student';
        case 4:
          return '4th Year Student';
        default:
          return 'Student';
      }
    } catch (e) {
      print("Error parsing year level: $e");
      return 'Student';
    }
  }

  dynamic _getUserData(
    Map<String, dynamic>? userData,
    String key, {
    dynamic defaultValue,
  }) {
    if (userData == null || !userData.containsKey(key)) {
      return defaultValue;
    }
    return userData[key];
  }

  // ADDED: Helper method to handle both network and asset images for the avatar
  ImageProvider _getAvatarImageProvider(String path) {
    if (path.startsWith('http') || path.startsWith('https')) {
      return NetworkImage(path);
    } else {
      return AssetImage(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Red Header with Smooth Curved Bottom
            ClipPath(
              clipper: _HeaderClipper(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 30,
                  left: 20,
                  right: 20,
                  bottom: 60,
                ),
                color: const Color(0xFFB41214),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection('users')
                      .doc(_targetUserId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildHeaderLoading();
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return _buildHeaderPlaceholder();
                    }
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>?;
                    return _buildHeaderContent(userData, context);
                  },
                ),
              ),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(_targetUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildBodyLoading();
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return _buildBodyPlaceholder();
                }
                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                return _buildBodyContent(userData, context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MODIFIED: Conditionally show back button
        if (!_isCurrentUser) _buildBackButton(),
        Text(
          _isCurrentUser ? "My Profile" : "Profile",
          style: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 150, height: 20, color: Colors.white24),
                  const SizedBox(height: 8),
                  Container(width: 100, height: 16, color: Colors.white24),
                  const SizedBox(height: 8),
                  // MODIFIED: Conditionally show edit/follow button
                  if (_isCurrentUser)
                    OutlinedButton(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white70),
                        backgroundColor: Colors.white24,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Edit Profile",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    )
                  else
                    _buildFollowButton(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MODIFIED: Conditionally show back button
        if (!_isCurrentUser) _buildBackButton(),
        Text(
          _isCurrentUser ? "My Profile" : "Profile",
          style: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage("assets/cce_male.jpg"),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isCurrentUser
                        ? (currentUser?.email ?? "Guest User")
                        : "User",
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _isCurrentUser ? "Complete your profile" : "User profile",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // MODIFIED: Conditionally show edit/follow button
                  if (_isCurrentUser)
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white70),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Edit Profile",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    _buildFollowButton(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderContent(
    Map<String, dynamic>? userData,
    BuildContext context,
  ) {
    final displayName = _getUserData(
      userData,
      'displayName',
      defaultValue: _isCurrentUser
          ? (currentUser?.email ?? "Unknown User")
          : "Unknown User",
    );
    final yearLevel = _getUserData(userData, 'yearLevel', defaultValue: 1);
    final avatarPath = _getUserData(
      userData,
      'avatarPath',
      defaultValue: "assets/cce_male.jpg",
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MODIFIED: Conditionally show back button
        if (!_isCurrentUser) _buildBackButton(),
        Text(
          _isCurrentUser ? "My Profile" : "Profile",
          style: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // MODIFIED: Use the helper for cleaner code
            CircleAvatar(
              radius: 45,
              backgroundImage: _getAvatarImageProvider(avatarPath.toString()),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName.toString(),
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _getYearLevelString(yearLevel),
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // MODIFIED: Conditionally show edit/follow button
                  if (_isCurrentUser)
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white70),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Edit Profile",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    _buildFollowButton(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBodyLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickInfoSectionLoading(),
          const SizedBox(height: 15),
          _sectionTitle("College Department"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[200],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school, size: 36, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 200,
                        height: 20,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 150,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _sectionTitle("My Bio"),
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
          ),
          if (_isCurrentUser) ...[
            const SizedBox(height: 40),
            buildLogoutButton(context),
            const SizedBox(height: 30),
          ],
        ],
      ),
    );
  }

  Widget _buildBodyPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickInfoSection(),
          const SizedBox(height: 2),
          _sectionTitle("College Department"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFCCCCCC), Color(0xFFEEEEEE)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    "assets/depLogo/defaultlogo.png",
                    height: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCurrentUser
                            ? "Complete your profile"
                            : "User profile",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isCurrentUser
                            ? "Add your department and program"
                            : "Profile information",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _sectionTitle("My Bio"),
          _infoCard(
            _isCurrentUser
                ? "No bio yet. You can add one by editing your profile."
                : "No bio available",
          ),
          if (_isCurrentUser) ...[
            const SizedBox(height: 40),
            buildLogoutButton(context),
            const SizedBox(height: 30),
          ],
        ],
      ),
    );
  }

  Widget _buildBodyContent(
    Map<String, dynamic>? userData,
    BuildContext context,
  ) {
    final department = _getUserData(
      userData,
      'department',
      defaultValue: "Department not set",
    );
    final program = _getUserData(
      userData,
      'program',
      defaultValue: "Program not set",
    );
    final gender = _getUserData(userData, 'gender', defaultValue: "Not set");
    final place = _getUserData(userData, 'place', defaultValue: "Not set");
    final strengths = _getUserData(
      userData,
      'strengths',
      defaultValue: <String>[],
    );
    final weaknesses = _getUserData(
      userData,
      'weaknesses',
      defaultValue: <String>[],
    );
    final rawBio = _getUserData(userData, 'bio');
    final bio = (rawBio == null || rawBio.trim().isEmpty)
        ? 'No Bio Added'
        : rawBio;
    final departmentLogo = DepartmentData.getDepartmentLogoPath(
      department.toString(),
    );
    final departmentColors = DepartmentData.getGradientColors(
      department.toString(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickInfoSectionWithData(gender.toString(), place.toString()),
          const SizedBox(height: 2),
          _sectionTitle("College Department"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: departmentColors,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(departmentLogo, height: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        department.toString(),
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        program.toString(),
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _sectionTitle("My Bio"),
          _infoCard(bio.toString()),
          const SizedBox(height: 15),
          if (strengths is List && strengths.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("Strengths"),
                const SizedBox(height: 8),
                _buildSkillsChips(
                  List<String>.from(strengths),
                  isImprovement: false,
                ),
                const SizedBox(height: 15),
              ],
            ),
          if (weaknesses is List && weaknesses.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("Areas for Improvement"),
                const SizedBox(height: 8),
                _buildSkillsChips(
                  List<String>.from(weaknesses),
                  isImprovement: true,
                ),
                const SizedBox(height: 15),
              ],
            ),
          // MODIFIED: Conditionally show account linking section
          if (_isCurrentUser) _buildAccountLinkingSection(),
          if (_isCurrentUser) ...[
            const SizedBox(height: 40),
            buildLogoutButton(context),
            const SizedBox(height: 30),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickInfoSectionLoading() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [_buildQuickInfoItemLoading(), _buildQuickInfoItemLoading()],
      ),
    );
  }

  Widget _buildQuickInfoItemLoading() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.help_outline, size: 20, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(width: 60, height: 16, color: Colors.grey[300]),
        const SizedBox(height: 4),
        Container(width: 40, height: 12, color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildQuickInfoSectionWithData(String gender, String place) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickInfoItem("Gender", gender, Icons.person),
          _buildQuickInfoItem("Building", place, Icons.apartment),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _infoCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(text, style: GoogleFonts.montserrat(fontSize: 14)),
    );
  }

  Widget _buildQuickInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickInfoItem("Gender", "Not set", Icons.person),
          _buildQuickInfoItem("Building", "PS Building", Icons.apartment),
        ],
      ),
    );
  }

  Widget _buildQuickInfoItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFB41214).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: const Color(0xFFB41214)),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        Text(
          title,
          style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildSkillsChips(List<String> skills, {bool isImprovement = false}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isImprovement
                ? const LinearGradient(colors: [Colors.grey, Color(0xFF9E9E9E)])
                : const LinearGradient(
                    colors: [Color(0xFFB41214), Color(0xFFD32F2F)],
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isImprovement)
                const Icon(Icons.arrow_upward, size: 12, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                skill,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

Widget buildLogoutButton(BuildContext context) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    child: ElevatedButton.icon(
      onPressed: () async {
        final confirm = await _showLogoutConfirmation(context);
        if (confirm == true) {
          await signOutUser(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFDC2626),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFFDC2626).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.logout_rounded, size: 20),
      ),
      label: Text(
        "Sign Out",
        style: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFDC2626),
        ),
      ),
    ),
  );
}

Future<bool?> _showLogoutConfirmation(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFDC2626),
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Sign Out?",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to sign out? You'll need to log in again to access your account.",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Sign Out",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 30,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// ADDED: Full-screen Sign Out Page
class _SignOutPage extends StatefulWidget {
  const _SignOutPage();

  @override
  State<_SignOutPage> createState() => _SignOutPageState();
}

class _SignOutPageState extends State<_SignOutPage> {
  @override
  void initState() {
    super.initState();
    _performSignOut();
  }

  Future<void> _performSignOut() async {
    final googleSignIn = GoogleSignIn();

    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      await FirebaseAuth.instance.signOut();
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
      print("User logged out and disconnected from Google.");
    } catch (e) {
      print("Error during logout: $e");
    }

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/icon/logoIconMaroon.png",
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB41214)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Signing out",
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
