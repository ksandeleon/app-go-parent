// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:go_parent/screens/gallery_page/gallery_brain.dart';
// import 'package:go_parent/services/database/local/helpers/pictures_helper.dart';
// import 'package:go_parent/services/database/local/models/pictures_model.dart';
// import 'package:go_parent/services/database/local/sqlite.dart';
// import 'package:go_parent/utilities/user_session.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// class GalleryScreen extends StatefulWidget {
//   const GalleryScreen({super.key});
//   static String id = "gallery_screen";

//   @override
//   State<GalleryScreen> createState() => _GalleryScreenState();
// }

// class _GalleryScreenState extends State<GalleryScreen> {
//   final userId = UserSession().userId;
//   late final GalleryBrain galleryBrain;
//   List<PictureModel> pictures = [];
//   bool isLoading = true;
//   bool isSelectMode = false;
//   Set<int> selectedPictureIds = {};

//   @override
//   void initState() {
//     super.initState();
//     _initializeGalleryBrain();
//   }

//   // ... (keep existing initialization and loading methods)

//   Future<void> _createCollage() async {
//     if (selectedPictureIds.isEmpty) return;

//     final titleController = TextEditingController();
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Create Collage'),
//         content: TextField(
//           controller: titleController,
//           decoration: const InputDecoration(
//             labelText: 'Collage Title',
//             hintText: 'Enter a title for your collage',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Create'),
//           ),
//         ],
//       ),
//     );

//     if (result == true && titleController.text.isNotEmpty) {
//       try {
//         // Insert into collagedb
//         final collageData = {
//           'layout': 'grid', // You can make this configurable
//           'selectedPictures': selectedPictureIds.toList(),
//         };

//         final db = await DatabaseService.instance.database;
//         final collageId = await db.insert('collagedb', {
//           'userId': userId,
//           'title': titleController.text,
//           'collageData': jsonEncode(collageData),
//         });

//         // Insert into collage_pictures
//         final batch = db.batch();
//         for (final pictureId in selectedPictureIds) {
//           batch.insert('collage_pictures', {
//             'collageId': collageId,
//             'pictureId': pictureId,
//           });
//         }
//         await batch.commit();

//         // Exit select mode and clear selections
//         setState(() {
//           isSelectMode = false;
//           selectedPictureIds.clear();
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Collage created successfully!')),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error creating collage: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (pictures.isEmpty) {
//       return const Center(child: Text('No pictures found'));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isSelectMode ? 'Select Pictures' : 'Gallery'),
//         actions: [
//           if (isSelectMode) ...[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   isSelectMode = false;
//                   selectedPictureIds.clear();
//                 });
//               },
//               child: const Text('Cancel', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           if (isSelectMode) {
//             if (selectedPictureIds.isNotEmpty) {
//               _createCollage();
//             }
//           } else {
//             setState(() {
//               isSelectMode = true;
//             });
//           }
//         },
//         child: Icon(isSelectMode ? Icons.check : Icons.grid_view),
//       ),
//       body: GridView.builder(
//         padding: const EdgeInsets.all(8),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 8,
//           mainAxisSpacing: 8,
//           childAspectRatio: 0.8,
//         ),
//         itemCount: pictures.length,
//         itemBuilder: (context, index) {
//           final picture = pictures[index];
//           final heroTag = 'picture_${picture.pictureId}';
//           final isSelected = selectedPictureIds.contains(picture.pictureId);

//           return Card(
//             clipBehavior: Clip.antiAlias,
//             elevation: 2,
//             child: InkWell(
//               onTap: () {
//                 if (isSelectMode) {
//                   setState(() {
//                     if (isSelected) {
//                       selectedPictureIds.remove(picture.pictureId);
//                     } else {
//                       selectedPictureIds.add(picture.pictureId!);
//                     }
//                   });
//                 } else {
//                   _showFullScreenImage(context, picture, heroTag);
//                 }
//               },
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       Expanded(
//                         child: Hero(
//                           tag: heroTag,
//                           child: Image.file(
//                             File(picture.photoPath),
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Container(
//                                 color: Colors.grey[300],
//                                 child: const Icon(Icons.error),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                       // ... (keep existing metadata display)
//                     ],
//                   ),
//                   if (isSelectMode)
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: isSelected ? Colors.blue : Colors.white,
//                         ),
//                         padding: const EdgeInsets.all(2),
//                         child: Icon(
//                           isSelected ? Icons.check : Icons.circle_outlined,
//                           size: 20,
//                           color: isSelected ? Colors.white : Colors.grey,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ... (keep existing _showFullScreenImage method)
// }
