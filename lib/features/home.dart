import 'package:hmis/main.dart';
import 'package:hmis/utils/redux.dart';

class Home extends UI {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HMIS'),
      ),
      body: Stack(
        children: [
          const Opacity(
            opacity: .3,
            child: Align(
              child: FaIcon(
                FontAwesomeIcons.hospital,
                size: 150,
              ),
            ),
          ),
          // Opacity(
          //   opacity: 0.4,
          //   child: Align(
          //     child: Text(context.of<HospitalBloc>().name),
          //   ),
          // ),
          Opacity(
            opacity: .9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FilledButton.icon(
                    onPressed: null,
                    icon:  Icon(
                      FontAwesomeIcons.hospital.data,
                    ),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.settings.hospitalName),
                          Text(state.settings.city),
                          Text(state.settings.info),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Total Patients',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${state.marks.all.length}',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text('top 3 category count: 45'),
                Text('max count on day: 45'),
                Text('max count on month: 45'),
                Text('max count on year: 45'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
