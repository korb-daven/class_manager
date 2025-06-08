import 'dart:async';
import 'package:sembast/sembast_io.dart'; // For mobile/desktop
import 'package:sembast_web/sembast_web.dart'; 
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:class_manager/models/student.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DBHelper {
   late Database _db;
  final _store = intMapStoreFactory.store('students');

  Future<void> init() async {
    if (kIsWeb) {
      // Web: use sembast_web database factory
      _db = await databaseFactoryWeb.openDatabase('students.db'); // ✅ This works now
    } else {
      // Mobile/Desktop: use sembast_io database factory
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = join(dir.path, 'students.db');
      _db = await databaseFactoryIo.openDatabase(dbPath);
    }
  }

  Future<int> insertStudent(Student student) async {
    return await _store.add(_db, student.toMap());
  }

  Future<List<Student>> getStudents() async {
    final records = await _store.find(_db);
    return records.map((snap) {
      final data = Map<String, dynamic>.from(snap.value);
      data['id'] = snap.key;
      return Student.fromMap(data);
    }).toList();
  }

  Future<void> updateStudent(Student student) async {
    await _store.record(student.id!).put(_db, student.toMap());
  }

  Future<void> deleteStudent(int id) async {
    await _store.record(id).delete(_db);
  }
}
