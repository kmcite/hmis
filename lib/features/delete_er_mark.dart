import 'package:hmis/domain/domain.dart';
import 'package:hmis/main.dart';

class DeleteErMarkDialog extends StatelessWidget {
  final ErMark mark;

  const DeleteErMarkDialog({super.key, required this.mark});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete entry'),
      content: const Text(
        'This will permanently remove this case from the register.',
      ),
      actions: [
        TextButton(
          onPressed: () => router.goToErCaseRegister(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            erRegisterRepository.remove(mark.id);
            router.goToErCaseRegister();
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
