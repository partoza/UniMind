import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimind/views/temspolicy.dart';

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
          // Background Image
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Use constraints to make sizes relative to the available space
                double logoSize =
                    constraints.maxWidth * 0.30; // 25% of screen width
                double topPadding =
                    constraints.maxHeight * 0.08; // 6% of screen height
                double textSpacing = constraints.maxHeight * 0.015;
                double fontSize =
                    constraints.maxWidth * 0.060; // responsive text

                return Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/Logo.png",
                        width: logoSize,
                        height: logoSize,
                      ),
                      SizedBox(height: textSpacing),
                      Text(
                        "Study ta GA!",
                        style: GoogleFonts.montserrat(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Login Container
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: showLogin ? 0 : -size.height,
            child: SingleChildScrollView(
              child: Container(
                width: size.width,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.02,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(size.width * 0.08),
                    topRight: Radius.circular(size.width * 0.08),
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 10),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Login",
                      style: GoogleFonts.montserrat(
                        fontSize: size.width * 0.08,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB41214),
                      ),
                    ),
                    Text(
                      "Login with your existing credentials.",
                      style: GoogleFonts.montserrat(
                        fontSize: size.width * 0.035,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    _buildTextField("Username"),
                    SizedBox(height: size.height * 0.02),
                    _buildPasswordField("Password"),
                    SizedBox(height: size.height * 0.01),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.montserrat(
                          fontSize: size.width * 0.03,
                          color: const Color(0xFFB41214),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.015),
                    FractionallySizedBox(
                      widthFactor: 1,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB41214),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.015,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TermsScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Login Now",
                          style: GoogleFonts.montserrat(
                            fontSize: size.width * 0.04,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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
                              fontSize: size.width * 0.03,
                              color: Colors.black54,
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() => showLogin = false),
                            child: Text(
                              "Register Here",
                              style: GoogleFonts.montserrat(
                                fontSize: size.width * 0.03,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFB41214),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    _buildDividerWithText(size, "or Login with"),
                    SizedBox(height: size.height * 0.02),
                    _buildGoogleButton(size),
                    SizedBox(height: size.height * 0.02),
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.montserrat(
                            fontSize: size.width * 0.025,
                            color: Colors.black54,
                          ),
                          children: const [
                            TextSpan(text: "By signing up, you agree to our "),
                            TextSpan(
                              text: "Terms",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: ". See how we use your data in our ",
                            ),
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: "."),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
            child: SingleChildScrollView(
              child: Container(
                width: size.width,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.02,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(size.width * 0.08),
                    topRight: Radius.circular(size.width * 0.08),
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 10),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Register",
                      style: GoogleFonts.montserrat(
                        fontSize: size.width * 0.08,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB41214),
                      ),
                    ),
                    Text(
                      "Please fill in all fields to register.",
                      style: GoogleFonts.montserrat(
                        fontSize: size.width * 0.035,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: size.height * 0.007),
                    _buildTextField("First Name"),
                    SizedBox(height: size.height * 0.007),
                    _buildTextField("Last Name"),
                    SizedBox(height: size.height * 0.007),
                    _buildTextField("Username"),
                    SizedBox(height: size.height * 0.007),
                    _buildPasswordField("Password"),
                    SizedBox(height: size.height * 0.007),
                    _buildPasswordField("Confirm Password"),
                    SizedBox(height: size.height * 0.02),
                    FractionallySizedBox(
                      widthFactor: 1,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB41214),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.015 ,
                          ),
                        ),
                        onPressed: () {},
                        child: Text(
                          "Register Now",
                          style: GoogleFonts.montserrat(
                            fontSize: size.width * 0.04,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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
                              fontSize: size.width * 0.03,
                              color: Colors.black54,
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() => showLogin = true),
                            child: Text(
                              "Back to Login",
                              style: GoogleFonts.montserrat(
                                fontSize: size.width * 0.03,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFB41214),
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
          ),
        ],
      ),
    );
  }

  // Reusable TextField
  Widget _buildTextField(String label) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        floatingLabelStyle: const TextStyle(color: Color(0xFFB41214)),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB41214), width: 2),
        ),
      ),
    );
  }

  // Reusable Password Field
  Widget _buildPasswordField(String label) {
    return TextField(
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelStyle: const TextStyle(color: Color(0xFFB41214)),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB41214), width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.black54,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }

  // Divider with text
  Widget _buildDividerWithText(Size size, String text) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.black26, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: size.width * 0.03,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.black26, thickness: 1)),
      ],
    );
  }

  // Google Button
  Widget _buildGoogleButton(Size size) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
        ),
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/google icon.png",
              height: size.width * 0.05,
              width: size.width * 0.05,
            ),
            SizedBox(width: size.width * 0.03),
            Text(
              "Continue with Google",
              style: GoogleFonts.montserrat(
                fontSize: size.width * 0.035,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
