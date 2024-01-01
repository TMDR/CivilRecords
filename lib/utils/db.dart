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
}
