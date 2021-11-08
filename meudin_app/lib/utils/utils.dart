import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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

    var docRef1 = dbReference.collection(spendingCategoriesCollectionName).doc();

    String id1 = docRef1.id;

    batch.set(docRef1, {
      'id': id1,
      'displayNamePt': 'Internet',
      'value': 'internet',
    });

    var docRef2 = dbReference.collection(spendingCategoriesCollectionName).doc();

    String id2 = docRef2.id;

    batch.set(docRef2, {
      'id': id2,
      'displayNamePt': 'Veículo',
      'value': 'vehicle',
    });

    var docRef3 = dbReference.collection(spendingCategoriesCollectionName).doc();

    String id3 = docRef3.id;

    batch.set(docRef3, {
      'id': id3,
      'displayNamePt': 'Outros',
      'value': 'others',
    });

    await batch.commit();
  }
}
