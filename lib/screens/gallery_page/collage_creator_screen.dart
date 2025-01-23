import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_parent/screens/gallery_page/gallery_brain.dart';
import 'package:go_parent/services/database/local/helpers/collage_helper.dart';
import 'package:go_parent/services/database/local/helpers/collage_pictures_helper.dart';
import 'package:go_parent/services/database/local/helpers/pictures_helper.dart';
import 'package:go_parent/services/database/local/models/collage_model.dart';
import 'package:go_parent/services/database/local/models/pictures_model.dart';
import 'package:go_parent/services/database/local/sqlite.dart';
import 'package:go_parent/utilities/user_session.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class CollageCreator extends StatefulWidget {
  final List<PictureModel> selectedPictures;

  const CollageCreator({
    Key? key,
    required this.selectedPictures,
  }) : super(key: key);

  @override
  State<CollageCreator> createState() => _CollageCreatorState();
}

class _CollageCreatorState extends State<CollageCreator> {
  late List<PictureModel> pictures;
  late List<Alignment> imageAlignments;
  late List<double> imageScales;
  late List<bool> flipHorizontal;
  late List<bool> flipVertical;
  late final GalleryBrain _galleryBrain;
  Color selectedBackgroundColor = Colors.teal[200]!;
  int? selectedImageIndex;

  final GlobalKey _collageKey = GlobalKey();

final List<Color> backgroundColors = [
  Colors.teal[200]!,
  Colors.white,
  Colors.black,
  Color(0xffc6dbef),
  Color(0xffa2b5a5),
  Color(0xffffc700),
  Color(0xfffce4e1),
  Color(0xff87ceeb),
  Color(0xfff0f0e6),
  Color(0xffccccb3),
  Color(0xff800020),
  Color(0xff40e0d0),
];

  @override
  void initState() {
    super.initState();
    _initializeGalleryBrain();
    pictures = List.from(widget.selectedPictures);
    imageAlignments = List.generate(pictures.length, (index) => Alignment.center);
    imageScales = List.generate(pictures.length, (index) => 1.0);
    flipHorizontal = List.generate(pictures.length, (index) => false);
    flipVertical = List.generate(pictures.length, (index) => false);
  }


  Future<void> _initializeGalleryBrain() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dbService = DatabaseService.instance;
    final db = await dbService.database;
    final pictureHelper = PictureHelper(db);
    final collageHelper = CollageHelper(db);
    final collagePicturesHelper = CollagePicturesHelper(db);
    _galleryBrain = GalleryBrain(pictureHelper, collageHelper, collagePicturesHelper);
  }


