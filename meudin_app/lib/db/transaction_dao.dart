import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meudin_app/models/forms/new_revenue_form.dart';
import 'package:meudin_app/models/smart_error.dart';
import 'package:meudin_app/services/smart_error_service.dart';
import 'package:meudin_app/utils/utils.dart';

class TransactionDao {
  final dbReference = FirebaseFirestore.instance;
  final String _transactionCollectionName = 'transactions';

  late SmartErrorService _smartErrorService;

  TransactionDao() {
    _smartErrorService = SmartErrorService();
  }
  Future<String> saveNewRevenue(NewRevenueForm form) async {
    Timestamp payDay = Timestamp.fromDate(form.payDay);
    Timestamp creationDate = Timestamp.fromDate(DateTime.now());

    String? uid = form.uid;
    String? reason = form.reason.text;
    double amount = Utils.convertStringFormToDouble(form.revenueValue.text);
    String? walletId = form.walletId;

    var batch = dbReference.batch();

    var docRef = dbReference.collection(_transactionCollectionName).doc();

    String id = docRef.id;

    batch.set(docRef, {
      'id': id,
      'userId': uid,
      'reason': reason,
      'transactionDate': payDay,
      'walletId': walletId,
      'amount': amount,
      'type': 'REVENUE',
      'creationDate': creationDate,
    });

    await batch.commit().then((value) {
      return id;
    }).catchError((onError) {
      SmartError errorDto = SmartError();
      errorDto.errorData = onError;
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Save revenue';
      errorDto.userId = id;
      errorDto.userMail = '';

      _smartErrorService.saveError(errorDto);
      return '';
    });

    return id;
  }
}
