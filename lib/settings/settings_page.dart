import 'package:hmis/main.dart';
import 'package:hmis/settings/hospital_repository.dart';
import 'package:hmis/settings/settings_bloc.dart';

const double paddingValue = 16.0;
const double borderRadiusValue = 12.0;
const double iconSize = 24.0;

class SettingsPage extends StatelessWidget {
  static const name = 'settings';

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(paddingValue),
        children: [
          _buildHospitalTile(context),
          const SizedBox(height: paddingValue),
          _buildThemeToggleButton(context),
          const SizedBox(height: paddingValue),
          _buildInvestigationsButton(context),
        ],
      ),
    );
  }

  Widget _buildHospitalTile(BuildContext context) {
    return ListTile(
      title: const Text('HOSPITAL INFORMATIONS'),
      subtitle: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'NAME',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadiusValue),
              ),
            ),
            initialValue: context.of<HospitalBloc>().name,
            onChanged: context.of<HospitalBloc>().setName,
            maxLength: 4,
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'CITY',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadiusValue),
              ),
            ),
            initialValue: context.of<HospitalBloc>().city,
            onChanged: context.of<HospitalBloc>().setCity,
            maxLength: 20,
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'INFORMATIONS',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadiusValue),
              ),
            ),
            initialValue: context.of<HospitalBloc>().info,
            onChanged: context.of<HospitalBloc>().setInfo,
            minLines: 2,
            maxLength: 50,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggleButton(BuildContext context) {
    return FilledButton(
      onPressed: context.of<SettingsBloc>().toggleThemeMode,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(FontAwesomeIcons.circleHalfStroke),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Toggle Theme Mode'),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestigationsButton(BuildContext context) {
    return FilledButton(
      onPressed: context
              .of<InvestigationsBloc>()
              .investigations
              .toSet()
              .containsAll([])
          ? null
          : () {
              // for (final investigation in investigationsBuiltIn) {
              //   if (!context.of<InvestigationsBloc>().state.contains(
              //         investigation,
              //       )) {
              //     context.of<InvestigationsBloc>().put(investigation);
              //   }
              // }
            },
      child: Row(
        children: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(FontAwesomeIcons.flask),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Built-In Investigations'),
          ),
        ],
      ),
    );
  }
}
