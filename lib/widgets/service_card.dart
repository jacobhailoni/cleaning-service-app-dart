import 'package:flutter/material.dart';
import 'package:tophservices/models/service_model.dart';
import 'package:tophservices/models/user.dart';
import 'package:tophservices/screens/cph_booking_screen.dart';
import 'package:tophservices/screens/sofa_booking_screen.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final UserModel? currentuser;

  const ServiceCard({
    Key? key,
    required this.service,
    required this.currentuser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (service.name == 'Cleaning Per Hour') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CphBookingScreen(service: service, currentuser: currentuser),
            ),
          );
        } else if (service.name == 'Sofa Cleaning') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SofaBookingScreen(service: service, currentuser: currentuser),
            ),
          );
        } else
          null;
      },
      child: Card(
        elevation: 3,
        color: Colors.white,
        child: SizedBox(
          height: 100, // Square size
          child: Row(
            children: [
              Expanded(
                flex: 1, // 2/3 of the height
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromRGBO(3, 173, 246, 1), width: 1),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(service.image_url),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2, // 1/3 of the height
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Alegreya'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.description,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'Alegreya'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
