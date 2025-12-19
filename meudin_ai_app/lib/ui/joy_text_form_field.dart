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
      style: const TextStyle(
        color: Styles.primaryTextColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Styles.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.red[300]!,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          color: Styles.primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
