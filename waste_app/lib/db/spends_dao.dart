import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/models/smart_error.dart';
import 'package:waste_app/models/spend.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/smart_error_service.dart';

class SpendsDao {
  final dbReference = Firestore.instance;
  SmartErrorService smartErrorService = SmartErrorService();

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
      errorDto.feature = 'Get total waste (profile)';
      errorDto.userId = user.uid;

      this.smartErrorService.saveError(errorDto);

      return spends;
    });
    return spends;
  }
}
