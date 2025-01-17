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
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  Future<void> _saveCollage(String collagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final targetPath = Directory('${directory.path}/GoParentCollages');
      if (!targetPath.existsSync()) {
        targetPath.createSync(recursive: true);
      }
      final fileName = collagePath.split('/').last;
      final newFilePath = '${targetPath.path}/$fileName';
      final collageFile = File(collagePath);
      await collageFile.copy(newFilePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Collage saved to $newFilePath')),
      );
    } catch (e) {
      debugPrint('Error saving collage: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save collage')),
      );
    }
  }

void _showSaveCollageDialog(String collagePath) {
  Alert(
    context: context,
    title: "Choose an Option",
    content: Text("What would you like to do with this collage?"),
    buttons: [
      DialogButton(
        child: Text(
          "Save",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          try {
            final directory = await getApplicationDocumentsDirectory();
            final targetPath = Directory('${directory.path}/GoParentCollages');
            if (!await targetPath.exists()) {
              await targetPath.create(recursive: true);
            }

            final fileName = collagePath.split('/').last;
            final savedPath = '${targetPath.path}/$fileName';
            final File originalFile = File(collagePath);
            await originalFile.copy(savedPath);

            Navigator.pop(context); // Close the dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Collage saved to $savedPath")),
            );
          } catch (e) {
            Navigator.pop(context); // Close the dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to save collage: $e")),
            );
          }
        },
        color: Colors.teal,
      ),
      DialogButton(
        child: Text(
          "Share",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          Navigator.pop(context); // Close the dialog
          try {
            await Share.shareXFiles([XFile('${collagePath}')], text: "Check out my collage!");
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to share collage: $e")),
            );
          }
        },
        color: Colors.blue,
      ),
    ],
  ).show();
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
            padding: EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
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
                  if (collage.collageData != null) {
                    _showSaveCollageDialog(collage.collageData!);
                  }
                },
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal, width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
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
                  ),
                ),
              ),
              );
            },
          );
  }
}
