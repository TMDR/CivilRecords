// import 'dart:math';
// import 'package:faker/faker.dart';
// import 'package:civilrecord/utils/db.dart';
// import 'package:civilrecord/components/models.dart' as models;

// void main() async {
//   // Initialize Faker library
//   final faker = Faker();
//   Pdb db = Pdb();
//   await db.openConn();
//   // Function to generate random number of children between 1 and 4
//   int generateRandomChildrenCount() {
//     return Random().nextInt(3) + 2;
//   }

//   // Function to generate a random date of birth for the current generation
//   DateTime generateRandomBirthDate() {
//     int year = 50 +
//         Random().nextInt(40) +
//         1960; // Generate birth year between 1960 and 1999
//     int month = Random().nextInt(12) + 1;
//     int day = Random().nextInt(28) +
//         1; // Limit days to 28 to avoid date inconsistencies
//     return DateTime(year, month, day);
//   }

//   // List<dynamic> temp;
//   // List<List<dynamic>> listOfMen = await db.getMaleChildren();
//   // List<List<dynamic>> listOfWomen = await db.getFemaleChildren();
//   // for (List<dynamic> man in listOfMen) {
//   //   if (listOfWomen.isEmpty) break;
//   //   temp = listOfWomen[Random().nextInt(listOfWomen.length)];
//   //   while (man[1] == temp[1]) {
//   //     temp = listOfWomen[Random().nextInt(listOfWomen.length)];
//   //   }
//   //   await db.addMarriage([man[0], temp[0]]);
//   //   listOfWomen.remove(temp);
//   // }

//   int gen;
//   List<List<dynamic>> listofparents = await db.getMarriedIds();
//   for (List<dynamic> parent in listofparents) {
//     gen = generateRandomChildrenCount();
//     for (var i = 0; i < gen; i++) {
//       String firstName = faker.person.firstName();
//       String lastName = parent[1];
//       String placeOfBirth = faker.address.city();
//       DateTime dateOfBirth = generateRandomBirthDate();
//       int gender = Random().nextInt(2); // 0 for male

//       int? id = await db.signupuser(
//         firstName,
//         lastName,
//         '$firstName.$lastName@example.com', // Use a unique email for each person
//         'password',
//         placeOfBirth,
//         gender,
//         dateOfBirth.toIso8601String(),
//       );
//       await db.addChildRelation(parent[0] as int, id ?? 0);
//     }
//   }
//   print("finish");
//   // List<models.Person> men = [];
//   // List<models.Person> women = [];
//   // for (int i = 0; i < 5; i++) {
//   //   String firstName = faker.person.firstName();
//   //   String lastName = faker.person.lastName();
//   //   String placeOfBirth = faker.address.city();
//   //   DateTime dateOfBirth = generateRandomBirthDate();
//   //   DateTime dateOfDeath = faker.randomGenerator.boolean()
//   //       ? dateOfBirth.add(Duration(days: Random().nextInt(365 * 80)))
//   //       : DateTime.now();
//   //   int gender = 0; // 0 for male
//   //   models.Occupation occupation = models.Occupation(
//   //     organization: faker.company.name(),
//   //     trait: faker.randomGenerator.boolean() ? 'Manager' : 'Employee',
//   //   );

//   //   int? id = await db.signupuser(
//   //     firstName,
//   //     lastName,
//   //     '$firstName.$lastName@example.com', // Use a unique email for each person
//   //     'password',
//   //     placeOfBirth,
//   //     gender,
//   //     dateOfBirth.toIso8601String(),
//   //   );

//   //   men.add(models.Person(
//   //     id: id!,
//   //     firstName: firstName,
//   //     lastName: lastName,
//   //     placeOfBirth: placeOfBirth,
//   //     dateOfBirth: dateOfBirth.toIso8601String(),
//   //     dateOfDeath: dateOfDeath.isBefore(DateTime.now())
//   //         ? dateOfDeath.toIso8601String()
//   //         : "None",
//   //     gender: gender == 0,
//   //     occupation: occupation,
//   //     spouse: null,
//   //   ));
//   // }

//   // for (int i = 0; i < 5; i++) {
//   //   String firstName = faker.person.firstName();
//   //   String lastName = faker.person.lastName();
//   //   String placeOfBirth = faker.address.city();
//   //   DateTime dateOfBirth = generateRandomBirthDate();
//   //   DateTime dateOfDeath = faker.randomGenerator.boolean()
//   //       ? dateOfBirth.add(Duration(days: Random().nextInt(365 * 80)))
//   //       : DateTime.now();
//   //   int gender = 1; // 1 for female
//   //   models.Occupation occupation = models.Occupation(
//   //     organization: faker.company.name(),
//   //     trait: faker.randomGenerator.boolean() ? 'Manager' : 'Employee',
//   //   );

//   //   int? id = await db.signupuser(
//   //     firstName,
//   //     lastName,
//   //     '$firstName.$lastName@example.com', // Use a unique email for each person
//   //     'password',
//   //     placeOfBirth,
//   //     gender,
//   //     dateOfBirth.toIso8601String(),
//   //   );

//   //   women.add(models.Person(
//   //     id: id!,
//   //     firstName: firstName,
//   //     lastName: lastName,
//   //     placeOfBirth: placeOfBirth,
//   //     dateOfBirth: dateOfBirth.toIso8601String(),
//   //     dateOfDeath: dateOfDeath.isBefore(DateTime.now())
//   //         ? dateOfDeath.toIso8601String()
//   //         : "None",
//   //     gender: gender == 0,
//   //     occupation: occupation,
//   //     spouse: null,
//   //   ));
//   // }

//   // // Marry every man to every woman
//   // for (int i = 0; i < men.length; i++) {
//   //   for (int j = 0; j < women.length; j++) {
//   //     await db.addMarriage([men[i].id, women[j].id]);
//   //   }
//   // }
//   // print("finished");
// }