Future<void> saveCollageAsImage(BuildContext context) async {
  try {
    RenderRepaintBoundary boundary =
    _collageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    // Capture the image as bytes
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final targetPath = Directory('${directory.path}/GoParentCollages');

    if (!await targetPath.exists()) {
      await targetPath.create();
    }

    String filePath =
        '${targetPath.path}/collage_${DateTime.now().millisecondsSinceEpoch}.png';

    File imgFile = File(filePath);
    await imgFile.writeAsBytes(pngBytes);

    TextEditingController titleController = TextEditingController();
    String? title = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter A Title'),
          content: TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: 'Enter Collage Title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(titleController.text);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    // If the user cancels, exit early
    if (title == null || title.isEmpty) return;

    CollageModel collage = CollageModel(
      userId: UserSession().userId!,
      title: title, // Use the entered title
      collageData: filePath,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    int result = await _galleryBrain.collageHelper.insertCollage(collage);

    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Collage saved successfully at $filePath')),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save collage. Please try again.')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}

Widget _buildImageTile(int index, int crossAxisCount, double mainAxisCount) {
    return StaggeredGridTile.count(
      crossAxisCellCount: crossAxisCount,
      mainAxisCellCount: mainAxisCount,
      child: GestureDetector(
        onTap: () => _showOptions(index),
        onLongPress: () => _showImageAdjustment(index),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scale(
                    flipHorizontal[index] ? -imageScales[index] : imageScales[index],
                    flipVertical[index] ? -imageScales[index] : imageScales[index],
                  ),
                child: Image.file(
                  File(pictures[index].photoPath),
                  fit: BoxFit.cover,
                  alignment: imageAlignments[index],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransformControls(int index, StateSetter setModalState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.zoom_out),
                onPressed: () {
                  setModalState(() {
                    imageScales[index] = (imageScales[index] - 0.1).clamp(0.5, 3.0);
                    setState(() {});
                  });
                },
              ),
              Expanded(
                child: Slider(
                  value: imageScales[index],
                  min: 0.5,
                  max: 3.0,
                  divisions: 25,
                  label: imageScales[index].toStringAsFixed(1),
                  onChanged: (value) {
                    setModalState(() {
                      imageScales[index] = value;
                      setState(() {});
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in),
                onPressed: () {
                  setModalState(() {
                    imageScales[index] = (imageScales[index] + 0.1).clamp(0.5, 3.0);
                    setState(() {});
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Flip controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFlipButton(
                icon: Icons.flip,
                label: 'Horizontal',
                isActive: flipHorizontal[index],
                onPressed: () {
                  setModalState(() {
                    flipHorizontal[index] = !flipHorizontal[index];
                    setState(() {});
                  });
                },
              ),
              _buildFlipButton(
                icon: Icons.flip,
                label: 'Vertical',
                isActive: flipVertical[index],
                rotateIcon: true,
                onPressed: () {
                  setModalState(() {
                    flipVertical[index] = !flipVertical[index];
                    setState(() {});
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlipButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
    bool rotateIcon = false,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.teal.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.teal : Colors.grey,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: rotateIcon ? 1.5708 : 0, // 90 degrees in radians if vertical
              child: Icon(
                icon,
                color: isActive ? Colors.teal : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.teal : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

void _showImageAdjustment(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Adjust Image',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTransformControls(index, setModalState),
                  const SizedBox(height: 16),
                  const Text(
                    'Long Press and Hold to Position Image',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.teal),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setModalState(() {
                            final currentAlignment = imageAlignments[index];
                            final dx = details.delta.dx / 100;
                            final dy = details.delta.dy / 100;
                            final newX = (currentAlignment.x + dx).clamp(-1.0, 1.0);
                            final newY = (currentAlignment.y + dy).clamp(-1.0, 1.0);
                            imageAlignments[index] = Alignment(newX, newY);
                            setState(() {});
                          });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..scale(
                                flipHorizontal[index] ? -imageScales[index] : imageScales[index],
                                flipVertical[index] ? -imageScales[index] : imageScales[index],
                              ),
                            child: Image.file(
                              File(pictures[index].photoPath),
                              fit: BoxFit.cover,
                              alignment: imageAlignments[index],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setModalState(() {
                            imageAlignments[index] = Alignment.center;
                            imageScales[index] = 1.0;
                            flipHorizontal[index] = false;
                            flipVertical[index] = false;
                            setState(() {});
                          });
                        },
                        child: const Text('Reset All'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showOptions(int index) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Image ${index + 1} Options',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOptionButton(
                      icon: Icons.swap_horiz,
                      label: 'Swap',
                      onTap: () {
                        Navigator.pop(context);
                        _showSwapOptions(index);
                      },
                    ),
                    _buildOptionButton(
                      icon: Icons.crop,
                      label: 'Adjust',
                      onTap: () {
                        Navigator.pop(context);
                        _showImageAdjustment(index);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

  Widget _buildOptionButton({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.teal),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      );
    }



  void _showSwapOptions(int tappedIndex) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Swap Image ${tappedIndex + 1}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pictures.length,
                  itemBuilder: (context, index) {
                    if (index == tappedIndex) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: () {
                        _swapImages(tappedIndex, index);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.teal,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                File(pictures[index].photoPath),
                                fit: BoxFit.cover,
                                height: 100,
                                width: 100,
                                alignment: imageAlignments[index],
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
              ),
            ],
          ),
        );
      },
    );
  }

  void _swapImages(int index1, int index2) {
    setState(() {
      // Swap both the images and their alignments
      final tempImage = pictures[index1];
      final tempAlignment = imageAlignments[index1];

      pictures[index1] = pictures[index2];
      imageAlignments[index1] = imageAlignments[index2];

      pictures[index2] = tempImage;
      imageAlignments[index2] = tempAlignment;
    });
  }

  List<Widget> _createCollageLayout() {
    final int photoCount = pictures.length;

    if (photoCount % 2 == 0) {
      return _createEvenLayout(photoCount);
    } else {
      return _createOddLayout(photoCount);
    }
  }

  List<Widget> _createEvenLayout(int count) {
    List<Widget> tiles = [];

    switch (count) {
      case 2:
        tiles = [
          _buildImageTile(0, 2, 3),
          _buildImageTile(1, 2, 3),
        ];
        break;

      case 4:
        for (int i = 0; i < 4; i++) {
          if (i == 0 || i == 2) {
            tiles.add(_buildImageTile(i, 2, 1.5));
            continue;
          }
          tiles.add(_buildImageTile(i, 2, 1));
        }
        break;

      case 6:
        for (int i = 0; i < 6; i++) {
          if (i == 1 || i == 4) {
            tiles.add(_buildImageTile(i, 2, 1.5));
            continue;
          }
          tiles.add(_buildImageTile(i, 2, 1));
        }
        break;

      default:
        throw Exception("Unsupported even count: $count");
    }

    return tiles;
  }

  List<Widget> _createOddLayout(int count) {
    List<Widget> tiles = [];

    switch (count) {
      case 3:
        tiles = [
          _buildImageTile(0, 2, 1.5),
          _buildImageTile(1, 2, 1.5),
          _buildImageTile(2, 4, 2),
        ];
        break;

      case 5:
        for (int i = 0; i < 5; i++) {
          if (i == 2) {
            tiles.add(_buildImageTile(i, 4, 1.5));
            continue;
          }
          tiles.add(_buildImageTile(i, 2, 1));
        }
        break;

      default:
        throw Exception("Unsupported odd count: $count");
    }

    return tiles;
  }

Widget _buildColorPicker() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Background',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          ...backgroundColors.map((color) => GestureDetector(
            onTap: () {
              setState(() {
                selectedBackgroundColor = color;
              });
            },
            child: Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectedBackgroundColor == color
                      ? Colors.teal
                      : Colors.grey[300]!,
                  width: selectedBackgroundColor == color ? 2 : 1,
                ),
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          tooltip: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create Collage', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        actions: [
          Tooltip(
            message: "Finish Creation",
            child: IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: () => saveCollageAsImage(context),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: RepaintBoundary(
                key: _collageKey,
                child: Container(
                  color: selectedBackgroundColor,
                  child: SizedBox(
                    width: 900,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StaggeredGrid.count(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: _createCollageLayout(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: (MediaQuery.of(context).size.height * 0.2) ,
            child: _buildColorPicker(),
          ),
        ],
      ),
    );
  }
}
