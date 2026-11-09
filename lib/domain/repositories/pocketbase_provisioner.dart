import 'package:pocketbase/pocketbase.dart';

/// One-time superuser setup: ensures the `marks` collection exists with open
/// rules (no end-user login). Admin credentials are not persisted.
class PocketBaseProvisioner {
  const PocketBaseProvisioner();

  static const marksCollection = 'marks';

  Future<void> ensureMarksCollection(
    PocketBase pb, {
    required String adminEmail,
    required String adminPassword,
  }) async {
    await pb.collection('_superusers').authWithPassword(
      adminEmail,
      adminPassword,
    );

    try {
      await pb.collections.getOne(marksCollection);
    } catch (_) {
      await pb.collections.create(
        body: {
          'name': marksCollection,
          'type': 'base',
          'fields': [
            {
              'name': 'sheet_date',
              'type': 'text',
              'required': true,
              'max': 10,
            },
            {
              'name': 'shift',
              'type': 'select',
              'required': true,
              'maxSelect': 1,
              'values': ['morning', 'evening', 'night'],
            },
            {
              'name': 'case_type',
              'type': 'select',
              'required': true,
              'maxSelect': 1,
              'values': [
                'medical',
                'surgical',
                'pediatrics',
                'minorOt',
                'rta',
                'dogBite',
                'mlc',
                'postmortem',
              ],
            },
            {'name': 'patient_name', 'type': 'text', 'required': false},
            {'name': 'age_years', 'type': 'text', 'required': false},
            {
              'name': 'sex',
              'type': 'select',
              'required': false,
              'maxSelect': 1,
              'values': ['male', 'female'],
            },
            {'name': 'remarks', 'type': 'text', 'required': false},
          ],
          'listRule': '',
          'viewRule': '',
          'createRule': '',
          'updateRule': '',
          'deleteRule': '',
        },
      );
    }

    pb.authStore.clear();
  }
}
