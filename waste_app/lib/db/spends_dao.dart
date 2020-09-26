import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/models/forms/edit_waste_form.dart';
import 'package:waste_app/models/forms/new_waste_form.dart';
import 'package:waste_app/models/smart_error.dart';
import 'package:waste_app/models/spend.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/smart_error_service.dart';
import 'package:waste_app/services/spending_categories_service.dart';

class SpendsDao {
  final dbReference = Firestore.instance;
  SmartErrorService smartErrorService = SmartErrorService();
  SpendingCategoriesService spendingCategoriesService =
      SpendingCategoriesService();

  Future<bool> saveNewWaste(NewWasteForm form) async {
    bool success = true;
    String uid = AuthService.currentUser.uid;

    Timestamp spendDate = Timestamp.fromDate(form.spendDate);
    Timestamp creationDate = Timestamp.fromDate(DateTime.now());

    String reason = form.reason.text;
    String walletId = form.walletId;
    String categoryId = form.categoryId;

    String wasteString = form.waste.text.replaceAll(',', '');
    double waste = double.parse(wasteString);

    await dbReference.collection('spends').add({
      'creationDate': creationDate,
      'reason': reason,
      'spendDate': spendDate,
      'userId': uid,
      'walletId': walletId,
      'categoryId': categoryId,
      'waste': waste
    }).then((value) {
      success = true;
      return success;
    }).catchError((onError) {
      print(onError);
      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Waste';
      errorDto.userId = uid;

      this.smartErrorService.saveError(errorDto);
      return success;
    });
    return success;
  }

  Future<bool> updateWaste(EditWasteForm form) async {
    bool success = true;
    String uid = AuthService.currentUser.uid;

    Timestamp spendDate = Timestamp.fromDate(form.spendDate);
    Timestamp lastUpdateDate = Timestamp.fromDate(DateTime.now());

    String reason = form.reason.text;
    String walletId = form.walletId;
    String spendId = form.spendId;
    String categoryId = form.categoryId;

    String wasteString = form.waste.text.replaceAll(',', '');
    double waste = double.parse(wasteString);

    await this.dbReference.collection('spends').document(spendId).setData({
      'reason': reason,
      'spendDate': spendDate,
      'userId': uid,
      'walletId': walletId,
      'waste': waste,
      'lastUpdate': lastUpdateDate,
      'categoryId': categoryId,
    }, merge: true).then((value) {
      success = true;
      return success;
    }).catchError((onError) {
      print(onError);
      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Update waste';
      errorDto.userId = uid;

      this.smartErrorService.saveError(errorDto);
      return success;
    });
    return success;
  }

  Future<bool> deleteWastesByWalletId(String walletId) async {
    bool success = false;

    await dbReference
        .collection('spends')
        .where('walletId', isEqualTo: walletId)
        .getDocuments()
        .then((onValue) {
      for (DocumentSnapshot ds in onValue.documents) {
        ds.reference.delete();
      }
      success = true;
      return success;
    }).catchError((onError) {
      print(onError);

      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Delete wallet spends';
      errorDto.userId = AuthService.currentUser.uid;

      this.smartErrorService.saveError(errorDto);

      return success;
    });
    return success;
  }

  Future<bool> deleteWaste(String spendId) async {
    bool success = true;

    await this
        .dbReference
        .collection('spends')
        .document(spendId)
        .delete()
        .then((value) {
      success = true;
      return success;
    }).catchError((onError) {
      print(onError);
      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Delete waste';
      errorDto.userId = AuthService.currentUser.uid;

      this.smartErrorService.saveError(errorDto);

      return success;
    });
    return success;
  }

  Future<List<Spend>> getSpendsByDAteIntervalAndCategoryId(
      String walletId,
      Timestamp fistDayOfCurrentMonthTimestamp,
      Timestamp lastDayOfCurrentMonthTimestamp,
      String categoryId) async {
    var spends = List<Spend>();
    var user = AuthService.currentUser;

    await dbReference
        .collection('spends')
        .where('walletId', isEqualTo: walletId)
        .where('spendDate',
            isGreaterThanOrEqualTo: fistDayOfCurrentMonthTimestamp)
        .where('spendDate', isLessThanOrEqualTo: lastDayOfCurrentMonthTimestamp)
        .where('categoryId', isEqualTo: categoryId)
        .getDocuments()
        .then((QuerySnapshot snapShot) {
      snapShot.documents.forEach((item) {
        var spend = Spend(item);

        spends.add(spend);
      });
      return spends;
    }).catchError((onError) {
      print(onError);

      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Get list of spends by month';
      errorDto.userId = user.uid;

      this.smartErrorService.saveError(errorDto);

      return spends;
    });
    return spends;
  }

  Future<List<Spend>> getSpendsByWalletId(String walletId) async {
    var spends = List<Spend>();

    await dbReference
        .collection('spends')
        .where('walletId', isEqualTo: walletId)
        .getDocuments()
        .then((QuerySnapshot snapShot) {
      snapShot.documents.forEach((item) {
        var spend = Spend(item);

        spends.add(spend);
      });
      return spends;
    }).catchError((onError) {
      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Get list of months/spends';
      errorDto.userId = AuthService.currentUser.uid;

      this.smartErrorService.saveError(errorDto);
      return spends;
    });
    return spends;
  }

  Future<List<Spend>> getSpendsByDateInterval(
      String walletId, Timestamp startDate, Timestamp endDate) async {
    var spends = List<Spend>();

    await dbReference
        .collection('spends')
        .where('walletId', isEqualTo: walletId)
        .where('spendDate', isGreaterThanOrEqualTo: startDate)
        .where('spendDate', isLessThanOrEqualTo: endDate)
        .getDocuments()
        .then((QuerySnapshot snapShot) {
      snapShot.documents.forEach((item) {
        var spend = Spend(item);

        spends.add(spend);
      });
      return spends;
    }).catchError((onError) {
      var user = AuthService.currentUser;

      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Get spends by date interval';
      errorDto.userId = user.uid;

      this.smartErrorService.saveError(errorDto);

      return spends;
    });
    return spends;
  }
}
