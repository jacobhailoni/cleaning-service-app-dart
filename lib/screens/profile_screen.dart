import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tophservices/main.dart';
import 'package:tophservices/models/user.dart';
import 'package:tophservices/screens/profileInfoScreen.dart';
import 'package:tophservices/widgets/CustomButton.dart';

class SettingItem {
  final String title;
  final IconData icon;
  final void Function(BuildContext) onTap;

  SettingItem(this.title, this.icon, this.onTap);
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<SettingItem> items = [
      SettingItem(
        AppLocalizations.of(context)!.accountSetting,
        Icons.person,
        (context) async {
          // Retrieve user data from Firestore
          DocumentSnapshot<Map<String, dynamic>> userDataSnapshot =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get();

          // Convert the Firestore data into a UserModel object
          UserModel userModel = UserModel.fromFirebaseCollection(
              UserModel.fromMap(userDataSnapshot.data() ?? {}));
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CompleteInfoPage(
                      user: userModel,
                      firstTime: false,
                    )),
          );
        },
      ),
      SettingItem(AppLocalizations.of(context)!.language, Icons.language,
          showLanguageChangeDialog),
      SettingItem(AppLocalizations.of(context)!.terms, Icons.file_copy_outlined,
          showterms),
      SettingItem(AppLocalizations.of(context)!.privacyPolicy, Icons.lock,
          _emptyFunction),
      // SettingItem(AppLocalizations.of(context)!.faq,
      //     Icons.question_answer_outlined, _emptyFunction),
      SettingItem(AppLocalizations.of(context)!.help, Icons.help_center,
          _emptyFunction),
      SettingItem(AppLocalizations.of(context)!.logout, Icons.logout_outlined,
          _signOut),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.accountSetting,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          leading: Container(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Icon(
                              item.icon,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(
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

  void showterms(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.terms,
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(
            child: Text(
              AppLocalizations.of(context)!.privacy_policy,
            ),
          ),
        ),
        actions: <Widget>[
          CustomButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: AppLocalizations.of(context)!.ok,
          ),
        ],
      );
    },
  );
}

  void showLanguageChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.language),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.english,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const Text(
                        '🇺🇸',
                        style: TextStyle(fontSize: 22),
                      )
                    ],
                  ),
                  onTap: () {
                    changeLocale(
                      context,
                      const Locale('en'),
                    );
                    Navigator.of(context).pop();
                  },
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(AppLocalizations.of(context)!.arabic,
                          style: const TextStyle(fontSize: 22)),
                      const Text(
                        '🇦🇪',
                        style: TextStyle(fontSize: 22),
                      )
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    changeLocale(context, const Locale('ar'));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void changeLocale(BuildContext context, Locale newLocale) {
  MyApp.setLocale(context, newLocale);
}
