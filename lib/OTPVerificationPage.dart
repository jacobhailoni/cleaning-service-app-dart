import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:tophservices/models/user.dart';
import 'package:tophservices/screens/admin/admin_screen.dart';
import 'package:tophservices/screens/loginPage.dart';
import 'package:tophservices/screens/profileInfoScreen.dart';
import 'package:tophservices/widgets/CustomButton.dart';

class OTPVerificationPage extends StatefulWidget {
  final String verificationId;
  final int? resendToken;
  final String phoneNumber;

  const OTPVerificationPage({
    Key? key,
    required this.verificationId,
    this.resendToken,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController otpController = TextEditingController();
  bool _isResendEnabled = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 30), () {
      setState(() {
        _isResendEnabled = true;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Verifying OTP...'),
            ],
          ),
        );
      },
    );

    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otpController.text.trim(),
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      Navigator.pop(context);
      if (await checkAdmin(userCredential.user!.uid)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteInfoPage(
              userId: UserModel.fromFirebaseUser(userCredential.user!).id,
              firstTime: true,
            ),
          ),
        );
      }
    } catch (e) {
      print("Error verifying OTP: $e");
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Verification Failed'),
            content: const Text('Failed to verify OTP. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LoginPage(
                        context: context,
                      ),
                    ),
                  );
                },
                child: const Text('Try Again'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _resendOTP(BuildContext context) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+971${widget.phoneNumber}',
        timeout: const Duration(seconds: 30),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          Navigator.pushReplacementNamed(context, '/home');
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid phone number')),
            );
          } else {
            print('Error: ${e.message}');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationPage(
                verificationId: verificationId,
                resendToken: resendToken,
                phoneNumber: widget.phoneNumber,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      print("Error resending OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to resend OTP. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: Colors.green,
                size: 250,
              ),
              const Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0),
              Pinput(
                showCursor: true,
                defaultPinTheme: PinTheme(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(3, 173, 246, 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                controller: otpController,
                length: 6,
                onCompleted: (pin) {
                  _verifyOTP(context);
                },
              ),
              const SizedBox(height: 20.0),
              CustomButton(
                onPressed: () {
                  _verifyOTP(context);
                },
                text: 'Verify OTP',
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed:
                        _isResendEnabled ? () => _resendOTP(context) : null,
                    child: Text(
                      'Didn\'t receive code? Resend',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _isResendEnabled
                            ? const Color.fromRGBO(3, 173, 246, 1)
                            : Colors.black26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Countdown(
                    seconds: 30,
                    build: (_, double time) => Text(
                      time.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    onFinished: () {
                      setState(() {
                        _isResendEnabled = true;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> checkAdmin(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(id).get();

      if (userSnapshot.exists) {
        // Check if the user is an admin based on the value of 'isAdmin' field
        bool isAdmin = userSnapshot.data()?['isAdmin'] ?? false;
        return isAdmin;
      } else {
        // If the document doesn't exist, user is not an admin
        return false;
      }
    } catch (e) {
      // Handle any potential errors
      print("Error checking admin status: $e");
      return false;
    }
  }
}
