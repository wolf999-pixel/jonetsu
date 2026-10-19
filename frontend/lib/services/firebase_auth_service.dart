import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';

class FirebaseAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  FirebaseAuth get _firebaseAuth {
    if (Firebase.apps.isEmpty) {
      throw FirebaseException(
        plugin: 'firebase_auth',
        message: 'Firebase non initialisé',
      );
    }
    return FirebaseAuth.instance;
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to get user from Google sign-in');
      }

      // Get Firebase ID token
      final idToken = await user.getIdToken();

      // Exchange Firebase token for backend JWT
      final response = await ApiService.dio.post(
        '/auth/firebase',
        data: {'idToken': idToken},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['accessToken'] is String) {
        ApiService.setAuthToken(data['accessToken'] as String);
      }

      return data;
    } catch (e) {
      print('Google sign-in error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to get user');
      }

      final idToken = await user.getIdToken();
      final response = await ApiService.dio.post(
        '/auth/firebase',
        data: {'idToken': idToken},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['accessToken'] is String) {
        ApiService.setAuthToken(data['accessToken'] as String);
      }

      return data;
    } catch (e) {
      print('Email/password sign-in error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signUpWithEmailPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      await user.updateDisplayName(username);

      final idToken = await user.getIdToken();
      final response = await ApiService.dio.post(
        '/auth/firebase',
        data: {'idToken': idToken},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['accessToken'] is String) {
        ApiService.setAuthToken(data['accessToken'] as String);
      }

      return data;
    } catch (e) {
      print('Email/password sign-up error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signInWithCurrentFirebaseUser() async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('Aucun utilisateur Firebase connecté');
      }

      final idToken = await user.getIdToken(true);
      final response = await ApiService.dio.post(
        '/auth/firebase',
        data: {'idToken': idToken},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['accessToken'] is String) {
        ApiService.setAuthToken(data['accessToken'] as String);
      }
      return data;
    } catch (e) {
      print('Firebase session restore error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      ApiService.clearAuthToken();
    } catch (e) {
      print('Sign-out error: $e');
      rethrow;
    }
  }

  User? getCurrentUser() {
    if (Firebase.apps.isEmpty) {
      return null;
    }
    return FirebaseAuth.instance.currentUser;
  }

  Stream<User?> authStateChanges() {
    if (Firebase.apps.isEmpty) {
      return const Stream.empty();
    }
    return FirebaseAuth.instance.authStateChanges();
  }
}
