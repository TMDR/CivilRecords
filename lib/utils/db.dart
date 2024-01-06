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

  Future<bool?> updateUser(
      int id,
      String firstname,
      String lastname,
      String gender,
      String placeOfBirth,
      String dateOfBirth,
      String dateOfDeath) async {
    if (id == 0 ||
        [firstname, lastname, gender, placeOfBirth, dateOfBirth, dateOfDeath]
            .contains("")) {
      return false;
    }
    String query =
        "update Person SET first_name='$firstname',last_name='$lastname',gender=${gender == "Female" ? 'True' : 'False'},place_of_birth='$placeOfBirth',date_of_birth='$dateOfBirth'::date,date_of_death=${dateOfDeath == "None" ? "NULL" : "'$dateOfDeath'::date"}  WHERE id=$id";
    Result? res = await execute(query);
    if (res == null) {
      return false;
    } else if (res.affectedRows == 1) {
      return true;
    } else {
      return false;
    }
  }

  Future<Map<Person, String>?> getRelated(int id) async {
    String query = """ 

    SELECT person.id,person.first_name,person.last_name,place_of_birth,date_of_birth,date_of_death,gender,
organization.name as Organization,
	                            traits.trait_val, case when person.id = person2_id OR relation_types.name = 'spouse' then relation_types.name else 'parent' end as relation_name FROM PERSON 
INNER JOIN relation ON 
(relation.person1_id=person.id AND relation.person2_id=$id)
OR 
(relation.person2_id=person.id AND relation.person1_id=$id)
INNER JOIN relation_types ON relation_type = type_id
left OUTER JOIN worker ON worker.personid = person.id
left OUTER JOIN traits ON worker.trait = traits.traitid 
left OUTER JOIN organization ON worker.orgid = organization.id
    
    """;
    Result? resp = await execute(query);
    if (resp == null) {
      return null;
    }
    Map<Person, String> foundpeople = {};
    var row = resp.iterator;
    while (row.moveNext()) {
      foundpeople.addEntries(
        [
          MapEntry(
              Person(
                id: row.current[0] as int,
                firstName: row.current[1] as String,
                lastName: row.current[2] as String,
                placeOfBirth: row.current[3] as String,
                dateOfBirth:
                    (row.current[4] as DateTime).toString().split(" ")[0],
                dateOfDeath: (row.current[5] as DateTime? ?? "None")
                    .toString()
                    .split(" ")[0],
                gender: !(row.current[6] as bool),
                occupation: row.current[7] != null
                    ? Occupation(
                        organization: row.current[7] as String,
                        trait: row.current[8] as String)
                    : null,
              ),
              row.current[9] as String)
        ],
      );
    }
    return foundpeople;
  }

  Future<int?> checkCredentials(String username, String password) async {
    //unique email, thus it suffices to try to find a row where username and password match
    Result? res = await execute(
        "SELECT id FROM login WHERE email = '$username' AND password = '$password'");
    if (res?.isEmpty ?? true) {
      return 0;
    } else {
      var it = res?.iterator;
      it?.moveNext();
      return it?.current[0] as int;
    }
  }

  Future<Person?> getUserById(int id) async {
    String query = "SELECT * FROM person WHERE id=$id";
    Result? res = await execute(query);
    if (res == null || res.isEmpty) {
      return null;
    } else {
      return Person(
        id: res[0][0] as int,
        firstName: res[0][1] as String,
        lastName: res[0][2] as String,
        placeOfBirth: res[0][3] as String,
        dateOfBirth: (res[0][4] as DateTime).toString().split(" ")[0],
        dateOfDeath: null,
        gender: !(res[0][6] as bool),
        occupation: null,
      );
    }
  }

  Future<bool?> addMarriage(List<int> ids) async {
    //check if it already exists
    Result? res = await execute(
        "SELECT * FROM relations WHERE person1_id = ${ids[0]}} OR person2_id = ${ids[1]}");
    if (res?.isEmpty ?? false) {
      res = await execute(
          "INSERT INTO relations(person1_id, person2_id, relation_type) VALUES(${ids[0]}, ${ids[1]}, 1)");
      if (res?.affectedRows == 1) {
        return true;
      }
    }
    return false;
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

                      FROM PERSON LEFT JOIN worker ON worker.personid = person.id
			                            LEFT JOIN traits ON worker.trait = traits.traitid 
			                            LEFT JOIN organization ON worker.orgid = organization.id  
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
          dateOfDeath:
              (row?.current[5] as DateTime? ?? "None").toString().split(" ")[0],
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

  Future<List<OccupationData>> listAllOccupations() async {
    String query = """
        SELECT organization.id, organization.name, traits.traitid, traits.trait_val, CONCAT_WS(' ', person.first_name, person.last_name) AS owner_name
        FROM traits LEFT OUTER JOIN organization ON traits.orgid = organization.id
			              LEFT OUTER JOIN person ON organization.owner = person.id ORDER BY organization.id
 """;
    Result? res = await execute(query);
    var row = res?.iterator;
    List<OccupationData> list = [];
    while (row?.moveNext() ?? false) {
      var checked = false;
      for (final (index, item) in list.indexed) {
        if (item.id == row?.current[0]) {
          list[index].traits.add(Trait(
              id: row?.current[2] as int, value: row?.current[3] as String));
          checked = true;
          break;
        }
      }
      if (!checked) {
        list.add(OccupationData(
            id: row?.current[0] as int,
            title: row?.current[1] as String,
            traits: [
              Trait(
                  id: row?.current[2] as int, value: row?.current[3] as String)
            ],
            owner: row?.current[4] as String));
      }
    }
    return list;
  }

  Future<bool?> setOccupation(
      bool occupationExists, int orgid, int traitid, int personid) async {
    String query = !occupationExists
        ? "INSERT INTO worker(orgid, trait, personid) VALUES($orgid, $traitid, $personid)"
        : "UPDATE worker SET orgid = $orgid, trait = $traitid WHERE personid = $personid";
    Result? res = await execute(query);
    if (res == null) {
      return false;
    }
    return true;
  }
}
