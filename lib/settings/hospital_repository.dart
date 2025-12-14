import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class Hospital {
  final String name;
  final String city;
  final String info;
  const Hospital({
    this.name = '',
    this.city = '',
    this.info = '',
  });

  static fromJson(String? string) {
    if (string == null || string.isEmpty) {
      return const Hospital();
    }
    final Map<String, dynamic> json = jsonDecode(string);
    return Hospital(
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      info: json['info'] ?? '',
    );
  }

  String toJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'city': city,
      'info': info,
    };
    return jsonEncode(json);
  }

  Hospital copyWith({
    String? name,
    String? city,
    String? info,
  }) {
    return Hospital(
      name: name ?? this.name,
      city: city ?? this.city,
      info: info ?? this.info,
    );
  }
}

String get _hospitalKey => 'hospital';

class HospitalRepository {
  SharedPreferences preferences;
  HospitalRepository(this.preferences);
  Hospital get hospital {
    return Hospital.fromJson(preferences.getString(_hospitalKey)) ?? Hospital();
  }

  void setHospital(Hospital hospital) {
    preferences.setString(
      _hospitalKey,
      hospital.toJson(),
    );
  }
}

class HospitalBloc extends ChangeNotifier {
  HospitalRepository get hospitalRepository => throw '';

  final BuildContext context;
  HospitalBloc(this.context);

  Hospital get hospital => hospitalRepository.hospital;

  void setHospital(Hospital value) {
    hospitalRepository.setHospital(value);
    notifyListeners();
  }

  /// NAME
  String get name => hospital.name;
  void setName(String? name) {
    setHospital(
      hospital.copyWith(name: name),
    );
  }

  /// INFORMATIONS
  String get info => hospital.info;

  void setInfo(String? info) {
    setHospital(
      hospital.copyWith(info: info),
    );
  }

  /// CITY

  String get city => hospital.city;

  void setCity(String? city) {
    setHospital(
      hospital.copyWith(city: city),
    );
  }
}
