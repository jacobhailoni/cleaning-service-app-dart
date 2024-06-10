import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tophservices/models/user.dart';
import 'package:tophservices/screens/MapScreen.dart';
import 'package:tophservices/widgets/CustomButton.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

enum Provience {
  Dubai('Dubai', 'دبي'),
  AbuDhabi('AbuDhabi', 'ابوظبي'),
  Sharjah('Sharjah', 'الشارقة'),
  Ajman('Ajman', 'عجمان'),
  all('All', 'الكل');

  const Provience(this.name, this.ar);
  final String name;
  final String ar;
}

class CompleteInfoPage extends StatefulWidget {
  final bool firstTime;
  final String userId;

  CompleteInfoPage({
    Key? key,
    required this.firstTime,
    required this.userId,
  }) : super(key: key);

  @override
  _CompleteInfoPageState createState() => _CompleteInfoPageState();
}

class _CompleteInfoPageState extends State<CompleteInfoPage> {
  UserModel? _currentUser;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late Provience selectedProvience;

  @override
  void initState() async {
    super.initState();
     _loadUserData();
    // print('name: ${widget.user.name.length}');
// Initialize controllers with user's info
    _nameController = TextEditingController(text: _currentUser != null ? _currentUser!.name : '');
    _emailController = TextEditingController(text: widget.userId);
    _phoneNumberController = TextEditingController(text: widget.userId);
    selectedProvience = Provience.all;
  }
  void _loadUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget!.userId)
              .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userDataMap = userSnapshot.data()!;
        print(userDataMap.values);
        setState(() {
          _currentUser = UserModel.fromMap(userDataMap);
        });
      } else {
        print('User data not found in Firestore');
      }
    } catch (e) {
      print('Error loading user data from Firestore: $e');
    }
  }

  @override
  void dispose() {
    print('Name: ${_currentUser!.name}');
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
        title: Text(AppLocalizations.of(context)!.profileinfo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<Provience>(
              value: selectedProvience, // Provide the selected value
              onChanged: (Provience? newValue) {
                setState(() {
                  selectedProvience = newValue!; // Update selected province
                });
              },
              items: Provience.values.map((prov) {
                return DropdownMenuItem<Provience>(
                  value: prov,
                  child: Text(prov.name),
                );
              }).toList(),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.name),
              // Add any necessary validation logic here
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.email,
              ),
              // Add any necessary validation logic here
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.phone),
              // Add any necessary validation logic here
            ),
            const SizedBox(height: 32),
            CustomButton(
              onPressed: () {
                Map<String, dynamic> updateData = {
                  'name': _nameController.text,
                  'email': _emailController.text,
                  'phoneNumber': _phoneNumberController.text,
                  'userLocation.administrativeArea': selectedProvience!.name
                };
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userId)
                    .update(updateData)
                    .then((value) {
                  // Data has been successfully updated
                  print('User data has been successfully updated in Firestore');
                }).catchError((error) {
                  // Failed to update data
                  print('Failed to update user data in Firestore: $error');
                });

                if (widget.firstTime) {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => MapScreen(
                  //       currentUser: widget.user,
                  //       onUpdateLocation: (updatedLocation) {
                  //         // Save user's information to Firestore
                  //         FirebaseFirestore.instance
                  //             .collection('users')
                  //             .doc(widget.user.id)
                  //             .set(widget.user.toMap())
                  //             .then(
                  //           (value) {
                  //             Navigator.pushNamedAndRemoveUntil(
                  //               context,
                  //               '/home',
                  //               (route) => false,
                  //             );
                  //           },
                  //         ).catchError(
                  //           (error) {
                  //             print("Failed to save user's info: $error");
                  //             // Handle error
                  //           },
                  //         );
                  //       },
                  //       navigateToHomePage: false,
                  //     ),
                  //   ),
                  // );
                } else {
                  Navigator.pop(context);
                }
                ;
              },
              text: AppLocalizations.of(context)!.ok,
            ),
          ],
        ),
      ),
    );
  }
}
