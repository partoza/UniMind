import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimind/views/profile_setup/selectionpage.dart';
import 'package:unimind/views/home/home_page.dart';
import 'package:unimind/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimind/views/terms_and_policy/temspolicy_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showLogin = true;
  bool _obscurePassword = true;
  bool _isGoogleSigningIn = false;
  bool _isEmailLoading = false;

  // Login form controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  // Register form controllers
  final TextEditingController _registerFirstNameController = TextEditingController();
  final TextEditingController _registerLastNameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _registerConfirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerFirstNameController.dispose();
    _registerLastNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  String _getUserFriendlyErrorMessage(dynamic error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
        return 'No account found with this email address. Please check your email or register for a new account.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'email-already-in-use':
        return 'An account already exists with this email address. Please try logging in instead.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password with at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'invalid-credential': 
        return 'The email or password is incorrect. Please try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      default:
        return 'An unexpected error occurred. Please try again. (${error.code})';
    }
  }

  // firebase_core.FirebaseException fallback
  if (error is FirebaseException) {
    return error.message ?? 'A Firebase error occurred. Please try again.';
  }

  final s = error?.toString() ?? '';
  if (s.toLowerCase().contains('network')) {
    return 'Network error. Please check your internet connection and try again.';
  }
  if (s.toLowerCase().contains('wrong') && s.toLowerCase().contains('password')) {
    return 'Incorrect password. Please try again.';
  }

  return 'Something went wrong. Please try again.';
}

  Future<void> _handleEmailLogin() async {
    if (_loginEmailController.text.isEmpty || _loginPasswordController.text.isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    setState(() => _isEmailLoading = true);

    try {
      final User? user = await AuthService().signInWithEmailAndPassword(
        _loginEmailController.text.trim(),
        _loginPasswordController.text,
      );

      if (user != null) {
        print("Signed in as ${user.email}");

        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final data = snapshot.data();
        final profileComplete = data?['profileComplete'] ?? false;

        if (profileComplete) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SelectionPage()),
          );
        }
      } else {
        _showErrorDialog('Login failed. Please check your credentials.');
      }
    } on FirebaseAuthException catch (e) {
      print('[LoginPage] Caught FirebaseAuthException: code=${e.code}, message=${e.message}');
      _showErrorDialog(_getUserFriendlyErrorMessage(e));
    } catch (e, st) {
      print('[LoginPage] Unknown error: type=${e.runtimeType}, value=$e\n$st');
      _showErrorDialog(_getUserFriendlyErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isEmailLoading = false);
    }
  }

  Future<void> _handleEmailRegister() async {
    // Validation
    if (_registerFirstNameController.text.isEmpty ||
        _registerLastNameController.text.isEmpty ||
        _registerEmailController.text.isEmpty ||
        _registerPasswordController.text.isEmpty ||
        _registerConfirmPasswordController.text.isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    if (_registerPasswordController.text != _registerConfirmPasswordController.text) {
      _showErrorDialog('Passwords do not match. Please make sure both passwords are identical.');
      return;
    }

    if (_registerPasswordController.text.length < 6) {
      _showErrorDialog('Password must be at least 6 characters long for security.');
      return;
    }

    // Email format validation
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(_registerEmailController.text.trim())) {
      _showErrorDialog('Please enter a valid email address (e.g., name@example.com).');
      return;
    }

    setState(() => _isEmailLoading = true);

    try {
      final User? user = await AuthService().registerWithEmailAndPassword(
        _registerEmailController.text.trim(),
        _registerPasswordController.text,
        _registerFirstNameController.text.trim(),
        _registerLastNameController.text.trim(),
      );

      if (user != null) {
        print("Registered as ${user.email}");
        
        // Navigate to profile setup after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SelectionPage()),
        );
      } else {
        _showErrorDialog('Registration failed. Please try again.');
      }
    } catch (e) {
      print("Email Registration Error: $e");
      _showErrorDialog(_getUserFriendlyErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _isEmailLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: const Color(0xFFB41214)),
            const SizedBox(width: 8),
            Text(
              'Oops!',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: const Color(0xFFB41214),
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFB41214),
            ),
            child: Text(
              'Got it',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              'Success!',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: Colors.green,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Fixed Background Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 60),
                Image.asset(
                  "assets/icon/logoIconWhite.png",
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 5),
                Text(
                  "Study ta GA!",
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Login Container
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: showLogin ? 0 : -size.height,
            child: Container(
              height: size.height * 0.66,
              width: double.infinity,
              padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Login",
                    style: GoogleFonts.montserrat(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB41214),
                    ),
                  ),
                  Text(
                    " Login with your existing credentials.",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _loginEmailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      floatingLabelStyle: TextStyle(color: Color(0xFFB41214)),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFB41214),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _loginPasswordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      floatingLabelStyle: TextStyle(color: Color(0xFFB41214)),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFB41214),
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Forgot Password?",
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffb41214),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffb41214),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isEmailLoading ? null : _handleEmailLogin,
                      child: _isEmailLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              "Login Now",
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Doesn't have an account?",
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => showLogin = false),
                          child: Text(
                            "Register Here",
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffb41214),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Colors.black26, thickness: 1),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 0,
                          bottom: 0,
                        ),
                        child: Text(
                          "or Login with",
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Colors.black26, thickness: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Google button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isGoogleSigningIn ? null : () async {
                        setState(() {
                          _isGoogleSigningIn = true;
                        });

                        try {
                          final user = await AuthService().signInWithGoogle();
                          if (user != null) {
                            print("Signed in as ${user.displayName}");

                            final snapshot = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .get();

                            final data = snapshot.data();
                            final profileComplete = data?['profileComplete'] ?? false;

                            if (profileComplete) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SelectionPage(),
                                ),
                              );
                            }
                          } else {
                            _showErrorDialog('Google sign-in was cancelled. Please try again.');
                          }
                        } catch (e) {
                          print("Google Sign-In error: $e");
                          _showErrorDialog('Unable to sign in with Google. Please check your internet connection and try again.');
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isGoogleSigningIn = false;
                            });
                          }
                        }
                      },
                      child: _isGoogleSigningIn
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFB41214),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Signing in...",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/google icon.png",
                                  height: 20,
                                  width: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Continue with Google",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                        children: [
                          const TextSpan(
                            text: "By signing up, you agree to our ",
                          ),
                          TextSpan(
                            text: "Terms",
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffb41214),
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TermsScreen(),
                                  ),
                                );
                              },
                          ),
                          const TextSpan(
                            text: ". See how we use your data in our ",
                          ),
                          TextSpan(
                            text: "Privacy Policy",
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffb41214),
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TermsScreen(),
                                  ),
                                );
                              },
                          ),
                          const TextSpan(text: "."),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Register Container
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: showLogin ? -size.height : 0,
            child: Container(
              height: size.height * 0.68,
              width: double.infinity,
              padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Register",
                    style: GoogleFonts.montserrat(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB41214),
                    ),
                  ),
                  Text(
                    " Please fill in all fields to register.",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _registerFirstNameController,
                    decoration: InputDecoration(
                      labelText: "First Name",
                      floatingLabelStyle: TextStyle(color: Color(0xFFB41214)),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFB41214),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 7),
                  TextField(
                    controller: _registerLastNameController,
                    decoration: InputDecoration(
                      labelText: "Last Name",
                      floatingLabelStyle: TextStyle(color: Color(0xFFB41214)),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFB41214),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 7),
                  TextField(
                    controller: _registerEmailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      floatingLabelStyle: TextStyle(color: Color(0xFFB41214)),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFB41214),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _registerPasswordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      floatingLabelStyle: TextStyle(color: Color(0xFFB41214)),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFB41214),
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  TextField(
                    controller: _registerConfirmPasswordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      floatingLabelStyle: TextStyle(color: Color(0xFFB41214)),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFB41214),
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffb41214),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isEmailLoading ? null : _handleEmailRegister,
                      child: _isEmailLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              "Register Now",
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "I already have an account,",
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => showLogin = true),
                          child: Text(
                            "Back to Login",
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffb41214),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}