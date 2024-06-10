import 'package:flutter/material.dart';
import 'package:tophservices/models/service_model.dart';
import 'package:tophservices/models/user.dart';
import 'package:tophservices/widgets/service_card.dart';

class ServicesScreen extends StatelessWidget {
  final List<Service> services;
  final UserModel? user;

  const ServicesScreen({Key? key, required this.services, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns in a grid
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return ServiceCard(
          service: service,
          currentuser: user,
        );
      },
    );
  }
}
