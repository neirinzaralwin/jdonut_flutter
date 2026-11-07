import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/app_text_field.dart';

/// Read-only field that opens a localized month list.
class MonthField extends StatefulWidget {
  const MonthField({required this.month, required this.onSelected, super.key});

  final int? month;
  final ValueChanged<int> onSelected;

  @override
  State<MonthField> createState() => _MonthFieldState();
}

class _MonthFieldState extends State<MonthField> {
  static const int _monthsInYear = 12;
  // Any year works — only the month name is formatted.
  static const int _referenceYear = 2000;

  final TextEditingController _controller = TextEditingController();

  String _monthName(int month) => DateFormat.MMMM(
    Localizations.localeOf(context).toString(),
  ).format(DateTime(_referenceYear, month));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.text = widget.month == null ? '' : _monthName(widget.month!);
  }

  @override
  void didUpdateWidget(MonthField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month) {
      _controller.text = widget.month == null ? '' : _monthName(widget.month!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final month = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.colors.surface,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (var month = 1; month <= _monthsInYear; month++)
              ListTile(
                title: Text(_monthName(month), style: context.text.bodyLarge),
                selected: month == widget.month,
                onTap: () => Navigator.of(context).pop(month),
              ),
          ],
        ),
      ),
    );
    if (month != null) widget.onSelected(month);
  }

  @override
  Widget build(BuildContext context) => AppTextField(
    controller: _controller,
    hintText: context.l10n.monthHint,
    readOnly: true,
    onTap: _pick,
    suffixIcon: Icon(
      Icons.expand_more_rounded,
      color: context.colors.onSurfaceVariant,
    ),
  );
}
