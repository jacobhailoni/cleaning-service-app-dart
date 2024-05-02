import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingItem {
  String title;
  IconData icon;
  void Function(BuildContext) onTap;

  SettingItem(this.title, this.icon, this.onTap);
}

void _signOut(BuildContext context) {
  try {
    FirebaseAuth.instance.signOut();
    // Navigate back to the login page
    Navigator.pushReplacementNamed(context, '/login');
  } catch (e) {
    print("Error signing out: $e");
    // Handle sign-out error (e.g., show error message)
  }
}

void _emptyFunction(BuildContext context) {
  // Empty function, does nothing
}

List<SettingItem> items = [
  SettingItem('Account Settings', Icons.person, _emptyFunction),
  SettingItem('Change Language', Icons.language, _emptyFunction),
  SettingItem('Terms & Condition', Icons.file_copy_outlined, _emptyFunction),
  SettingItem('Privacy Policy', Icons.lock, _emptyFunction),
  SettingItem('FAQ', Icons.question_answer_outlined, _emptyFunction),
  SettingItem('Get Help', Icons.help_center, _emptyFunction),
  // Changed the title of the last item to "Log Out" instead of "Sign Out"
  SettingItem('Log Out', Icons.logout_outlined, _signOut),
];

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile And Settings',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Column(
            children: items
                .map(
                  (item) => Card(
                    elevation: 8.0,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0),
                    child: InkWell(
                      onTap: () => item.onTap(context),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Color.fromRGBO(3, 173, 246, 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          leading: Container(
                            padding: EdgeInsets.only(right: 12.0),
                            child: Icon(
                              item.icon,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
