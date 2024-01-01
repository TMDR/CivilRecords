import 'package:civilrecord/components/models.dart';
import 'package:postgres/postgres.dart';

class Pdb {
  Pdb();
  late Connection conn;
  String hostname = "mel.db.elephantsql.com";
  String usr = "kjgnqpzi";
  String pass = "D3vIT5ya-hQxwxvqpjqk0srPGyip5pm3";

  Future<bool> openConn() async {
    try {
      conn = await Connection.open(Endpoint(
          host: hostname, database: usr, username: usr, password: pass));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Result?> execute(String query) async {
    try {
      var res = await conn.execute(query);
      return res;
    } catch (e) {
      return null;
    }
  }

  Future<bool?> checkCredentials(String username, String password) async {
    //unique email, thus it suffices to try to find a row where username and password match
    Result? res = await execute(
        "SELECT * FROM login WHERE email = '$username' AND password = '$password'");
    if (res!.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future<int?> singupuser(
      String firstname,
      String lastname,
      String username,
      String password,
      String placeOfBirth,
      int gender,
      String dateOfBirth) async {
    //check if email already in use
    Result? res =
        await execute("SELECT * FROM login WHERE email = '$username'");
    if (res!.isEmpty) {
      Result? res = await execute(
          "INSERT into person(first_name, last_name, place_of_birth, date_of_birth, date_of_death, occupation, gender) VALUES ('$firstname', '$lastname', '$placeOfBirth', '$dateOfBirth'::date, NULL, NULL, ${(gender == 0 ? false : true).toString()}) RETURNING id;");
      if (res!.affectedRows == 1) {
        String? id = res[0][0].toString();
        await execute(
            "INSERT INTO login(email, password, id) VALUES ('$username','$password',$id)");
        return 0;
      } else {
        return 1;
      }
    } else {
      return -1;
    }
  }

  Future<List<Person>> fetchPeople(
      String firstName,
      String lastName,
      String fromDateOfBirth,
      String toDateOfBirth,
      String fromDateOfDeath,
      String toDateOfDeath) async {
    String select = """SELECT 
	                            person.id,person.first_name,person.last_name,person.place_of_birth,person.date_of_birth,person.date_of_death,person.gender,
	                            organization.name as Organization,
	                            traits.trait_val

                      FROM PERSON FULL OUTER JOIN worker ON worker.personid = person.id
			                            FULL OUTER JOIN traits ON worker.trait = traits.traitid 
			                            FULL OUTER JOIN organization ON worker.orgid = organization.id  
                      WHERE """;
    int length = select.length;
    select =
        firstName == "" ? select : ("${select}first_name='$firstName' AND ");
    select = lastName == "" ? select : ("${select}last_name='$lastName' AND ");
    select = fromDateOfBirth == ""
        ? select
        : ("${select}date_of_birth>='$fromDateOfBirth' AND ");
    select = toDateOfBirth == ""
        ? select
        : ("${select}date_of_birth<='$toDateOfBirth' AND ");
    select = fromDateOfDeath == ""
        ? select
        : ("${select}date_of_death>='$fromDateOfDeath' AND ");
    select = toDateOfDeath == ""
        ? select
        : ("${select}date_of_death<='$toDateOfBirth' AND ");
    if (select.length > length) {
      select = select.substring(0, select.length - 5);
    } else {
      select = "";
    }
    Result? resp = select == "" ? null : await execute(select);
    List<Person> foundpeople = [];
    var row = resp?.iterator;
    while (row?.moveNext() ?? false) {
      foundpeople.add(
        Person(
          id: row?.current[0] as int,
          firstName: row?.current[1] as String,
          lastName: row?.current[2] as String,
          placeOfBirth: row?.current[3] as String,
          dateOfBirth: (row?.current[4] as DateTime).toString().split(" ")[0],
          dateOfDeath: row?.current[5] as String?,
          gender: !(row?.current[6] as bool),
          occupation: row?.current[7] != null
              ? Occupation(
                  organization: row?.current[7] as String,
                  trait: row?.current[8] as String)
              : null,
        ),
      );
    }
    return foundpeople;
  }
}
