import 'package:hmis/main.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});
  static const name = 'user_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'user profile',
        action: SizedBox(),
      ),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text(context.of<SettingsBloc>().userName),
          // ),
          Text(
            'please enter your name',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: TextFormField(
          //     initialValue: context.of<SettingsBloc>().userName,
          //     onChanged: context.of<SettingsBloc>().setUserName,
          //   ),
          // ),
        ],
      ),
    );
  }
}
