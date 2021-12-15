import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meudin_app/models/smart_error.dart';
import 'package:meudin_app/models/user.dart';
import 'package:meudin_app/services/smart_error_service.dart';

class UserDao {
  final dbReference = FirebaseFirestore.instance;
  final String _usersCollectionName = 'user';

  late SmartErrorService _smartErrorService;

  UserDao() {
    _smartErrorService = SmartErrorService();
  }

  // Future<User?> auth(String userMail, String password) async {
  //   User? user;

  //   await dbReference
  //       .collection(_usersCollectionName)
  //       .where('email', isEqualTo: userMail)
  //       .where('password', isEqualTo: password)
  //       .get()
  //       .then((snapShot) {
  //     for (var item in snapShot.docs) {
  //       user = User(item);
  //     }
  //   }).catchError((onError) {
  //     SmartError errorDto = SmartError();
  //     errorDto.errorData = onError;
  //     errorDto.errorLog = onError.toString();
  //     errorDto.feature = 'Login';
  //     errorDto.userId = '';
  //     errorDto.userMail = userMail;

  //     _smartErrorService.saveError(errorDto);
  //   });

  //   return user;
  // }

  // Future<String?> changePassword(String password, String uid) async {
  //   DateTime lastUpdate = DateTime.now();

  //   DocumentReference docRef =
  //       dbReference.collection(_usersCollectionName).doc(uid);

  //   await docRef.set(
  //       {'password': password, 'lastUpdate': Timestamp.fromDate(lastUpdate)},
  //       SetOptions(merge: true));

  //   return uid;
  // }

  // Future<String> createNewUser(
  //     String displayName, String userEmail, String password) async {
  //   Timestamp creationDate = Timestamp.fromDate(DateTime.now());

  //   var batch = dbReference.batch();

  //   var docRef = dbReference.collection(_usersCollectionName).doc();

  //   String id = docRef.id;

  //   batch.set(docRef, {
  //     'id': id,
  //     'displayName': displayName,
  //     'email': userEmail,
  //     'password': password,
  //     'privacyPolicyCheckedAt': creationDate,
  //     'creationDate': creationDate,
  //   });

  //   await batch.commit().then((value) {
  //     return id;
  //   }).catchError((onError) {
  //     SmartError errorDto = SmartError();
  //     errorDto.errorData = onError;
  //     errorDto.errorLog = onError.toString();
  //     errorDto.feature = 'Create user';
  //     errorDto.userId = id;
  //     errorDto.userMail = userEmail;

  //     _smartErrorService.saveError(errorDto);
  //     return '';
  //   });

  //   return id;
  // }

  // Future<List<User>> getUsersByIds(List<String> memberIdList) async {
  //   List<User> users = [];

  //   var snapShot = await dbReference
  //       .collection(_usersCollectionName)
  //       .where('id', whereIn: memberIdList)
  //       .get();

  //   for (var item in snapShot.docs) {
  //     User user = User(item);

  //     users.add(user);
  //   }

  //   users.sort((a, b) => b.displayName.compareTo(a.displayName));

  //   return users;
  // }

  // Future<User?> getUserByEmail(String userMail) async {
  //   User? user;

  //   await dbReference
  //       .collection(_usersCollectionName)
  //       .where('email', isEqualTo: userMail)
  //       .get()
  //       .then((snapShot) {
  //     for (var item in snapShot.docs) {
  //       user = User(item);
  //     }
  //   });

  //   return user;
  // }

  // Future<User?> loginByUid(String uid) async {
  //   User? user;

  //   DocumentReference docRef = dbReference.collection('user').doc(uid);

  //   await docRef.get().then((onValue) async {
  //     if (onValue.exists) {
  //       user = User(onValue);
  //     }
  //   }).catchError((onError) {
  //     print(onError);

  //     SmartError errorDto = SmartError();
  //     errorDto.errorData = onError;
  //     errorDto.errorLog = onError.toString();
  //     errorDto.feature = 'Auto login';
  //     errorDto.userId = uid;

  //     _smartErrorService.saveError(errorDto);
  //   });

  //   return user;
  // }
}
