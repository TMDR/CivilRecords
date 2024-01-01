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
