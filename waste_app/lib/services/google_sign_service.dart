import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/services/wallet-service.dart';

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

    wallets = await this.walletService.getWalletsByUserId(user.uid);

    return wallets;
  }

  void signOut() {
    _auth.signOut();
  }
}

final GoogleSignService googleSignService = GoogleSignService();
