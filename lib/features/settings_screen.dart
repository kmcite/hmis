import 'package:hmis/bussiness/restore_appication.dart';
import 'package:hmis/main.dart';
import 'package:hmis/bussiness/navigation.dart';
import 'package:hmis/bussiness/settings.dart';
import 'package:hmis/utils/redux.dart';

class SettingsScreen extends UI {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          children: [
            Text('HOSPITAL INFORMATIONS'),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'NAME',
              ),
              initialValue: state.settings.hospitalName,
              onChanged: (value) => dispatch(HospitalNameAction(value)),
              maxLength: 4,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'CITY',
              ),
              initialValue: state.settings.city,
              onChanged: (value) => dispatch(CityAction(value)),
              maxLength: 20,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'INFORMATIONS',
              ),
              initialValue: state.settings.info,
              onChanged: (value) => dispatch(InfoAction(value)),
              minLines: 2,
              maxLength: 50,
              maxLines: 4,
            ),
            FilledButton(
              onPressed: () => dispatch(DarkAction(!state.settings.dark)),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(FontAwesomeIcons.circleHalfStroke.data),
                  ),  
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Toggle Theme Mode'),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () => dispatch(NavigateTo(Investigations())),
              child: Row(
                children:  [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(FontAwesomeIcons.flask.data),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Built-In Investigations'),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                dispatch(RestoreAppication());
              },
              child: Icon(Icons.restore),
            ),
          ],
        ),
      ),
    );
  }
}
