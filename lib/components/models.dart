import 'package:flutter/material.dart';

class Person {
  final int id;
  final String firstName;
  final String lastName;
  final String placeOfBirth;
  final String dateOfBirth;
  final String? dateOfDeath;
  final bool gender;
  final Occupation? occupation;

  Person({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.placeOfBirth,
    required this.dateOfBirth,
    required this.dateOfDeath,
    required this.gender,
    required this.occupation,
  });
}

class Occupation {
  final String organization;
  final String trait;
  Occupation({required this.organization, required this.trait});
}

class UserPage {
  bool editMode = false;
  late List<TextEditingController> controllers;
  Person data;
  UserPage({required this.data}) {
    controllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController()
    ];
    controllers[0].text = data.firstName;
    controllers[1].text = data.lastName;
    controllers[2].text = data.gender ? "Male" : "Female";
    controllers[3].text = data.placeOfBirth;
    controllers[4].text = data.dateOfBirth;
    controllers[5].text = data.dateOfDeath ?? "None";
    controllers[6].text = data.occupation != null
        ? "${data.occupation?.organization} as ${data.occupation?.trait}"
        : "None";
  }
}
