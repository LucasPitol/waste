import 'package:flutter/material.dart';

class NewWasteForm {
  late TextEditingController reason;
  late TextEditingController waste;
  late String categoryId;
  late DateTime spendDate;
  late String? uid;
  late String walletId;

  NewWasteForm() {
    reason = TextEditingController();
    waste = TextEditingController();
    spendDate = DateTime.now();
  }
}
