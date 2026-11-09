import 'package:hmis/domain/models/models.dart';
import 'package:hmis/objectbox.g.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class HmisLocalStore {
  HmisLocalStore(this._store);

  final Store _store;

  late final Box<MarkEntity> marks = _store.box<MarkEntity>();
  late final Box<OutboxEntry> outbox = _store.box<OutboxEntry>();
  late final Box<SyncMetaEntity> meta = _store.box<SyncMetaEntity>();

  static Future<HmisLocalStore> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final store = await openStore(
      directory: p.join(dir.path, 'hmis-objectbox'),
    );
    return HmisLocalStore(store);
  }

  String? getMeta(String key) =>
      meta.query(SyncMetaEntity_.key.equals(key)).build().findFirst()?.value;

  void setMeta(String key, String value) {
    meta.put(SyncMetaEntity(key: key, value: value));
  }

  void close() => _store.close();
}
