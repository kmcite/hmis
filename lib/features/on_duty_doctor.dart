import 'package:hmis/main.dart';
import 'package:hmis/bussiness/settings.dart';
import 'package:hmis/utils/redux.dart';

class OnDutyDoctor extends UI {
  const OnDutyDoctor({super.key});

  @override
  void init() {
    dispatch(GetUserNameAction());
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('On Duty Doctor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          children: [
            Text(state.settings.userName),
            Text(
              'Please enter your name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              initialValue: state.settings.userName,
              onChanged: (value) {
                dispatch(UserNameUpdated(value));
              },
            ),
            if (state.settings.failureReason != null)
              Text(state.settings.failureReason!),
          ],
        ),
      ),
    );
  }
}
