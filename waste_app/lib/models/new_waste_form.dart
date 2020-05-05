import 'package:flutter/material.dart';

class NewWasteForm {
  TextEditingController reason;
  TextEditingController waste;
  DateTime spendDate;
  String walletId;

  NewWasteForm() {
    this.reason = new TextEditingController();
    this.waste = new TextEditingController();
    this.spendDate = DateTime.now();
  }
}