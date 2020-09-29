import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class NewRevenueForm {
  TextEditingController reason;
  MoneyMaskedTextController revenueValue;
  DateTime payDay;
  String walletId;

  NewRevenueForm() {
    this.reason = new TextEditingController();
    this.revenueValue = new MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
    this.payDay = DateTime.now();
  }
}