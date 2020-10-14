import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/models/dtos/transaction_block_dto.dart';
import 'package:waste_app/models/dtos/transaction_dto.dart';
import 'package:waste_app/models/forms/edit_waste_form.dart';
import 'package:waste_app/models/forms/new_revenue_form.dart';
import 'package:waste_app/models/forms/new_waste_form.dart';
import 'package:waste_app/models/smart_error.dart';
import 'package:waste_app/models/spend.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/smart_error_service.dart';
import 'package:waste_app/services/spending_categories_service.dart';
import 'package:waste_app/services/wallet_service.dart';

class TransactionsDao {
  final dbReference = Firestore.instance;
  SmartErrorService smartErrorService = SmartErrorService();
  SpendingCategoriesService spendingCategoriesService =
      SpendingCategoriesService();

  Future<bool> saveNewWaste(NewWasteForm form) async {
    bool success = false;
    String uid = AuthService.currentUser.uid;

    Timestamp spendDate = Timestamp.fromDate(form.spendDate);
    Timestamp creationDate = Timestamp.fromDate(DateTime.now());

    String reason = form.reason.text;
    String walletId = form.walletId;
    String categoryId = form.categoryId;

    String wasteString = form.waste.text.replaceAll(',', '');
    double waste = double.parse(wasteString);
    double wasteNegative = waste * (-1);

    await dbReference.collection('transactions').add({
      'creationDate': creationDate,
      'reason': reason,
      'transactionDate': spendDate,
      'userId': uid,
      'walletId': walletId,
      'categoryId': categoryId,
      'amount': wasteNegative,
      'type': 'WASTE'
    }).then((value) async {
      success = true;

      await WalletService.decrementBallance(form.walletId, waste);

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
    bool success = false;
    String uid = AuthService.currentUser.uid;

    Timestamp spendDate = Timestamp.fromDate(form.spendDate);
    Timestamp lastUpdateDate = Timestamp.fromDate(DateTime.now());

    String reason = form.reason.text;
    String walletId = form.walletId;
    String transactionId = form.spendId;
    String categoryId = form.categoryId;

    String wasteString = form.waste.text.replaceAll(',', '');
    double waste = double.parse(wasteString);

    if (waste > 0) {
      waste = waste * (-1);
    }

    await this
        .dbReference
        .collection('transactions')
        .document(transactionId)
        .setData({
      'reason': reason,
      'transactionDate': spendDate,
      'userId': uid,
      'walletId': walletId,
      'amount': waste,
      'lastUpdate': lastUpdateDate,
      'categoryId': categoryId,
      'type': 'WASTE'
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

  Future<bool> deleteWaste(String transactionId) async {
    bool success = false;

    await this
        .dbReference
        .collection('transactions')
        .document(transactionId)
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

  Future<bool> deleteTransactionsByWalletId(String walletId) async {
    bool success = false;

    await dbReference
        .collection('transactions')
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
      errorDto.feature = 'Delete wallet transactions';
      errorDto.userId = AuthService.currentUser.uid;

      this.smartErrorService.saveError(errorDto);

      return success;
    });
    return success;
  }

  Future<List<TransactionBlockDto>> getTransactionsByWalletId(
      String walletId) async {
    // List<TransactionDto> transactions = [];
    List<TransactionBlockDto> transactionBlockList = [];
    Map<DateTime, List<TransactionDto>> transactionByMonthMap =
        Map<DateTime, List<TransactionDto>>();

    await dbReference
        .collection('transactions')
        .where('walletId', isEqualTo: walletId)
        .orderBy('transactionDate', descending: true)
        // .limit(2)
        .getDocuments()
        .then((QuerySnapshot snapShot) {
      snapShot.documents.forEach((element) {
        var objMap = element.data;
        var transaction = TransactionDto();

        Timestamp transactionDateTimestamp = objMap['transactionDate'];
        DateTime transactionDate = transactionDateTimestamp.toDate();

        transaction.amount = double.parse(objMap['amount'].toString());
        transaction.reason = objMap['reason'];
        transaction.transactionId = element.documentID;
        transaction.transactionDate = transactionDate;

        DateTime key = DateTime(transactionDate.year, transactionDate.month, 1);

        if (transactionByMonthMap.containsKey(key)) {
          var values = transactionByMonthMap[key];

          values.add(transaction);

          transactionByMonthMap.remove(key);

          transactionByMonthMap.putIfAbsent(key, () => values);
        } else {
          // primeira entrada
          var list = List<TransactionDto>();
          list.add(transaction);
          transactionByMonthMap.putIfAbsent(key, () => list);
        }
        // transactions.add(transaction);
      });

      var sortedKeys = transactionByMonthMap.keys.toList(growable: false)
        ..sort((k1, k2) => k2.compareTo(k1));
      var sortedMap = Map<DateTime, List<TransactionDto>>.fromIterable(
          sortedKeys,
          key: (k) => k,
          value: (k) => transactionByMonthMap[k]);

      sortedMap.forEach((key, value) {
        TransactionBlockDto transactionBlock = TransactionBlockDto();

        transactionBlock.blockDate = key;
        transactionBlock.transactions = value;

        transactionBlockList.add(transactionBlock);
      });

      return transactionBlockList;
    }).catchError((onError) {
      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Get transactions by wallet id';
      errorDto.userId = AuthService.currentUser.uid;

      this.smartErrorService.saveError(errorDto);
      return transactionBlockList;
    });
    return transactionBlockList;
  }

  Future<List<TransactionDto>> getLast2Transactions(String walletId) async {
    List<TransactionDto> transactions = [];

    await dbReference
        .collection('transactions')
        .where('walletId', isEqualTo: walletId)
        .orderBy('transactionDate', descending: true)
        .limit(2)
        .getDocuments()
        .then((QuerySnapshot snapShot) {
      snapShot.documents.forEach((element) {
        var objMap = element.data;
        var transaction = TransactionDto();

        Timestamp transactionDateTimestamp = objMap['transactionDate'];

        transaction.amount = double.parse(objMap['amount'].toString());
        transaction.reason = objMap['reason'];
        transaction.transactionId = element.documentID;
        transaction.transactionDate = transactionDateTimestamp.toDate();

        transactions.add(transaction);
      });
      return transactions;
    }).catchError((onError) {
      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Get las 2 transactions';
      errorDto.userId = AuthService.currentUser.uid;

      this.smartErrorService.saveError(errorDto);
      return transactions;
    });
    return transactions;
  }

  Future<List<Spend>> getSpendsByWalletId(String walletId) async {
    var spends = List<Spend>();

    await dbReference
        .collection('transactions')
        .where('walletId', isEqualTo: walletId)
        .where('type', isEqualTo: 'WASTE')
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

  Future<List<Spend>> getSpendsByDateIntervalAndCategoryId(
      String walletId,
      Timestamp fistDayOfCurrentMonthTimestamp,
      Timestamp lastDayOfCurrentMonthTimestamp,
      String categoryId) async {
    var spends = List<Spend>();
    var user = AuthService.currentUser;

    await dbReference
        .collection('transactions')
        .where('walletId', isEqualTo: walletId)
        .where('transactionDate',
            isGreaterThanOrEqualTo: fistDayOfCurrentMonthTimestamp)
        .where('transactionDate',
            isLessThanOrEqualTo: lastDayOfCurrentMonthTimestamp)
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

  Future<List<Spend>> getSpendsByDateInterval(
      String walletId, Timestamp startDate, Timestamp endDate) async {
    var spends = List<Spend>();

    await dbReference
        .collection('transactions')
        .where('walletId', isEqualTo: walletId)
        .where('transactionDate', isGreaterThanOrEqualTo: startDate)
        .where('transactionDate', isLessThanOrEqualTo: endDate)
        .where('type', isEqualTo: 'WASTE')
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

  Future<bool> saveNewRevenue(NewRevenueForm form) async {
    bool success = false;
    String uid = AuthService.currentUser.uid;

    Timestamp payDay = Timestamp.fromDate(form.payDay);
    Timestamp creationDate = Timestamp.fromDate(DateTime.now());

    String reason = form.reason.text;
    String walletId = form.walletId;

    String revenueString = form.revenueValue.text.replaceAll(',', '');
    double revenue = double.parse(revenueString);

    await dbReference.collection('transactions').add({
      'creationDate': creationDate,
      'reason': reason,
      'transactionDate': payDay,
      'userId': uid,
      'walletId': walletId,
      'amount': revenue,
      'type': 'REVENUE'
    }).then((value) async {
      success = true;

      await WalletService.incrementBallance(form.walletId, revenue);

      return success;
    }).catchError((onError) {
      print(onError);
      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Recive new revenue';
      errorDto.userId = uid;

      this.smartErrorService.saveError(errorDto);
      return success;
    });
    return success;
  }
}
