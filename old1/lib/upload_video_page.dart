import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadVideoPage extends StatefulWidget {
  const UploadVideoPage({super.key});

  @override
  State<UploadVideoPage> createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {

  File? videoFile;
  bool uploading = false;
  double progress = 0;

  final picker = ImagePicker();

  // PICK VIDEO
  Future<void> pickVideo() async {
    final XFile? video =
    await picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      setState(() {
        videoFile = File(video.path);
      });
    }
  }

  // FFmpeg COMPRESSION
  Future<File?> compressVideo(File inputFile) async {

    final outputPath =
        "${inputFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.mp4";

    String command = """
    -i "${inputFile.path}"
    -vf scale=720:-2
    -c:v libx264
    -preset veryfast
    -crf 26
    -c:a aac
    -b:a 128k
    "$outputPath"
    """;

    await FFmpegKit.execute(command);

    return File(outputPath);
  }

  // UPLOAD VIDEO
  Future<String?> uploadVideo(File file) async {

    final ref = FirebaseStorage.instance
        .ref()
        .child("videos/${DateTime.now().millisecondsSinceEpoch}.mp4");

    UploadTask uploadTask = ref.putFile(file);

    uploadTask.snapshotEvents.listen((event) {
      setState(() {
        progress = event.bytesTransferred / event.totalBytes;
      });
    });

    TaskSnapshot snapshot = await uploadTask;

    return await snapshot.ref.getDownloadURL();
  }

  // SAVE TO FIRESTORE
  Future<void> saveToFirestore(String url) async {
    await FirebaseFirestore.instance.collection("videos").add({
      "videoUrl": url,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // FULL PROCESS
  Future<void> processVideo() async {

    if (videoFile == null) return;

    setState(() {
      uploading = true;
    });

    print("Original: ${videoFile!.lengthSync() ~/ (1024 * 1024)} MB");

    File? compressed = await compressVideo(videoFile!);

    print("Compressed: ${compressed!.lengthSync() ~/ (1024 * 1024)} MB");

    String? url = await uploadVideo(compressed);

    if (url != null) {
      await saveToFirestore(url);
    }

    compressed.delete(); // cleanup

    setState(() {
      uploading = false;
      videoFile = null;
      progress = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Upload Complete")),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Upload Video")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            if (videoFile != null)
              const Text("Video Selected"),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: pickVideo,
              child: const Text("Pick Video"),
            ),

            const SizedBox(height: 20),

            if (uploading)
              Column(
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 10),
                  Text("${(progress * 100).toStringAsFixed(0)}%"),
                ],
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: uploading ? null : processVideo,
              child: uploading
                  ? const Text("Uploading...")
                  : const Text("Upload Video"),
            ),
          ],
        ),
      ),
    );
  }
}