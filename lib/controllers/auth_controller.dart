import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok_flutter/constants.dart';
import 'package:tiktok_flutter/models/user_model.dart' as model;
import 'package:tiktok_flutter/views/screens/auth/log_in_screen.dart';
import 'package:tiktok_flutter/views/screens/home_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  late Rx<User?> _user;
  
  User get user => _user.value!;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(firebaseAuth.currentUser);
    _user.bindStream(firebaseAuth.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => LogInScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

  Future<String> _uploadToStorage(File image) async {
    Reference ref = firebaseStorage
        .ref()
        .child('profilePics')
        .child(firebaseAuth.currentUser!.uid);
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snap = await uploadTask;
    String downloadURL = await snap.ref.getDownloadURL();

    return downloadURL;
  }

  void signupUser(
      String username, String email, String password, File? image) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        UserCredential cred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String downloadURL = await _uploadToStorage(image);

        model.User user = model.User(
          name: username,
          email: email,
          profilePhoto: downloadURL,
          uid: cred.user!.uid,
        );
        await fireStore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());
      } else {
        Get.snackbar(
          'Error creating account',
          'Please enter all the fields',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error creating account',
        e.toString(),
      );
    }
  }

  void logInUser(
    String email,
    String password,
  ) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print("successful log in");
      } else {
        Get.snackbar(
          'Error logging in ',
          'Please enter all the fields',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error logging',
        e.toString(),
      );
    }
  }

  late Rx<File?> _pickedImage;
  File? get profilePhoto => _pickedImage.value;

  void pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      Get.snackbar("Profile picture", "Ypu have selected a profile picture");
    }
    _pickedImage = Rx<File?>(
      File(pickedImage!.path),
    );
  }

  void signOut() async{
    await firebaseAuth.signOut();   
  }
}
