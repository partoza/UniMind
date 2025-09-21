import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      // Start Google sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; 

      // Get auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // 🔑 Check if Firestore doc exists
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        final snapshot = await userDoc.get();
        if (!snapshot.exists) {
          // First time login creates blank profile
          await userDoc.set({
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName ?? '',
            'avatarPath': null,
            'profileComplete': false,
            'createdAt': FieldValue.serverTimestamp(), 
          });
        }
      }

      return user;
    } catch (e) {
      print("Google Sign-In error: $e");
      return null;
    }
  }
}
