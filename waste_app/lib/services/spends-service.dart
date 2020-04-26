import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/models/spend_item_dto.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/services/auth_service.dart';

class SpendsService {
  final dbReference = Firestore.instance;

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
    String uid = user.uid;

    await dbReference
        .collection('spends')
        .where('walletId', isEqualTo: 'NrVZOfYKOMES17nLAPff')
        .where('spendDate',
            isGreaterThanOrEqualTo: fistDayOfCurrentMonthTimestamp)
        .where('spendDate', isLessThanOrEqualTo: lastDayOfCurrentMonthTimestamp)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((item) {
        var obj = item.data;

        Timestamp spendDate = obj['spendDate'];
        double waste = double.parse(obj['waste'].toString());

        var spend =
            SpendItem(obj['userId'], obj['reason'], spendDate.toDate(), waste);

        spendsList.add(spend);
      });
      return spendsList.sort((a, b) => b.spendDate.compareTo(a.spendDate));
    }).catchError((onError) {
      print(onError);
      return spendsList;
    });

    return spendsList;
  }
}
