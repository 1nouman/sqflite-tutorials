import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Person implements Comparable{

  final String firstName;
  final String lastName;
  final int id;

  Person({required this.firstName, required this.lastName, required this.id});
 Person.fromRow(Map<String , Object? > row):
       firstName = row['FIRST_NAME'] as String,
       lastName = row['LAST_NAME'] as String,
       id=row['ID'] as int;




  @override
  int compareTo(covariant  Person other) => other.id.compareTo(id);

  @override
  bool operator == (covariant Person other) => id== other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    // TODO: implement toString
    return  "firstName: $firstName LastName: $lastName  ID: $id";
  }
}

class PersonDB{
  final String dbName;
  Database? _database;
  PersonDB(this.dbName);

  List<Person> _persons=[];

  final _streamController = StreamController<List<Person>>.broadcast();
  Future<List<Person>>  _fetchData() async {

    final db = _database;
    try{
      if (db==null){
        return [];
      }

      final read =await db.query('PEOPLE', distinct: true, columns: ['ID', 'FIRSTNAME', 'LASTNAME'], orderBy: 'ID');
      final persons= read.map((row)=> Person.fromRow(row)).toList();
      return persons;

    }
    catch(e){
      print(e.toString());
      return [];

    }
    }


   Future<bool> open() async {

     final dir = await getApplicationDocumentsDirectory();
     final path = '${dir.path}/$dbName';

     try{
       if (_database!=null){
         return true;
       }
      final db = await  openDatabase(path);
       _database = db;


       const create='''CREATE TABLE PEOPLE IF NOT EXISTS PEOPLE (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        FIRSTNAME STRING NOT NULL,
        LASTNAME STRING NOT NULL
       )''';

       final execute = db.execute(create);
       // reads the data here

      final persons= await _fetchData();


      _persons =persons;

      _streamController.add(_persons);

       return true;

     }
     catch(e){
       print(e.toString());
       return false;

     }
   }




}


