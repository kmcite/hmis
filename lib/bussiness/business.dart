import 'package:hmis/bussiness/investigations.dart';
import 'package:hmis/bussiness/marks/marks.dart';
import 'package:hmis/bussiness/settings.dart';
import 'package:redux/redux.dart';

class Business {
  Settings settings = Settings();
  Investigations investigations = Investigations();
  Marks marks = Marks();
}

class BusinessReducer extends ReducerClass<Business> {
  @override
  Business call(Business state, action) {
    return switch (action) {
      SettingsAction() =>
        state..settings = SettingsReducer()(state.settings, action),
      InvestigationsAction() =>
        state
          ..investigations = InvestigationsReducer()(
            state.investigations,
            action,
          ),
      MarksAction() => state..marks = MarksReducer()(state.marks, action),
      _ => state,
    };
  }
}
