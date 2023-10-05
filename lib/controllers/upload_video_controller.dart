import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:tiktok_flutter/constants.dart';
import 'package:tiktok_flutter/models/video_model.dart';
import 'package:video_compress/video_compress.dart';


class UploadVideoContreoller extends GetxController {
  
  _compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
    );
    return compressedVideo!.file;
  }

  Future<String> _uploadToStroage(String id, String videoPath) async {
    Reference ref = firebaseStorage.ref().child("videos").child(id);

    UploadTask uploadTask = ref.putFile(
      await _compressVideo(videoPath),
    );
    TaskSnapshot snap = await uploadTask;
    String downloadURL = await snap.ref.getDownloadURL();
    return downloadURL;
  }

  _getThumbNail(String videoPath) async {
    final thumbNail = await VideoCompress.getFileThumbnail(videoPath);
    return thumbNail;
  }

  Future<String> _uploadImageToStroage(String id, String videoPath) async {
    Reference ref = firebaseStorage.ref().child("thumbnails").child(id);

    UploadTask uploadTask = ref.putFile(
      await _getThumbNail(videoPath),
    );
    TaskSnapshot snap = await uploadTask;
    String downloadURL = await snap.ref.getDownloadURL();
    return downloadURL;
  }

  upladVideo(String songName, String caption, String videoPath) async {
    try {
      String uid = firebaseAuth.currentUser!.uid;
      DocumentSnapshot userDoc =
          await fireStore.collection("users").doc(uid).get();

      var allVideos = await fireStore.collection("videos").get();
      int len = allVideos.docs.length;

      String videoURL = await _uploadToStroage("Video $len", videoPath);

      String thumbNailURL =
          await _uploadImageToStroage("Video $len", videoPath);

      Video video = Video(
        username: (userDoc.data()! as Map<String, dynamic>)['name'],
        uid: uid,
        id: "Video $len",
        likes: [],
        commentCount: 0,
        shareCount: 0,
        songName: songName,
        caption: caption,
        videoURL: videoURL,
        videoThumbNail: thumbNailURL,
        profilePhoto: (userDoc.data()! as Map<String, dynamic>)['profilePhoto'],
      );

      await fireStore
          .collection("videos")
          .doc("Video $len")
          .set(video.toJson());
          
      Get.back();
    } catch (e) {
      Get.snackbar(
        "Error uploading video",
        e.toString(),
      );
    }
  }
}
