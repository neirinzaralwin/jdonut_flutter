import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/theme/theme.dart';

/// The one text input of the app: white field, animated focus/error border,
/// animated error message below.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.controller,
    required this.hintText,
    this.focusNode,
    this.prefixText,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final FocusNode? focusNode;
  final String? prefixText;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? suffixIcon;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _ownFocusNode = FocusNode();
  bool _hasFocus = false;

  FocusNode get _focusNode => widget.focusNode ?? _ownFocusNode;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _ownFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() => _hasFocus = _focusNode.hasFocus);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_field(context), _error(context)],
    );
  }

  Widget _field(BuildContext context) {
    final colors = context.colors;
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? colors.error
        : (_hasFocus ? colors.primary : colors.surface);
    return AnimatedContainer(
      duration: context.motion(AppDurations.fast),
      constraints: const BoxConstraints(minHeight: AppSizes.inputHeight),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(
          color: borderColor,
          width: AppSizes.inputBorderWidth,
        ),
      ),
      alignment: Alignment.centerLeft,
      child: _input(context),
    );
  }

  Widget _input(BuildContext context) => TextField(
    controller: widget.controller,
    focusNode: _focusNode,
    readOnly: widget.readOnly,
    onTap: widget.onTap,
    keyboardType: widget.keyboardType,
    textInputAction: widget.textInputAction,
    inputFormatters: widget.inputFormatters,
    autofillHints: widget.autofillHints,
    onChanged: widget.onChanged,
    onSubmitted: widget.onSubmitted,
    style: context.text.bodyLarge,
    cursorColor: context.colors.primary,
    decoration:
        InputDecoration.collapsed(
          hintText: widget.hintText,
          hintStyle: context.text.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ).copyWith(
          prefixText: widget.prefixText,
          prefixStyle: context.text.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          suffixIcon: widget.suffixIcon,
        ),
  );

  Widget _error(BuildContext context) => AnimatedSize(
    duration: context.motion(AppDurations.fast),
    alignment: Alignment.topCenter,
    child: widget.errorText == null
        ? const SizedBox(width: double.infinity)
        : Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s2),
            child: Text(
              widget.errorText!,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
  );
}
