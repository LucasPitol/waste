import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class EditWasteForm {
  TextEditingController reason;
  MoneyMaskedTextController waste;
  DateTime spendDate;
  String walletId;
  String spendId;
  String categoryId;

  EditWasteForm() {
    this.reason = new TextEditingController();
    this.waste = new MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
    this.spendDate = DateTime.now();
  }
}