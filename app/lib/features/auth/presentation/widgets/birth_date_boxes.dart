import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/app_text_field.dart';

/// Screen 6: three boxes — Month, Day, Year — like the design. They're
/// read-only; tapping any of them opens the native date picker ([onTap]).
class BirthDateBoxes extends StatefulWidget {
  const BirthDateBoxes({
    required this.date,
    required this.onTap,
    this.errorText,
    super.key,
  });

  /// Null until the user picks a date (boxes show their hints).
  final DateTime? date;
  final VoidCallback onTap;
  final String? errorText;

  @override
  State<BirthDateBoxes> createState() => _BirthDateBoxesState();
}

class _BirthDateBoxesState extends State<BirthDateBoxes> {
  final TextEditingController _month = TextEditingController();
  final TextEditingController _day = TextEditingController();
  final TextEditingController _year = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fill();
  }

  @override
  void didUpdateWidget(BirthDateBoxes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) _fill();
  }

  void _fill() {
    final date = widget.date;
    final locale = Localizations.localeOf(context).toString();
    _month.text = date == null ? '' : DateFormat.MMMM(locale).format(date);
    _day.text = date == null ? '' : '${date.day}';
    _year.text = date == null ? '' : '${date.year}';
  }

  @override
  void dispose() {
    _month.dispose();
    _day.dispose();
    _year.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _box(_month, context.l10n.monthHint),
      const SizedBox(height: AppSpacing.s4),
      _box(_day, context.l10n.dayHint),
      const SizedBox(height: AppSpacing.s4),
      _box(_year, context.l10n.yearHint, errorText: widget.errorText),
    ],
  );

  Widget _box(
    TextEditingController controller,
    String hint, {
    String? errorText,
  }) => AppTextField(
    key: ValueKey('birth-$hint'),
    controller: controller,
    hintText: hint,
    readOnly: true,
    onTap: widget.onTap,
    errorText: errorText,
  );
}
