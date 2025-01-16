import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_parent/services/database/local/helpers/collage_helper.dart';
import 'package:go_parent/services/database/local/helpers/collage_pictures_helper.dart';
import 'package:go_parent/services/database/local/models/collage_model.dart';
import 'package:go_parent/services/database/local/models/colllage_pictures_model.dart';
import 'package:intl/intl.dart';
import 'package:go_parent/screens/gallery_page/gallery_brain.dart';
import 'package:go_parent/services/database/local/helpers/pictures_helper.dart';
import 'package:go_parent/services/database/local/models/pictures_model.dart';
import 'package:go_parent/services/database/local/sqlite.dart';
import 'package:go_parent/utilities/user_session.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';




class CollageScreen extends StatefulWidget {
  const CollageScreen({super.key});

  @override
  State<CollageScreen> createState() => _CollageScreenState();
}

class _CollageScreenState extends State<CollageScreen> {
  final userId = UserSession().userId;
  late final GalleryBrain galleryBrain;


  @override
  void initState() {
    super.initState();
    _initializeGalleryBrain();
  }

  Future<void> _initializeGalleryBrain() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dbService = DatabaseService.instance;
    final db = await dbService.database;
    final pictureHelper = PictureHelper(db);
    final collageHelper = CollageHelper(db);
    final collagePicturesHelper = CollagePicturesHelper(db);
    galleryBrain = GalleryBrain(pictureHelper, collageHelper, collagePicturesHelper);
  }


  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('You have no collage yet..'));
  }
}








   //           StaggeredGrid.count(
//   crossAxisCount: 4,
//   mainAxisSpacing: 4,
//   crossAxisSpacing: 4,
//   children: const [
//     StaggeredGridTile.count(
//       crossAxisCellCount: 2,
//       mainAxisCellCount: 2,
//       child: Tile(index: 0),
//     ),
//     StaggeredGridTile.count(
//       crossAxisCellCount: 2,
//       mainAxisCellCount: 1,
//       child: Tile(index: 1),
//     ),
//     StaggeredGridTile.count(
//       crossAxisCellCount: 1,
//       mainAxisCellCount: 1,
//       child: Tile(index: 2),
//     ),
//     StaggeredGridTile.count(
//       crossAxisCellCount: 1,
//       mainAxisCellCount: 1,
//       child: Tile(index: 3),
//     ),
//     StaggeredGridTile.count(
//       crossAxisCellCount: 4,
//       mainAxisCellCount: 2,
//       child: Tile(index: 4),
//     ),
//   ],
// );

    //         ListView.builder(
    // itemCount: collages.length,
    // itemBuilder: (context, index) {
    //   final collage = collages[index];

    //   // Decode collageData
    //   Map<String, dynamic> collageData;
    //   try {
    //     collageData = jsonDecode(collage.collageData!);
    //   } catch (e) {
    //     print('Error decoding collage data: $e');
    //     return const Text('Error decoding collage data'); // Handle error gracefully
    //   }

    //   return Card(
    //     margin: const EdgeInsets.all(8.0),
    //     child: Padding(
    //       padding: const EdgeInsets.all(16.0),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Text(
    //             collage.title,
    //             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //           ),
    //           const SizedBox(height: 8),
    //           Text('Created: ${_formatDate(collage.createdAt)}'),
    //           const SizedBox(height: 8),

    //           // Display the raw collageData
    //           Text('Collage Data (Raw): ${collage.collageData}'),

    //           // Display collageData in a more readable format (optional)
    //           const Text('Collage Data (Formatted):'),
    //           const SizedBox(height: 4),

    //           // Check if selectedPictures exists and is a List
    //           if (collageData.containsKey('selectedPictures') && collageData['selectedPictures'] is List)
    //             GridView.builder(
    //               shrinkWrap: true, // Important to prevent unbounded height errors
    //               physics: const NeverScrollableScrollPhysics(), // Disable scrolling within GridView
    //               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //                 crossAxisCount: 3, // Adjust as needed
    //                 crossAxisSpacing: 4,
    //                 mainAxisSpacing: 4,
    //               ),
    //               itemCount: (collageData['selectedPictures'] as List).length,
    //               itemBuilder: (context, index) {
    //                 final pictureId = (collageData['selectedPictures'] as List)[index];
    //                 return Text('Picture ID: $pictureId'); // Display each picture ID
    //               },
    //             )
    //           else
    //             const Text('No picture IDs found in collage data.'),
    //         ],
    //       ),
    //     ),
    //   );
    // },
    //         ),




                // Positioned(
                //     right: 32,
                //     bottom: 32,
                //     child: Tooltip(
                //       message: "Create a new collage",
                //       child: FloatingActionButton(
                //         backgroundColor: Colors.teal,
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
                //         child: const Icon(
                //           Icons.add,
                //           color: Colors.white,
                //         ),
                //       ),
                //     ),
                //   ),
