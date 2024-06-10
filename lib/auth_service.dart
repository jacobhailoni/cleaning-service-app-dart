import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences package
import 'package:tophservices/models/booking_location_model.dart';
import 'package:tophservices/models/user.dart';
import 'package:tophservices/screens/home.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final BuildContext context;
  User? get currentUser => _auth.currentUser;

  AuthService(this.context);

  Future<UserModel> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.token);
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final UserModel userModel = _convertUserToUserModel(userCredential.user!);
      _saveUserId(userModel.id);
      return userModel;
    } catch (e) {
      print("Error signing in with Facebook: $e");
      throw e;
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount!.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final UserModel userModel = _convertUserToUserModel(userCredential.user!);
      _saveUserId(userModel.id);
      return userModel;
    } catch (e) {
      print("Error signing in with Google: $e");
      throw e;
    }
  }

  UserModel _convertUserToUserModel(User user) {
    // Extract user information and create a UserModel object
    return UserModel(
      id: user.uid,
      name: user.displayName != null ? user.displayName as String : '',
      email: user.email != null ? user.email as String : '',
      phoneNumber: '',
      // You may need to adjust this based on your application's requirements
      userLocation: BookingLocation(
        location: '',
        buildingNumber: '',
        apartmentNumber: '',
        administrativeArea: '',
      ),
    );
  }

  Future<void> _saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<String?> _getSavedUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  void _navigateToHomePage(String userId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(userId: userId), // Pass user ID
      ),
    );
  }
}
