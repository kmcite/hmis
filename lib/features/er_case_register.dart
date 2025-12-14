import 'package:hmis/domain/domain.dart';
import 'package:hmis/main.dart';
import 'package:hmis/utils/datetime.dart';

class ErCaseRegisterPage extends StatelessWidget {
  const ErCaseRegisterPage({super.key});

  DateTime get date => erRegisterRepository.value.date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ER Register · ${date.format()}',
        ),
        actions: [
          IconButton(
            onPressed: () {
              router.goToMarkSheet();
            },
            icon: Icon(Icons.home),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: erRegisterRepository,
        builder: (_, __) {
          final marks = erRegisterRepository.dailySheet(date)
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

          if (marks.isEmpty) {
            return const Center(child: Text('No cases recorded'));
          }

          return ListView.separated(
            itemCount: marks.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final mark = marks[index];
              return _ErMarkTile(
                mark: mark,
                onDelete: () => router.goToDeleteErMarkDialog(mark),
              );
            },
          );
        },
      ),
    );
  }
}

class _ErMarkTile extends StatelessWidget {
  final ErMark mark;
  final VoidCallback onDelete;

  const _ErMarkTile({
    required this.mark,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final shift = DutyShift.values[mark.shift];
    final caseType = CaseType.values[mark.caseType];

    return ListTile(
      dense: true,
      title: Text(
        mark.patientName.isEmpty ? caseType.label : mark.patientName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${caseType.label} · ${shift.name} · Age ${mark.ageYears}',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}
