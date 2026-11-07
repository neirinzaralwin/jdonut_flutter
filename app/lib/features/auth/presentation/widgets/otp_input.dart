import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jdonut/core/constants/app_constants.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/theme/theme.dart';

/// Six OTP boxes driven by one hidden-text TextField, which gives auto-advance,
/// backspace-back, paste-fills-all and SMS autofill (oneTimeCode) for free.
class OtpInput extends StatelessWidget {
  const OtpInput({
    required this.controller,
    required this.focusNode,
    required this.onCompleted,
    this.enabled = true,
    this.hasError = false,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onCompleted;
  final bool enabled;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.otpBox,
      child: Stack(
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => _boxes(context, value.text),
          ),
          Positioned.fill(child: _hiddenField(context)),
        ],
      ),
    );
  }

  Widget _hiddenField(BuildContext context) => Opacity(
    // Kept in the tree (not offstage) so long-press paste works.
    opacity: 0,
    child: TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      autofocus: true,
      keyboardType: TextInputType.number,
      autofillHints: const [AutofillHints.oneTimeCode],
      maxLength: AppConstants.otpLength,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      showCursor: false,
      decoration: const InputDecoration(
        counterText: '',
        border: InputBorder.none,
      ),
      onChanged: (code) {
        if (code.length == AppConstants.otpLength) onCompleted(code);
      },
    ),
  );

  Widget _boxes(BuildContext context, String code) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      for (var index = 0; index < AppConstants.otpLength; index++)
        _OtpBox(
          digit: index < code.length ? code[index] : '',
          isActive:
              enabled &&
              index == code.length.clamp(0, AppConstants.otpLength - 1),
          hasError: hasError,
        ),
    ],
  );
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.digit,
    required this.isActive,
    required this.hasError,
  });

  final String digit;
  final bool isActive;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final border = hasError
        ? colors.error
        : (isActive ? colors.primary : colors.surface);
    return AnimatedContainer(
      duration: context.motion(AppDurations.fast),
      width: AppSizes.otpBox,
      height: AppSizes.otpBox,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: border, width: AppSizes.inputBorderWidth),
      ),
      child: AnimatedSwitcher(
        duration: context.motion(AppDurations.fast),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Text(
          digit,
          key: ValueKey(digit),
          style: context.text.titleLarge,
        ),
      ),
    );
  }
}
