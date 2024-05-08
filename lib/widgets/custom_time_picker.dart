import 'package:flutter/material.dart';

Future<TimeOfDay?> showCustomTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  required DateTime selectedDate,
}) async {
  TimeOfDay? result;

  final List<Widget> timeCards = [];
  List<Widget> currentRow = [];
  final today = DateTime.now();
  final startHour = 8;
  final startMinute = 30;

  for (int hour = startHour; hour < 24; hour++) {
    for (int minute = (hour == startHour ? startMinute : 0);
        minute < 60;
        minute += 30) {
      final time = TimeOfDay(hour: hour, minute: minute);
      bool isDisabled = false;

      if (today.day == selectedDate.day &&
          (hour < today.hour ||
              (hour == today.hour && minute < today.minute))) {
        isDisabled = true;
      }

      if (!isDisabled) {
        // Skip disabled times
        currentRow.add(
          Expanded(
            child: InkWell(
              onTap: () {
                result = time;
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color.fromRGBO(3, 173, 246, 1),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      if (currentRow.length == 2) {
        timeCards.add(Row(children: [...currentRow]));
        currentRow = [];
      }
    }
  }

  await showModalBottomSheet(
    context: context,
    builder: (BuildContext builder) {
      return Expanded(
        child: Column(
          children: [
            const SizedBox(
              height: 7,
            ),
            const Text(
              'Select Time',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView(
                children: timeCards,
              ),
            ),
          ],
        ),
      );
    },
  );

  return result;
}
