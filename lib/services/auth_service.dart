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

      // Sign in with Firebase using _auth instance
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

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  } on FirebaseAuthException catch (e) {
    print('[AuthService] FirebaseAuthException: code=${e.code}, message=${e.message}');
    rethrow; // preserve original exception type
  } catch (e, st) {
    print('[AuthService] Unknown sign-in error: ${e.runtimeType} -> $e\n$st');
    rethrow; // keep the original error (don't wrap into Exception(...))
  }
}

  Future<User?> registerWithEmailAndPassword(
  String email, 
  String password, 
  String firstName, 
  String lastName,
) async {
  try {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    User? user = result.user;
    
    if (user != null) {
      String displayName = '$firstName $lastName';
      
      // Update displayName in Firebase Auth
      await user.updateDisplayName(displayName);
      
      // Create user document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'displayName': displayName,
        'firstName': firstName,
        'lastName': lastName,
        'avatarPath': 'assets/cce_male.jpg',
        'createdAt': FieldValue.serverTimestamp(),
        'yearLevel': 1,
        'department': 'Not set',
        'program': 'Not set',
        'gender': 'Not set',
        'place': 'PS Building',
        'bio': 'No bio yet. You can add one by editing your profile.',
        'strengths': [],
        'weaknesses': [],
        'followerCount': 0,
        'followingCount': 0,
        'profileComplete': false,
      });
    }
    
    return user;
  } on FirebaseAuthException catch (e) {
    print("FirebaseAuthException in registerWithEmailAndPassword: ${e.code} - ${e.message}");
    rethrow;
  } catch (e) {
    print("Unexpected error in registerWithEmailAndPassword: $e");
    throw FirebaseAuthException(
      code: 'unknown-error',
      message: 'An unexpected error occurred during registration',
    );
  }
}
}