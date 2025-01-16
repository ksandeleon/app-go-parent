import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_parent/screens/gallery_page/collage_screen.dart';
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

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});
  static String id = "gallery_screen";

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final userId = UserSession().userId;
  late  GalleryBrain galleryBrain;
  List<PictureModel> pictures = [];
  List<CollageModel> collages = [];

  bool isLoading = true;
  bool isSelectMode = false;
  Set<int> selectedPictureIds = {};

  @override
  void initState() {
    super.initState();
    _initializeGalleryBrain().then((_) {
     _loadCollages();
    });
    

    //final collageScreen = CollageScreen();

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

  void _loadCollages() async {
  setState(() {
    isLoading = true;
  });

  // Use galleryBrain.collageHelper instead of context.read
  final retrievedCollages = await galleryBrain.collageHelper.getAllCollages();
  setState(() {
    collages = retrievedCollages;
    isLoading = false;
  });
}

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';
    return DateFormat('MMM d, y').format(date);
  }


  Future<void> _createCollage() async {
    if (selectedPictureIds.isEmpty) return;

    final titleController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Collage'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Collage Title',
            hintText: 'Enter a title for your collage',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );


  if (result == true && titleController.text.isNotEmpty) {
    try {
      // Create collage data
      final collageData = {
        'layout': 'grid', // You can make this configurable
        'selectedPictures': selectedPictureIds.toList(),
      };

    final collageId = await galleryBrain.collageHelper.insertCollage(
        CollageModel(
          userId: userId!,
          title: titleController.text,
          collageData: jsonEncode(collageData),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now()
        ),
      );

    // Insert collage pictures using CollagePicturesHelper
    final collagePictures = selectedPictureIds.map((pictureId) => {
      'collageId': collageId,
      'pictureId': pictureId,
    }).toList();

    await galleryBrain.collagePicturesHelper.insertCollagePictures(collagePictures);


      // Exit select mode and clear selections
      setState(() {
        isSelectMode = false;
        selectedPictureIds.clear();
      });

      // Exit select mode and clear selections
      setState(() {
        isSelectMode = false;
        selectedPictureIds.clear();
      });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Collage created successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating collage: $e')),
        );
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pictures.isEmpty) {
      return const Center(child: Text('No pictures found'));
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 8,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
        title: const Text(
          'Go Gallery',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
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
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white38,
            elevation: 0,
            bottom: const TabBar(
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              tabs: [
                Tab(text: 'Joyful Pictures', icon: Icon(Icons.image)),
                Tab(text: 'Memory Collage', icon: Icon(Icons.grid_on)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Stack(
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

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 2,
                      child: InkWell(
                        onTap: () => _showFullScreenImage(context, picture, heroTag),
                        child: Column(
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
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        picture.isCollage ? Icons.grid_on : Icons.image,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        picture.isCollage ? 'Collage' : 'Single Image',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(picture.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Mission ID: ${picture.userMissionId}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
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
                      message: "Create a new collage",
                      child: FloatingActionButton(
                        backgroundColor: Colors.teal,
                        onPressed: () {
                          if (isSelectMode) {
                            if (selectedPictureIds.isNotEmpty) {
                              _createCollage();
                            }
                          } else {
                            setState(() {
                              isSelectMode = true;
                            });
                          }
                        },


                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                ],
              ),

              //secondpage here <= place to operate collages
              CollageScreen()

            ],
          ),
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
