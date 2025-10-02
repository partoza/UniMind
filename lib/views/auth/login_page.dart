import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimind/views/profile_setup/gender.dart';
import 'package:unimind/views/home/home_page.dart';
import 'package:unimind/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showLogin = true;
  bool _obscurePassword = true;

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
                image: AssetImage("assets/bg.png"), // your background image
                fit: BoxFit.cover, // covers entire screen
              ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 60),
                Image.asset("assets/icon/logoIconWhite.png", width: 120, height: 120),
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
              padding:  EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 0),
              decoration:  BoxDecoration(
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
                    decoration: InputDecoration(
                      labelText: "Username",
                      floatingLabelStyle: TextStyle(color: Color(0xFFB41214)),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ), 
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
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const GenderSelectionPage()),
                        );
                      },
                      child: Text(
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
                          "Doesn’t have an account?",
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
                        padding: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0),
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
                      onPressed: () async {
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
                            // If profile is complete
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomePage()),
                            );
                          } else {
                            // If profile is not complete
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const GenderSelectionPage()),
                            );
                          }
                        } else {
                          print("Sign-in failed or cancelled");
                        }
                      },
                      child: Row(
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
                              color: Colors.black54,
                            ),
                          ),
                          const TextSpan(
                            text: ". See how we use your data in our ",
                          ),
                          TextSpan(
                            text: "Privacy Policy",
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                            ),
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
                    decoration: InputDecoration(
                      labelText: "First Name",
                      floatingLabelStyle: TextStyle(color: Color(0xFFB41214)),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ), // bottom line color
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
                    decoration: InputDecoration(
                      labelText: "Last Name",
                      floatingLabelStyle: TextStyle(color: Color(0xFFB41214)),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
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
                    decoration: InputDecoration(
                      labelText: "Username",
                      floatingLabelStyle: TextStyle(color: Color(0xFFB41214)),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
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
                      onPressed: () {},
                      child: Text(
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
