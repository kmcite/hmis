import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/models/models.dart';
import 'package:hmis/ui/chit/chit_notifier.dart';
import 'package:hmis/ui/chit/custom_chit_header.dart';
import 'sections/vitals_section.dart';
import 'sections/symptoms_section.dart';
import 'sections/examination_section.dart';
import 'sections/diagnosis_section.dart';
import 'sections/prescription_section.dart';
import 'sections/actions_section.dart';
import 'sections/chit_preview.dart';

class ChitScreen extends StatefulWidget {
  const ChitScreen({super.key});

  @override
  State<ChitScreen> createState() => _ChitScreenState();
}

class _ChitScreenState extends State<ChitScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      context.read<ChitNotifier>().updateName(_nameController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showSavePicker() {
    int selectedShift = 0;
    int selectedCaseType = 0;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Save to Register',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select duty shift and case type for this patient.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Duty Shift',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              value: selectedShift,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHigh,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: DutyShift.values.asMap().entries.map((
                                entry,
                              ) {
                                return DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value.label),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedShift = value!);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Case Type',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              value: selectedCaseType,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHigh,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: CaseType.values.asMap().entries.map((
                                entry,
                              ) {
                                return DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value.label),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedCaseType = value!);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<ChitNotifier>().saveToErMark(
                        shift: selectedShift,
                        caseType: selectedCaseType,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Saved to Case Register'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Confirm & Save'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<ChitNotifier>().state.patientName),
        centerTitle: true,
      ),
      // backgroundColor: colorScheme.surface,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BlocBuilder<ChitNotifier, PatientChit>(
            builder: (context, chit) => CustomChitHeader(
              nameController: _nameController,
              isMale: chit.isMale,
              age: chit.age,
              onGenderToggle: () => context.read<ChitNotifier>().toggleGender(),
              onAgeChanged: (v) => context.read<ChitNotifier>().updateAge(v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const ChitPreview(),
                const VitalsSection(),
                const SymptomsSection(),
                const ExaminationSection(),
                const DiagnosisSection(),
                const PrescriptionSection(),
                const ActionsSection(),
              ],
            ),
          ),
          const SizedBox(height: 100), // Spacing for bottom bar
        ],
      ),
      bottomNavigationBar: Container(
        padding: .all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          spacing: 16,
          children: [
            Expanded(
              child: FloatingActionButton.extended(
                heroTag: 'save-to-register',
                onPressed: _showSavePicker,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Save to Register'),
              ),
            ),
            FloatingActionButton(
              heroTag: 'reset-chit',
              child: const Icon(Icons.refresh),
              onPressed: () {
                context.read<ChitNotifier>().reset();
                _nameController.clear();
              },
              tooltip: 'Reset',
            ),
          ],
        ),
      ),
    );
  }
}
