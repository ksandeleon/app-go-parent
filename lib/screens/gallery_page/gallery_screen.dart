import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_parent/screens/gallery_page/collage_creator_screen.dart';
import 'package:go_parent/screens/gallery_page/collage_screen.dart';
import 'package:go_parent/services/database/local/helpers/collage_helper.dart';
import 'package:go_parent/services/database/local/helpers/collage_pictures_helper.dart';
import 'package:go_parent/utilities/constants.dart';
import 'package:intl/intl.dart';
import 'package:go_parent/screens/gallery_page/gallery_brain.dart';
import 'package:go_parent/services/database/local/helpers/pictures_helper.dart';
import 'package:go_parent/services/database/local/models/pictures_model.dart';
import 'package:go_parent/services/database/local/sqlite.dart';
import 'package:go_parent/utilities/user_session.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});
  static String id = "gallery_screen";

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final userId = UserSession().userId;
  late final GalleryBrain galleryBrain;
  List<PictureModel> pictures = [];


  bool isLoading = true;
  bool isSelectMode = false;
  Set<int> selectedPictureIds = {};

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
    await _loadPictures();
  }

  Future<void> _loadPictures() async {
    try {
      final pics = await galleryBrain.pictureHelper.getPicturesByUserId(userId!);
      setState(() {
        pictures = pics;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading pictures: $e');
    }
  }


  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';
    return DateFormat('MMM d, y').format(date);
  }

@override
Widget build(BuildContext context) {
  if (isLoading) {
    return const Center(child: CircularProgressIndicator());
  }


  return Scaffold(
    appBar: AppBar(
      elevation: 8,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.teal,
      title: isSelectMode
        ? Text(
            '${selectedPictureIds.length}/6 Selected',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          )
        : const Text(
            'Go Gallery',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
      actions: [
        if (isSelectMode)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() {
                isSelectMode = false;
                selectedPictureIds.clear();
              });
            },
          )
        else
          Tooltip(
            message: 'Refresh gallery',
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadPictures,
            ),
          ),
      ],
    ),
    body: DefaultTabController(
      length: 2,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white38,
              automaticallyImplyLeading: false,
              elevation: 0,
              bottom: const TabBar(
                indicatorColor: Colors.teal,
                labelColor: Colors.teal,
                unselectedLabelColor: Colors.black54,
                tabs: [
                  Tab(text: 'Joyful Pictures', icon: Icon(Icons.image)),
                  Tab(text: 'Memory Collage', icon: Icon(Icons.grid_on)),
                ],

              ),
            ),
            body: TabBarView(
              children: [
                pictures.isEmpty
                ? const Center(child: Text('You have no photos yet.. Lets Complete A Mission First' ,style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)) // Show message when no pictures
                : Stack(
                  children: [
                    GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: pictures.length,
                      itemBuilder: (context, index) {
                        final picture = pictures[index];
                        final heroTag = 'picture_${picture.pictureId}';
                        final isSelected = selectedPictureIds.contains(picture.pictureId);

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.teal, // Teal border
                              width: isSelected ? 6.0 : 3.0, // Thicker border if selected
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: InkWell(
                            onTap: () {
                              if (isSelectMode) {
                                setState(() {
                                  if (isSelected) {
                                    selectedPictureIds.remove(picture.pictureId);
                                  } else {
                                    if (selectedPictureIds.length >= 6) {
                                      Alert(
                                        context: context,
                                        type: AlertType.warning,
                                        title: "Selection Limit",
                                        desc: "You can only select up to 6 pictures for a collage.",
                                        buttons: [
                                          DialogButton(
                                            child: const Text(
                                              "OK",
                                              style: TextStyle(color: Colors.white, fontSize: 20),
                                            ),
                                            onPressed: () => Navigator.pop(context),
                                            color: Colors.teal,
                                          )
                                        ],
                                      ).show();
                                      return;
                                    }
                                    selectedPictureIds.add(picture.pictureId!);
                                  }
                                });
                              } else {
                                _showFullScreenImage(context, picture, heroTag);
                              }
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Hero(
                                        tag: heroTag,
                                        child: Image.file(
                                          File(picture.photoPath),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.error),
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    // ... rest of your image details ...

                                  ],
                                ),
                                if (isSelectMode)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? Colors.teal : Colors.white,
                                        border: Border.all(
                                          color: Colors.teal,
                                          width: 2,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Icon(
                                          Icons.check,
                                          size: 16,
                                          color: isSelected ? Colors.white : Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ),
                        );
                      },
                    ),
                    Positioned(
                      right: 32,
                      bottom: 32,
                      child: Tooltip(
                        message: isSelectMode ? "Continue" : "Create Collage",
                        child: FloatingActionButton(
                          elevation: 12,
                          backgroundColor: Colors.teal,
                          onPressed: () {
                            if (isSelectMode) {
                              if (selectedPictureIds.isEmpty) {
                                Alert(
                                  context: context,
                                  type: AlertType.warning,
                                  title: "No Pictures Selected",
                                  desc: "Please select at least two pictures to create a collage.",
                                  buttons: [
                                    DialogButton(
                                      child: const Text(
                                        "OK",
                                        style: TextStyle(color: Colors.white, fontSize: 20),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                      color: Colors.teal,
                                    ),
                                  ],
                                ).show();
                              } else if (selectedPictureIds.length < 2) {
                                Alert(
                                  context: context,
                                  type: AlertType.warning,
                                  title: "Not Enough Pictures",
                                  desc: "You need at least two pictures to create a collage.",
                                  buttons: [
                                    DialogButton(
                                      child: const Text(
                                        "OK",
                                        style: TextStyle(color: Colors.white, fontSize: 20),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                      color: Colors.teal,
                                    ),
                                  ],
                                ).show();
                              } else {
                                List<PictureModel> selectedPictures = pictures
                                    .where((picture) => selectedPictureIds.contains(picture.pictureId))
                                    .toList();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CollageCreator(
                                      selectedPictures: selectedPictures,
                                    ),
                                  ),
                                );

                                setState(() {
                                  isSelectMode = false;
                                  selectedPictureIds.clear();
                                });
                              }
                            } else {
                              setState(() {
                                isSelectMode = true;
                              });
                            }
                          },

                          child: Icon(
                            isSelectMode ? Icons.check : Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                CollageScreen(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  void _showFullScreenImage(BuildContext context, PictureModel picture, String heroTag) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.black87,
              child: Center(
                child: Hero(
                  tag: heroTag,
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.file(
                      File(picture.photoPath),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(_formatDate(picture.createdAt)),
                actions: [
                  if (picture.isCollage)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.grid_on),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
