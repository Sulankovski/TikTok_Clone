import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tiktok_flutter/controllers/auth_controller.dart';
import 'package:tiktok_flutter/views/screens/add_video_screen.dart';
import 'package:tiktok_flutter/views/screens/profile_screen.dart';
import 'package:tiktok_flutter/views/screens/search_screen.dart';
import 'package:tiktok_flutter/views/screens/video_feed_screen.dart';

const backgroundColor = Colors.black;
var buttonColor = Colors.red[400];
const borderColor = Colors.grey;

var firebaseAuth = FirebaseAuth.instance;
var firebaseStorage = FirebaseStorage.instance;
var fireStore = FirebaseFirestore.instance;

var authController = AuthController.instance;

List pages = [
  VideoFeedScreen(),
  SearchScreen(),
  const AddVideoScreen(),
  const Text("Message screen"),
  ProfileScreen(uid: authController.user.uid)
];
