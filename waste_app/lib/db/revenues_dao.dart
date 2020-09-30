import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/models/forms/new_revenue_form.dart';
import 'package:waste_app/models/smart_error.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/smart_error_service.dart';

class RevenuesDao {
  final dbReference = Firestore.instance;
  SmartErrorService smartErrorService = SmartErrorService();

  Future<bool> saveNewRevenue(NewRevenueForm form) async {
    bool success = false;
    String uid = AuthService.currentUser.uid;

    Timestamp payDay = Timestamp.fromDate(form.payDay);
    Timestamp creationDate = Timestamp.fromDate(DateTime.now());

    String reason = form.reason.text;
    String walletId = form.walletId;

    String revenueString = form.revenueValue.text.replaceAll(',', '');
    double revenue = double.parse(revenueString);

    await dbReference.collection('revenues').add({
      'creationDate': creationDate,
      'reason': reason,
      'payDay': payDay,
      'userId': uid,
      'walletId': walletId,
      'revenueValue': revenue
    }).then((value) {
      success = true;
      return true;
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
