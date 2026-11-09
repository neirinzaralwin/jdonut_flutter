import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';

/// The platform's own date picker: the wheel in a sheet on iOS, the
/// calendar dialog on Android. Returns null if dismissed.
Future<DateTime?> showBirthdayPicker(
  BuildContext context, {
  required DateTime initial,
  required DateTime today,
}) {
  final start = initial.isAfter(today) ? today : initial;
  return Platform.isIOS
      ? _showWheel(context, initial: start, today: today)
      : showDatePicker(
          context: context,
          initialDate: start,
          firstDate: DateTime(_earliestYear),
          lastDate: today,
          helpText: context.l10n.selectBirthday,
        );
}

const int _earliestYear = 1900;
const double _sheetHeight = 390;

Future<DateTime?> _showWheel(
  BuildContext context, {
  required DateTime initial,
  required DateTime today,
}) => showModalBottomSheet<DateTime>(
  context: context,
  isScrollControlled: true,
  backgroundColor: context.colors.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
  ),
  builder: (_) => _WheelSheet(initial: initial, today: today),
);

class _WheelSheet extends StatefulWidget {
  const _WheelSheet({required this.initial, required this.today});

  final DateTime initial;
  final DateTime today;

  @override
  State<_WheelSheet> createState() => _WheelSheetState();
}

class _WheelSheetState extends State<_WheelSheet> {
  late DateTime _selected = widget.initial;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SizedBox(
      height: _sheetHeight,
      child: Column(
        children: [
          _header(context),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: _selected,
              maximumDate: widget.today,
              minimumDate: DateTime(_earliestYear),
              onDateTimeChanged: (date) => _selected = date,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s5,
              AppSpacing.s2,
              AppSpacing.s5,
              AppSpacing.s4,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_selected),
                child: Text(context.l10n.select),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _header(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.s5,
      AppSpacing.s4,
      AppSpacing.s3,
      AppSpacing.s2,
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.selectBirthday,
            style: context.text.titleLarge?.copyWith(
              color: context.colors.primary,
            ),
          ),
        ),
        IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    ),
  );
}
