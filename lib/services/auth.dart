import 'package:cstballprogram/models/user.dart';
import 'package:cstballprogram/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cstballprogram/screens/authenticate/authenticate.dart';

class AuthService {
  final FirebaseAuth _fAuth = FirebaseAuth.instance;

  // create user obj based on FirebaseUser
  cUser? _userFromFirebaseUser(User? user) {
    return user != null ? cUser(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<cUser?> get loginstatus {
    return _fAuth.authStateChanges().map(_userFromFirebaseUser);
  }

  //sign in with email and pass
  Future signInEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _fAuth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      User user = result.user as User;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //register with email & pass
  Future registerEmailAndPassword(
      String name, String email, String password) async {
    try {
      UserCredential result = await _fAuth.createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      User user = result.user as User;

      // create a new document for the user with the uid
      teacher
          ? await DatabaseService(uid: user.uid)
              .createNewTeacherData(name, [], true, 0)
          : await DatabaseService(uid: user.uid).createNewStudentData(
              name, [], [], [], [], [], 0.0, 0.0, 0.0, 0.0, [], [], false);
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future logOut() async {
    try {
      return await _fAuth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
