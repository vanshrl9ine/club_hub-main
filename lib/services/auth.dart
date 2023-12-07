// import 'package:club_hub/Pages/LoginAndSignup/login.dart';
// import 'package:club_hub/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class Auth {
  // late Rx<User?> _user;
  // @override
  // void onReady() {
  //   super.onReady();
  //   _user = Rx<User?>(FirebaseAuth.instance.currentUser);
  //   _user.bindStream(FirebaseAuth.instance.authStateChanges());
  //   ever(_user, _setInitialScreen);
  // }

  // _setInitialScreen(User? user) {
  //   if (user == null) {
  //     Get.offAll(() => const LoginPage());
  //   } else {
  //     Get.offAll(() => const HomePage(currentIndex: 0));
  //   }
  // }

  static savetofirestore(String? name, email, uid, photourl) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': email,
      'name': name,
      'photourl': photourl,
      'profileType': 'User',
    });
  }

  static Future<String> signupUser(
      String email, String password, String name) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      await FirebaseAuth.instance.currentUser!.updateDisplayName(name);
      await FirebaseAuth.instance.currentUser!.updateEmail(email);
      await savetofirestore(name, email, userCredential.user!.uid,
          'https://firebasestorage.googleapis.com/v0/b/clubhub-739f9.appspot.com/o/user_1177568.png?alt=media&token=d1ee94a4-1d7b-4b50-a7af-2b32b7813b2e');
      print('success');
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }


  // Update your signinUser method in the Auth class
  static Future<String> signinUser(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Additional step: Check if email is verified
      User user = FirebaseAuth.instance.currentUser!;

      if (user.emailVerified) {
        return 'success';
      } else {
        // If email is not verified, sign out the user and show a message
        await FirebaseAuth.instance.signOut();
        return 'Email not verified. Check your email inbox.';
      }
    } catch (e) {
      return e.toString();
    }
  }


  static Future<String> googleLogin() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    // try {
    var result = await googleSignIn.signIn();
    if (result == null) {
      return 'error!';
    }

    final userData = await result.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: userData.accessToken, idToken: userData.idToken);
    var finalResult =
        await FirebaseAuth.instance.signInWithCredential(credential);

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    List<String> userIds = snapshot.docs.map((doc) => doc.id).toList();
    if (!userIds.contains(finalResult.user!.uid)) {
      final resp = await http.get(Uri.parse(finalResult.user!.photoURL ??
          'https://firebasestorage.googleapis.com/v0/b/clubhub-739f9.appspot.com/o/user_1177568.png?alt=media&token=d1ee94a4-1d7b-4b50-a7af-2b32b7813b2e'));
      final imageBytes = resp.bodyBytes;
      String fileName = 'profile_pic'; // Change the filename format as needed
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('Profile')
          .child(finalResult.user!.uid)
          .child(fileName);
      UploadTask uploadTask = ref.putData(imageBytes);
      TaskSnapshot snap = await uploadTask;
      String url = await snap.ref.getDownloadURL();
      await savetofirestore(
          result.displayName, result.email, finalResult.user!.uid, url);
      return 'first';
    } else {
      return 'success';
    }
  }
  //  catch (error) {
  //   return error.toString();
  // }

  static Future<String> logout() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      bool isGoogleSignedIn =
          user!.providerData.any((info) => info.providerId == 'google.com');
      if (isGoogleSignedIn) {
        await GoogleSignIn().disconnect();
      }
      await FirebaseAuth.instance.signOut();
      return 'Signed Out';
    } catch (error) {
      return error.toString();
    }
  }
}
