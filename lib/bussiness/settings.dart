import 'package:hmis/bussiness/business.dart';
import 'package:hmis/domain/services.dart';
import 'package:hmis/utils/redux.dart';
import 'package:redux/redux.dart';

class Settings {
  String userName = '';
  bool dark = false;
  String hospitalName = '';
  String city = '';
  String info = '';
  DateTime date = DateTime.now();
  int count = 0;
  bool get anyFailure => failureReason != null;
  String? failureReason;
}

class SettingsReducer extends ReducerClass<Settings> {
  @override
  Settings call(Settings state, action) {
    return switch (action) {
      UserNameUpdated() => state..userName = action.userName,
      DarkAction() => state..dark = action.dark,
      HospitalNameAction() => state..hospitalName = action.hospitalName,
      CityAction() => state..city = action.city,
      InfoAction() => state..info = action.info,
      DateAction() => state..date = action.date,
      AnyFailureAction() =>
        state
          ..failureReason = action.failureReason.isEmpty
              ? null
              : action.failureReason,
      _ => state,
    };
  }
}

abstract class SettingsAction {
  const SettingsAction();
}

class UserNameUpdated extends SettingsAction {
  final String userName;
  const UserNameUpdated(this.userName);
}

class DarkAction extends SettingsAction {
  final bool dark;
  const DarkAction(this.dark);
}

class HospitalNameAction extends SettingsAction {
  final String hospitalName;
  const HospitalNameAction(this.hospitalName);
}

class CityAction extends SettingsAction {
  final String city;
  const CityAction(this.city);
}

class InfoAction extends SettingsAction {
  final String info;
  const InfoAction(this.info);
}

class DateAction extends SettingsAction {
  final DateTime date;
  const DateAction(this.date);
}

class AnyFailureAction extends SettingsAction {
  final String failureReason;
  const AnyFailureAction(this.failureReason);
}

class SettingsMW extends MiddlewareClass<Business> {
  static const key = 'userName';
  @override
  call(store, action, next) async {
    next(action);
    switch (action) {
      case GetUserNameAction():
        final userName = preferences.getString(key);
        if (userName != null) {
          dispatch(UserNameUpdated(userName));
        } else {
          dispatch(AnyFailureAction('User Name Not Found'));
        }
        break;
      case UserNameUpdated():
        await preferences.setString(key, action.userName);
        break;
      default:
    }
  }
}

class GetUserNameAction extends SettingsAction {}
