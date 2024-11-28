import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'joy_ui.dart';

class JoyTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final TextInputType keyboardType;
  final validator;
  final inputFormatter;
  final onFieldSubmitted;
  final int? maxLenght;
  final String? hintText;

  const JoyTextFormField({
    super.key,
    required this.controller,
    this.labelText = '',
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.sentences,
    this.keyboardType = TextInputType.none,
    this.validator,
    this.inputFormatter,
    this.maxLenght,
    this.hintText,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLenght,
      inputFormatters: inputFormatter != null ? [inputFormatter] : [],
      validator: (value) {
        return validator(value);
      },
      onFieldSubmitted: (_) => onFieldSubmitted != null
          ? onFieldSubmitted()
          : FocusScope.of(Get.context!).nextFocus(),
      style: const TextStyle(color: Styles.primaryTextColor),
      decoration: InputDecoration(
        counterText: '',
        hintText: hintText,
        hintStyle: const TextStyle(color: Styles.greyDarker, fontSize: 14),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Styles.primaryTextColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Styles.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Styles.primaryTextColor),
        ),
        labelText: labelText,
        focusColor: Styles.primaryColor,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }
}
