import 'package:flutter/material.dart';

class HourSelection extends StatefulWidget {
  final Function(double) onHourSelected;

  const HourSelection({Key? key, required this.onHourSelected})
      : super(key: key);

  @override
  _HourSelectionState createState() => _HourSelectionState();
}

class _HourSelectionState extends State<HourSelection> {
  double _selectedHour = 2.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80, // Set a fixed height to constrain the cross axis
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Scroll horizontally
        itemCount: 13,
        itemBuilder: (context, index) {
          double hour = 2.0 + index * 0.5;
          return InkWell(
            onTap: () {
              setState(() {
                _selectedHour = hour;
              });
              widget.onHourSelected(_selectedHour); // Notify parent
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _selectedHour == hour
                        ? const Color.fromRGBO(3, 173, 246, 1)
                        : Colors.white,
                    _selectedHour == hour
                        ? Color.fromRGBO(2, 134, 191, 1)
                        : Colors.white,
                  ],
                ),
                color: _selectedHour == hour
                    ? const Color.fromRGBO(3, 173, 246, 1)
                    : Colors.white,
                border: Border.all(color: Colors.black45),
                borderRadius: BorderRadius.circular(8.0),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 15, 10.0, 15),
                child: Center(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.watch_later_rounded,
                      color: _selectedHour == hour
                          ? Colors.white
                          : Color.fromRGBO(3, 173, 246, 1),
                    ),
                    Text(
                      '${hour.toString()[0]} hours ${hour.toString()[2] == '0' ? '' : 'and half'}',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color:
                            _selectedHour == hour ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                )),
              ),
            ),
          );
        },
      ),
    );
  }
}
