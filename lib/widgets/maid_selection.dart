import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class MaidSelection extends StatefulWidget {
  final Function(double) onMaidSelected;

  const MaidSelection({Key? key, required this.onMaidSelected})
      : super(key: key);

  @override
  _MaidSelectionState createState() => _MaidSelectionState();
}

class _MaidSelectionState extends State<MaidSelection> {
  int _selectedMaidIndex = -1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80, // Set a fixed height to constrain the cross axis
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Scroll horizontally
        itemCount: 8,
        itemBuilder: (context, index) {
          double maidCount = index + 1;
          return InkWell(
            onTap: () {
              setState(() {
                _selectedMaidIndex = index;
                widget.onMaidSelected(_selectedMaidIndex.toDouble());
              });
              // Handle maid count selection
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _selectedMaidIndex == index
                        ? const Color.fromRGBO(3, 173, 246, 1)
                        : Colors.white,
                    _selectedMaidIndex == index
                        ? const Color.fromRGBO(3, 173, 246, 1)
                        : Colors.white,
                  ],
                ),
                color: _selectedMaidIndex == index
                    ? const Color.fromRGBO(3, 173, 246, 1)
                    : Colors.white,
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(8.0),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 12, 20.0, 12),
                child: Column(children: [
                  Icon(
                    Icons.person_2_sharp,
                    color: _selectedMaidIndex == index
                        ? Colors.white
                        : const Color.fromRGBO(3, 173, 246, 1),
                  ),
                  Text(
                    '${maidCount.toInt()}  ${AppLocalizations.of(context)!.maid}',
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: _selectedMaidIndex == index
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}
