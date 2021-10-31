import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meudin_app/models/user.dart';

class UserDao {
  final dbReference = FirebaseFirestore.instance;
  final String _usersCollectionName = 'user';

  Future<User?> auth(String userMail, String password) async {
    User? user;

    await dbReference
        .collection(_usersCollectionName)
        .where('email', isEqualTo: userMail)
        .where('password', isEqualTo: password)
        .get()
        .then((snapShot) {
      for (var item in snapShot.docs) {
        user = User(item);
      }
    });

    return user;
  }

  // Future<bool> createNewUser(
  //     String userName, String userEmail, String password) async {
  //   bool success = false;
  //   Timestamp creationDate = Timestamp.fromDate(DateTime.now());

  //   var batch = dbReference.batch();

  //   var docRef = dbReference.collection(_usersCollectionName).doc();

  //   String id = docRef.id;

  //   batch.set(docRef, {
  //     'id': id,
  //     'name': userName,
  //     'email': userEmail,
  //     'password': password,
  //     'userType': 1,
  //     'creationDate': creationDate,
  //   });

  //   await batch.commit().then((value) {
  //     success = true;
  //     return success;
  //   }).catchError((onError) {
  //     print(onError);
  //     return success;
  //   });
  //   return success;
  // }

  // Future<User> getUserByEmail(String userMail) async {
  //   User user;

  //   await dbReference
  //       .collection(_usersCollectionName)
  //       .where('email', isEqualTo: userMail)
  //       .get()
  //       .then((snapShot) {
  //     snapShot.docs.forEach((item) {
  //       user = User(item);
  //     });
  //   });

  //   return user;
  // }

  Future<User?> loginByUid(String uid) async {
    User? user;

    return user;
    // DocumentReference docRef = dbReference.collection('user').doc(uid);

    // await docRef.get().then((onValue) async {

    //   if (onValue.exists) {

    //   }
    // }).catchError((onError) {
    //   print(onError);

    //   SmartError errorDto = SmartError();
    //   errorDto.errorData = onError;
    //   errorDto.errorLog = onError.toString();
    //   errorDto.feature = 'Auto login';
    //   errorDto.userId = uid;

    //   this.smartErrorService.saveError(errorDto);
    // });
  }
}
