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
  static String id = "collage_screen";

  @override
  State<CollageScreen> createState() => _CollageScreenState();
}

class _CollageScreenState extends State<CollageScreen> {
  final userId = UserSession().userId;
  late final GalleryBrain galleryBrain;
  bool isLoading = true;

  List<CollageModel> collages = [];

  @override
  void initState() {
    super.initState();
    _initializeGalleryBrain();
  }

  Future<void> _initializeGalleryBrain() async {
    try {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final dbService = DatabaseService.instance;
      final db = await dbService.database;
      final pictureHelper = PictureHelper(db);
      final collageHelper = CollageHelper(db);
      final collagePicturesHelper = CollagePicturesHelper(db);
      galleryBrain = GalleryBrain(pictureHelper, collageHelper, collagePicturesHelper);
      await _loadCollages();
    } catch (e) {
      debugPrint('Error initializing GalleryBrain: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadCollages() async {
    if (userId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final fetchedCollages = await galleryBrain.collageHelper.getAllCollagesByUserId(userId!);
      setState(() {
        collages = fetchedCollages;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading collages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return collages.isEmpty
        ? Center(
            child: Text(
              "You have no collages yet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
        : GridView.builder(
            padding: EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: collages.length,
            itemBuilder: (context, index) {
              CollageModel collage = collages[index];
              return GridTile(
                footer: GridTileBar(
                  backgroundColor: Colors.black54,
                  title: Text(
                    collage.title,
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    // Handle collage tap
                  },
                  child: collage.collageData != null && File(collage.collageData!).existsSync()
                      ? Image.file(
                          File(collage.collageData!),
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                ),
              );
            },

          );
  }
}
