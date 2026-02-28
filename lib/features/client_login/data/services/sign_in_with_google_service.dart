import 'package:google_sign_in/google_sign_in.dart';

// Use a single instance for the entire app
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<GoogleSignInAccount?> handleGoogleSignIn() async {
  try {
    // Triggers the platform-specific account picker
    final GoogleSignInAccount? user = await googleSignIn.signIn();
    return user;
  } catch (e) {
    print('Error during Google Sign-In: $e');
    return null;
  }
}

Future<void> signOutGoogle() async {
  try {
    // signOut() logs out, disconnect() forces account selection next time
    await googleSignIn.signOut();
    await googleSignIn.disconnect();
  } catch (e) {
    print('Error during Google Sign-Out: $e');
  }
}