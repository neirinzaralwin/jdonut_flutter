import 'package:drift/drift.dart';

/// Locally registered users (fake auth stores users on device — brief Task 1).
@DataClassName('UserRow')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get phone => text().unique()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text().nullable()();
  DateTimeColumn get dateOfBirth => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
