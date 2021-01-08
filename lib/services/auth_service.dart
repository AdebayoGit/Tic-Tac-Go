import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:tic_tac_go_project/models/User.dart';
import 'package:tic_tac_go_project/models/Error.dart';
import 'package:tic_tac_go_project/utils/user_util.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

class UserService {
  FirebaseAuth _auth;
  GoogleSignIn _googleSignIn;

  UserService() {
    _auth = FirebaseAuth.instance;
   _googleSignIn = GoogleSignIn();
  }

  /*Future<User> authenticateWithFaceBook() async {
    var facebookLogin = new FacebookLogin();
    var result = await facebookLogin.logInWithReadPermissions(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        FirebaseUser user = await _auth.signInWithFacebook(
            accessToken: result.accessToken.token);
        return _processAuthUser(user);
        break;
      case FacebookLoginStatus.cancelledByUser:
        throw (AppError('Login Cancelled'));
        break;
      case FacebookLoginStatus.error:
        throw (AppError('Login Failed'));
        break;
    }

    return null;
  }*/
  Future<User> authenticateWithGoogle() async {
    try {
        GoogleSignInAccount googleUser = await _googleSignIn.signIn();
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final FirebaseUser user = (await _auth.signInWithCredential(credential)) as FirebaseUser;
        print("signed in " + user.displayName);
        return _processAuthUser(user);
    } catch (error) {
      throw (AppError('Error occured during google authentication'));
    }
  }

  Future<User> signUpWithEmailAndPassword(username, email, password) async {
    final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
        email: email, password: password)) as FirebaseUser;
    UserUpdateInfo updateInfo = new UserUpdateInfo();
    updateInfo.displayName = username;
    await user.updateProfile(updateInfo);
    return signInWithEmailAndPasword(email, password);
  }

  Future<User> signInWithEmailAndPasword(email, password) async {
    final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
        email: email, password: password)) as FirebaseUser;
    return _processAuthUser(user);
  }

  logoutUser() async{
    if((await _auth.currentUser()) != null){
      _auth.signOut();
    }
  }

  Future<User> _processAuthUser(FirebaseUser authUser) async {

    User loggedInUser = User(
        id: authUser.uid,
        email: authUser.email,
        name: authUser.displayName,
        avatarUrl: authUser.photoUrl);

    String fcmToken = await _getTokenFromPreference();
    loggedInUser = loggedInUser.copyWith(fcmToken: fcmToken);
    await _addUserToFireStore(loggedInUser);
    return loggedInUser;
  }

  Future<Null> _addUserToFireStore(User user) async {

    await Firestore.instance
        .collection('users')
        .document(user.id)
        .setData({'email': user.email, 'displayName': user.name, 'fcmToken': user.fcmToken, 'currentState': UserUtil().getStringFromState(UserState.available)});
  }

  saveUserFcmTokenToPreference(String token) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  addUserTokenToStore(String userId, String fcmToken) async{
    await Firestore.instance
        .collection('users')
        .document(userId)
        .setData({'fcmToken': fcmToken}, merge: true);
  }

  Future<String> _getTokenFromPreference() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fcmToken = prefs.getString('fcm_token');
    return fcmToken;
  }

  Future<User> getCurrentUser() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String   token = prefs.getString('fcm_token');
    FirebaseUser currentUser = await _auth.currentUser();
    if(currentUser != null){
      return User(id: currentUser.uid, name: currentUser.displayName, avatarUrl: currentUser.photoUrl , fcmToken:  token );
    }
    return null;

  }

  checkUserPresence(){
    FirebaseDatabase.instance
        .reference()
        .child('.info/connected')
        .onValue.listen((Event event) async{
      if(event.snapshot.value == false){
        return;
      }
      User currentUser = await getCurrentUser();
      FirebaseDatabase.instance.reference().child('/status/'+currentUser.id).onDisconnect().set({
        'state': UserUtil().getStringFromState(UserState.offline)
      }).then((onValue){
        FirebaseDatabase.instance.reference().child('/status/'+currentUser.id).set({
          'state': UserUtil().getStringFromState(UserState.available)
        });
      });
    });
  }
}
