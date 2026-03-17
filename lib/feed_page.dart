// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:video_player/video_player.dart';
// import 'upload_video_page.dart';
//
//
// class FeedPage extends StatelessWidget {
//   const FeedPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Civic Connect Feed"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.upload),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const UploadVideoPage(),
//                 ),
//               );
//             },
//           )
//         ],
//       ),
//
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection("videos")
//             .orderBy("createdAt", descending: true)
//             .snapshots(),
//
//         builder: (context, snapshot) {
//
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           final docs = snapshot.data!.docs;
//
//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//
//               final videoUrl = docs[index]['videoUrl'];
//
//               return VideoItem(videoUrl: videoUrl);
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// class VideoItem extends StatefulWidget {
//   final String videoUrl;
//
//   const VideoItem({super.key, required this.videoUrl});
//
//   @override
//   State<VideoItem> createState() => _VideoItemState();
// }
//
// class _VideoItemState extends State<VideoItem> {
//
//   late VideoPlayerController controller;
//
//   @override
//   void initState() {
//     super.initState();
//
//     controller = VideoPlayerController.networkUrl(
//       Uri.parse(widget.videoUrl),
//     )
//       ..initialize().then((_) {
//         setState(() {});
//         controller.play();
//         controller.setLooping(true);
//       });
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Container(
//       margin: const EdgeInsets.all(10),
//       height: 300,
//       color: Colors.black,
//
//       child: controller.value.isInitialized
//           ? AspectRatio(
//         aspectRatio: controller.value.aspectRatio,
//         child: VideoPlayer(controller),
//       )
//           : const Center(child: CircularProgressIndicator()),
//     );
//   }
// }