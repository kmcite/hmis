import 'package:shared_database/shared_database.dart';

/// App preferences persisted as a single JSON document in the shared
/// database (`hmis_config` collection, `settings` record).
class AppSettingsStore {
  AppSettingsStore(this._db);

  final SharedDatabase _db;

  static const collectionName = 'hmis_config';
  static const recordId = 'settings';

  Future<bool> readDark() async {
    await _db.ensure(collectionName);
    final record = await _db.get(collectionName, recordId);
    return record?.data['dark'] == true;
  }

  Future<void> writeDark(bool value) async {
    await _db.ensure(collectionName);
    await _db.put(
      collectionName,
      {'dark': value},
      id: recordId,
    );
  }
}
