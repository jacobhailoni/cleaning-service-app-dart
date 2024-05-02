library item_count_number_button;

import 'package:flutter/material.dart';

typedef CounterChangeCallback = void Function(num value);

// ignore: must_be_immutable
class ItemCount extends StatelessWidget {
  final CounterChangeCallback onChanged;

  ItemCount({
    super.key,
    required num initialValue,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    required this.decimalPlaces,
    this.color,
    this.textStyle,
    this.step = 1,
    this.buttonSizeWidth = 30,
    this.buttonSizeHeight = 25,
  })  : assert(maxValue > minValue),
        assert(initialValue >= minValue && initialValue <= maxValue),
        assert(step > 0),
        selectedValue = initialValue;

  ///min value user can pick
  final num minValue;

  ///max value user can pick
  final num maxValue;

  /// decimal places required by the counter
  final int decimalPlaces;

  ///Currently selected integer value
  num selectedValue;

  /// if min=0, max=5, step=3, then items will be 0 and 3.
  final num step;

  /// indicates the color of fab used for increment and decrement
  Color? color;

  /// text syle
  TextStyle? textStyle;

  final double buttonSizeWidth, buttonSizeHeight;

  void _incrementCounter() {
    if (selectedValue + step <= maxValue) {
      onChanged((selectedValue + step));
    }
  }

  void _decrementCounter() {
    if (selectedValue - step >= minValue) {
      onChanged((selectedValue - step));
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _decrementCounter,
                child: const Icon(
                  size: 40,
                  Icons.remove_circle,
                  color: Color.fromARGB(255, 2, 80, 144),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                    '${num.parse((selectedValue).toStringAsFixed(decimalPlaces))}',
                    style: textStyle == null
                        ? textStyle
                        : const TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          )),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: _incrementCounter,
                child: const Icon(
                  size: 40,
                  Icons.add_circle_outlined,
                  color: Color.fromARGB(255, 2, 80, 144),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
