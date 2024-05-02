import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tophservices/models/user.dart';
import 'package:tophservices/screens/MapScreen.dart';
import 'package:tophservices/widgets/CustomButton.dart';

class CompleteInfoPage extends StatefulWidget {
  final UserModel user;

  CompleteInfoPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _CompleteInfoPageState createState() => _CompleteInfoPageState();
}

class _CompleteInfoPageState extends State<CompleteInfoPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with user's info
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneNumberController =
        TextEditingController(text: widget.user.phoneNumber);
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              // Add any necessary validation logic here
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              // Add any necessary validation logic here
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              // Add any necessary validation logic here
            ),
            const SizedBox(height: 32),
            CustomButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                      currentUser: widget.user,
                      onUpdateLocation: (updatedLocation) {
                        // Save user's information to Firestore
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.user.id)
                            .set(widget.user.toMap())
                            .then(
                          (value) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (route) => false,
                            );
                          },
                        ).catchError(
                          (error) {
                            print("Failed to save user's info: $error");
                            // Handle error
                          },
                        );
                      },
                      navigateToHomePage: false,
                    ),
                  ),
                );
              },
              text: 'Save',
            ),
          ],
        ),
      ),
    );
  }
}
