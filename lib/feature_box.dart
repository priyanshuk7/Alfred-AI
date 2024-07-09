import 'dart:ui';

import 'package:alfred_4/pallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FeatureBox extends StatelessWidget {
  final String headerText;
  final Color color;
  final String descriptionText;
  const FeatureBox({
    super.key,
    required this.color,
    required this.headerText,
    required this.descriptionText
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 35,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius:const BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(headerText,
                style: const TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.blackColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(descriptionText,
                style: const TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.blackColor,
                  fontSize: 14,

                ),
              ),
            ),        ],
        ),
      ),
    );
  }
}
