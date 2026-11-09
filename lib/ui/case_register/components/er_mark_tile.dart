import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/er_mark_draft_cubit.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/ui/shared/dialogs/delete_er_mark.dart';
import 'package:hmis/ui/new_chit/new_chit_screen.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/ui/shared/widgets/sheet_arrival_banner.dart';
import 'package:hmis/services/datetime.dart';

class ErMarkTile extends StatelessWidget {
  final Mark mark;
  const ErMarkTile(this.mark);

  void _openMark(BuildContext context) {
    context.read<ErMarkDraftCubit>().open(mark.id);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewChitScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shift = mark.shift;
    final caseType = mark.caseType;
    final color = caseType.color;

    return LiquidCard(
      onTap: () => _openMark(context),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  LiquidChip(
                    label: caseType.label,
                    icon: caseType.icon,
                    tint: color,
                    dense: true,
                  ),
                  const SizedBox(width: 8),
                  LiquidChip(
                    label: shift.label,
                    tint: theme.colorScheme.secondary,
                    dense: true,
                  ),
                  const Spacer(),
                  LiquidIconButton(
                    size: 36,
                    icon: Icons.edit_outlined,
                    tint: theme.colorScheme.primary,
                    onPressed: () => _openMark(context),
                  ),
                  LiquidIconButton(
                    size: 36,
                    icon: Icons.delete_outline,
                    tint: theme.colorScheme.error,
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => DeleteErMarkDialog(mark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Patient info
              Text(
                mark.patientName?.isEmpty ?? true
                    ? 'Anonymous Patient'
                    : mark.patientName!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: mark.patientName?.isEmpty ?? true
                      ? theme.disabledColor
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 6),
              MarkDateChips(mark: mark),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: theme.hintColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    // Real datetime (wall-clock, never altered)
                    mark.createdAt?.formattedDateTime() ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  if ((mark.ageYears ?? 0) > 0) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      mark.info,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ],
              ),
              if (mark.remarks?.isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                Text(
                  mark.remarks!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.hintColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
    );
  }
}
