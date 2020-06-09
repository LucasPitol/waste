import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/services/wallet_service.dart';

import 'auth_service.dart';

class GoogleSignService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Observable<FirebaseUser> user;
  Observable<Map<String, dynamic>> profile;
  WalletService walletService = WalletService();
  PublishSubject loading = PublishSubject();

  GoogleSignService() {
    user = Observable(_auth.onAuthStateChanged);

    profile = user.switchMap((FirebaseUser u) {
      if (u != null) {
        return _db
            .collection('user')
            .document(u.uid)
            .snapshots()
            .map((snap) => snap.data);
      } else {
        return Observable.just({});
      }
    });
  }

  Future<FirebaseUser> googleSignIn() async {
    loading.add(true);

    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

    List<Wallet> wallets = await updateUserData(user);

    AuthService.currentUser.email = user.email;
    AuthService.currentUser.name = user.displayName;
    AuthService.currentUser.uid = user.uid;
    AuthService.currentUser.walletList = wallets;
    AuthService.currentUser.currentWalletId = wallets[0].id;

    loading.add(false);
    return user;
  }

  Future<List<Wallet>> updateUserData(FirebaseUser user) async {
    List<Wallet> wallets;

    DocumentReference docRef = _db.collection('user').document(user.uid);

    Map<String, dynamic> preferencesMap = {
      'language': AuthService.currentUser.language,
      'theme': 'light'
    };

    await docRef.setData({
      'uid': user.uid,
      'email': user.email,
      'photoUrl': user.photoUrl,
      'name': user.displayName,
      'lastAccess': Timestamp.fromDate(DateTime.now()),
      'preferences': preferencesMap,
    }, merge: true);

    await this._setUserIdToLocalStorage(user.uid);

    wallets = await this.walletService.getWalletsByUserId(user.uid);

    return wallets;
  }

  void signOut() {
    this._clearLocalStorage();
    AuthService.currentUser = UserDto();
    _auth.signOut();
  }

  Future<void> _clearLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _setUserIdToLocalStorage(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setString(uid, 'Google');
  }

  Future<bool> loginByUid(String uid) async {
    DocumentReference docRef = _db.collection('user').document(uid);

    await docRef.setData({
      'uid': uid,
      'lastAccess': Timestamp.fromDate(DateTime.now()),
    }, merge: true);

    await this._setUserIdToLocalStorage(uid);

    List<Wallet> wallets = await this.walletService.getWalletsByUserId(uid);

    await docRef.get().then((onValue) {
      var user = onValue.data;

      AuthService.currentUser.email = user['email'];
      AuthService.currentUser.name = user['name'];
      AuthService.currentUser.uid = uid;
      AuthService.currentUser.walletList = wallets;
      AuthService.currentUser.currentWalletId = wallets[0].id;
    });
  }
}

final GoogleSignService googleSignService = GoogleSignService();
