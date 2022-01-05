import 'package:flutter/material.dart';

class NewRevenueForm {
  late TextEditingController reason;
  late TextEditingController revenueValue;
  late DateTime payDay;
  late String walletId;
  late String? uid;

  NewRevenueForm() {
    reason = TextEditingController();
    revenueValue = TextEditingController();
    payDay = DateTime.now();
  }
}
