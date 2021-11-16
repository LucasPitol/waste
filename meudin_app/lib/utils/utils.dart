import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meudin_app/models/forms/new_revenue_form.dart';
import 'package:meudin_app/models/forms/new_waste_form.dart';
import 'package:meudin_app/services/transaction_service.dart';
import 'package:meudin_app/services/user_service.dart';
import 'package:meudin_app/models/forms/new_user_form.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import 'constants.dart';

class Utils {
  static String formatDateDDdeMMMdeYYYY(DateTime? value) {
    if (value == null) {
      return Constants.EMPTY_STRING;
    } else {
      return DateFormat.yMMMMd(Constants.ptLanguage).format(value);
    }
  }

  static String formatDateDDMM(DateTime? value) {
    if (value == null) {
      return Constants.EMPTY_STRING;
    } else {
      return DateFormat.yMd(Constants.ptLanguage).add_jm().format(value);
    }
  }

  static String formatDateMMMdeYYYY(DateTime? value) {
    if (value == null) {
      return Constants.EMPTY_STRING;
    } else {
      return DateFormat.yMMMM(Constants.ptLanguage).format(value);
    }
  }

  static String formatAmount(double? value) {
    if (value == null) {
      return Constants.EMPTY_STRING;
    } else {
      return toCurrencyString(value.toString());
    }
  }

  static double convertStringFormToDouble(String valueStr) {
    String valueString = valueStr.replaceAll(',', '');
    double value = double.parse(valueString);

    return value;
  }

  static mockData() async {
    UserService _userService = UserService();

    NewUserForm _newUserForm = NewUserForm();
    _newUserForm.name.text = 'Judas';
    _newUserForm.email.text = 'judas@gmail.com';
    _newUserForm.password.text = '1234567';

    await _userService.createNewUser(_newUserForm);

    String spendingCategoriesCollectionName = 'spendingCategories';

    final dbReference = FirebaseFirestore.instance;

    var batch = dbReference.batch();

    var docRef1 =
        dbReference.collection(spendingCategoriesCollectionName).doc();

    String id1 = docRef1.id;

    batch.set(docRef1, {
      'id': id1,
      'displayNamePt': 'Internet',
      'value': 'internet',
    });

    var docRef2 =
        dbReference.collection(spendingCategoriesCollectionName).doc();

    String id2 = docRef2.id;

    batch.set(docRef2, {
      'id': id2,
      'displayNamePt': 'Veículo',
      'value': 'vehicle',
    });

    var docRef3 =
        dbReference.collection(spendingCategoriesCollectionName).doc();

    String id3 = docRef3.id;

    batch.set(docRef3, {
      'id': id3,
      'displayNamePt': 'Outros',
      'value': 'others',
    });

    // spending categories
    // await batch.commit();

    String walletId = UserService.currentUser!.currentWalletId;
    String userId = UserService.currentUser!.id;

    //transactions
    TransactionService ts = TransactionService();

    NewWasteForm nw1 = NewWasteForm();
    nw1.categoryId = id1;
    nw1.reason = TextEditingController(text: 'Crédito');
    nw1.spendDate = DateTime(2021, 11, 16);
    nw1.walletId = walletId;
    nw1.uid = userId;
    nw1.waste = TextEditingController(text: '-80');

    NewWasteForm nw2 = NewWasteForm();
    nw2.categoryId = id2;
    nw2.reason = TextEditingController(text: 'Gasolina');
    nw2.spendDate = DateTime(2021, 11, 10);
    nw2.walletId = walletId;
    nw2.uid = userId;
    nw2.waste = TextEditingController(text: '-250');

    NewWasteForm nw3 = NewWasteForm();
    nw3.categoryId = id2;
    nw3.reason = TextEditingController(text: 'Revisão');
    nw3.spendDate = DateTime(2021, 11, 5);
    nw3.walletId = walletId;
    nw3.uid = userId;
    nw3.waste = TextEditingController(text: '-450');

    NewWasteForm nw4 = NewWasteForm();
    nw4.categoryId = id3;
    nw4.reason = TextEditingController(text: 'Mesa');
    nw4.spendDate = DateTime(2021, 10, 20);
    nw4.walletId = walletId;
    nw4.uid = userId;
    nw4.waste = TextEditingController(text: '-850');

    NewRevenueForm nr1 = NewRevenueForm();
    nr1.payDay = DateTime(2021, 11, 5);
    nr1.reason = TextEditingController(text: 'Salário');
    nr1.revenueValue = TextEditingController(text: '4000');
    nr1.uid = userId;
    nr1.walletId = walletId;

    NewRevenueForm nr2 = NewRevenueForm();
    nr2.payDay = DateTime(2021, 10, 5);
    nr2.reason = TextEditingController(text: 'Salário');
    nr2.revenueValue = TextEditingController(text: '4000');
    nr2.uid = userId;
    nr2.walletId = walletId;

    // ts.saveNewWaste(nw1);
    // ts.saveNewWaste(nw2);
    // ts.saveNewWaste(nw3);
    // ts.saveNewWaste(nw4);

    // ts.saveNewRevenue(nr1);
    // ts.saveNewRevenue(nr2);
  }

  static String getAmountFormated(double amount) {
    return toCurrencyString(amount.toString());
  }
}
