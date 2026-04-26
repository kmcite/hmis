import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/main.dart';
import 'package:hmis/ui/marksheet/er_mark.dart';

class ErMarkPage extends StatefulWidget {
  final ErMark mark;
  const ErMarkPage(this.mark, {super.key});

  @override
  State<ErMarkPage> createState() => _ErMarkPageState();
}

class _ErMarkPageState extends State<ErMarkPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<ErMarkCubit>().onErMarkChanged(widget.mark);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mark = widget.mark;
    final caseType = CaseType.values[mark.caseType];
    final shift = DutyShift.values[mark.shift];
    final typeColor = caseType.color;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          mark.patientName.isEmpty ? 'Patient Details' : mark.patientName,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Case type hero banner ──────────────────────────────
            Card(
              elevation: 0,
              color: typeColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: typeColor.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(caseType.icon, color: typeColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            caseType.label,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: typeColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                _shiftIconData(shift),
                                size: 14,
                                color: theme.hintColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${shift.label}  ·  ${_formatDate(mark.date)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Patient Information ────────────────────────────────
            _SectionHeader(
              icon: Icons.person_pin_rounded,
              title: 'Patient Information',
            ),
            const SizedBox(height: 12),
            _InfoGroup(
              children: [
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: mark.patientName.isEmpty
                      ? 'Not assigned'
                      : mark.patientName,
                  dimmed: mark.patientName.isEmpty,
                ),
                if (mark.ageYears > 0)
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Age',
                    value: '${mark.ageYears} years',
                  ),
                _InfoRow(
                  icon: mark.isMale ? Icons.male : Icons.female,
                  label: 'Gender',
                  value: mark.isMale ? 'Male' : 'Female',
                ),
                if (mark.remarks.isNotEmpty)
                  _InfoRow(
                    icon: Icons.notes_outlined,
                    label: 'Remarks',
                    value: mark.remarks,
                    multiline: true,
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Case Information ───────────────────────────────────
            _SectionHeader(
              icon: Icons.medical_information_outlined,
              title: 'Case Information',
            ),
            const SizedBox(height: 12),
            _InfoGroup(
              children: [
                _InfoRow(
                  icon: _shiftIconData(shift),
                  label: 'Shift',
                  value: shift.label,
                ),
                _InfoRow(
                  icon: Icons.calendar_month_outlined,
                  label: 'Date',
                  value: _formatDate(mark.date),
                ),
                _InfoRow(
                  icon: Icons.history_outlined,
                  label: 'Recorded at',
                  value: _formatDateTime(mark.createdAt),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── helpers ──────────────────────────────────────────────────

  IconData _shiftIconData(DutyShift shift) {
    switch (shift) {
      case DutyShift.morning:
        return Icons.wb_sunny;
      case DutyShift.evening:
        return Icons.wb_twilight;
      case DutyShift.night:
        return Icons.nightlight_round;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatDateTime(DateTime dt) {
    return '${_formatDate(dt)}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─── SECTION HEADER ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

// ─── INFO GROUP ──────────────────────────────────────────────────────────────

class _InfoGroup extends StatelessWidget {
  final List<Widget> children;
  const _InfoGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor, width: 0.5),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: 52,
                endIndent: 16,
                color: theme.dividerColor.withOpacity(0.5),
              ),
          ],
        ],
      ),
    );
  }
}

// ─── INFO ROW ────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool dimmed;
  final bool multiline;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.dimmed = false,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: multiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.hintColor,
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.hintColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: dimmed
                    ? theme.hintColor
                    : theme.textTheme.bodyLarge?.color,
                fontStyle: dimmed ? FontStyle.italic : FontStyle.normal,
              ),
              maxLines: multiline ? null : 1,
              overflow: multiline
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
