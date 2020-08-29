import 'package:waste_app/models/edit_waste_form.dart';
import 'package:waste_app/models/spend_by_month_dto.dart';
import 'package:waste_app/models/spending_category.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/models/new_waste_form.dart';
import 'package:waste_app/models/spend_item_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/models/smart_error.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/utils/constants.dart';
import 'smart_error_service.dart';

class SpendsService {
  final dbReference = Firestore.instance;
  SmartErrorService smartErrorService = SmartErrorService();

  Future<bool> waste(NewWasteForm form) async {
    bool success = false;

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
    }).catchError((onError) {
      print(onError);
      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Waste';
      errorDto.userId = uid;

      this.smartErrorService.saveError(errorDto);

      return success;
    });
    success = true;
    return success;
  }

  Future<bool> updateWaste(EditWasteForm form) async {
    bool success = false;

    String uid = AuthService.currentUser.uid;

    Timestamp spendDate = Timestamp.fromDate(form.spendDate);
    Timestamp lastUpdateDate = Timestamp.fromDate(DateTime.now());

    String reason = form.reason.text;
    String walletId = form.walletId;
    String spendId = form.spendId;

    String wasteString = form.waste.text.replaceAll(',', '');
    double waste = double.parse(wasteString);

    await dbReference.collection('spends').document(spendId).setData({
      'reason': reason,
      'spendDate': spendDate,
      'userId': uid,
      'walletId': walletId,
      'waste': waste,
      'lastUpdate': lastUpdateDate,
    }, merge: true).then((onValue) {
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

  Future<bool> deleteWaste(String spendId) async {
    bool success = false;

    await this
        .dbReference
        .collection('spends')
        .document(spendId)
        .delete()
        .then((onValue) {
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

  Future<List<SpendByMonthDto>> getSpendsByMonthDtoList() async {
    List<SpendByMonthDto> spendsByMonthDtoList = [];

    String walletId = AuthService.currentUser.currentWalletId;

    await dbReference
        .collection('spends')
        .where('walletId', isEqualTo: walletId)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((doc) {
        var spend = doc.data;

        Timestamp spendDateTimestamp = spend['spendDate'];
        DateTime spendDateComplete = spendDateTimestamp.toDate();
        DateTime spendYearAndMonth =
            DateTime(spendDateComplete.year, spendDateComplete.month);

        var spendItem =
            spendsByMonthDtoList.where((i) => i.date == spendYearAndMonth);
        double waste = double.parse(spend['waste'].toString());

        if (spendItem.isEmpty) {
          SpendByMonthDto newDto = SpendByMonthDto(spendYearAndMonth, waste);
          spendsByMonthDtoList.add(newDto);
        } else {
          int index = spendsByMonthDtoList
              .indexWhere((i) => i.date == spendYearAndMonth);
          SpendByMonthDto oldDto = spendsByMonthDtoList.elementAt(index);
          double oldWaste = oldDto.spent;
          double newWaste = oldWaste + waste;
          SpendByMonthDto newDto = SpendByMonthDto(spendYearAndMonth, newWaste);
          spendsByMonthDtoList[index] = newDto;
        }
      });
      return spendsByMonthDtoList.sort((a, b) => b.date.compareTo(a.date));
    }).catchError((onError) {
      print(onError);

      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Get list of months/spends';
      errorDto.userId = AuthService.currentUser.uid;

      this.smartErrorService.saveError(errorDto);

      return spendsByMonthDtoList;
    });
    return spendsByMonthDtoList;
  }

  Future<double> getTotalWasteByYear(DateTime completeDate) async {
    double totalWaste = 0.0;

    DateTime firstDayOfTheYear = DateTime(completeDate.year, 1, 1);
    Timestamp firstDayOfTheYearTimestamp =
        Timestamp.fromDate(firstDayOfTheYear);

    DateTime lastDayOfTheYear = DateTime(completeDate.year, 12, 31);
    Timestamp lastDayOfTheYearTimestamp = Timestamp.fromDate(lastDayOfTheYear);

    UserDto user = AuthService.currentUser;
    String walletId = user.currentWalletId;

    await dbReference
        .collection('spends')
        .where('walletId', isEqualTo: walletId)
        .where('spendDate', isGreaterThanOrEqualTo: firstDayOfTheYearTimestamp)
        .where('spendDate', isLessThanOrEqualTo: lastDayOfTheYearTimestamp)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((item) {
        var obj = item.data;
        double waste = double.parse(obj['waste'].toString());
        totalWaste = totalWaste + waste;
      });
      return totalWaste;
    }).catchError((onError) {
      print(onError);

      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Get total waste by year';
      errorDto.userId = user.uid;

      this.smartErrorService.saveError(errorDto);

      return totalWaste;
    });
    return totalWaste;
  }

  Future<List<SpendingCategory>> getSpendingCategories() async {
    bool isPtLanguage =
        AuthService.currentUser.language == Constants.languages[0];

    List<SpendingCategory> categories = List<SpendingCategory>();

    await this
        .dbReference
        .collection('spendingCategories')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((item) {
        String categoryId = item.documentID;

        var obj = item.data;

        String ptName = obj['displayNamePt'];
        String enName = obj['displayNameEn'];
        String value = obj['value'];

        SpendingCategory category =
            SpendingCategory(categoryId, ptName, enName, value);
        categories.add(category);
      });
      return isPtLanguage
          ? (categories.sort((a, b) => a.displayNamePt.compareTo(b.displayNamePt)))
          : (categories.sort((a, b) => a.displayNameEn.compareTo(b.displayNameEn)));
    }).catchError((onError) {
      print(onError);

      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Get list categories';
      errorDto.userId = AuthService.currentUser.uid;

      this.smartErrorService.saveError(errorDto);
      return categories;
    });
    return categories;
  }

  Future<List<SpendItem>> getSpendsByMonth(DateTime completeDate) async {
    List<SpendItem> spendsList = List<SpendItem>();

    DateTime fistDayOfCurrentMonth =
        DateTime(completeDate.year, completeDate.month, 1);

    Timestamp fistDayOfCurrentMonthTimestamp =
        Timestamp.fromDate(fistDayOfCurrentMonth);

    DateTime firstDayOfNextMonth =
        DateTime(completeDate.year, completeDate.month + 1, 1, 23, 59, 59);

    DateTime lastDayOfCurrentMonth =
        firstDayOfNextMonth.add(Duration(days: -1));

    Timestamp lastDayOfCurrentMonthTimestamp =
        Timestamp.fromDate(lastDayOfCurrentMonth);

    UserDto user = AuthService.currentUser;
    String walletId = user.currentWalletId;

    await dbReference
        .collection('spends')
        .where('walletId', isEqualTo: walletId)
        .where('spendDate',
            isGreaterThanOrEqualTo: fistDayOfCurrentMonthTimestamp)
        .where('spendDate', isLessThanOrEqualTo: lastDayOfCurrentMonthTimestamp)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((item) {
        String spendId = item.documentID;
        var obj = item.data;

        Timestamp spendDate = obj['spendDate'];
        double waste = double.parse(obj['waste'].toString());

        var spend = SpendItem(obj['userId'], obj['reason'], spendDate.toDate(),
            waste, spendId, obj['walletId']);

        spendsList.add(spend);
      });
      return spendsList.sort((a, b) => b.spendDate.compareTo(a.spendDate));
    }).catchError((onError) {
      print(onError);

      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Get list of spends by month';
      errorDto.userId = user.uid;

      this.smartErrorService.saveError(errorDto);

      return spendsList;
    });

    return spendsList;
  }
}
