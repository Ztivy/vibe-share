import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthGoogle {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get usuarioActual => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: '173763559487-ta681nuges1bgo0q2f6jq70086jrur9m.apps.googleusercontent.com',
      );

      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final clientAuth = await googleUser.authorizationClient
          .authorizeScopes(['email', 'profile']);

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: clientAuth.accessToken,
      );

      final UserCredential result =
          await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      // ignore: avoid_print
      print('Error Google Sign-In: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}