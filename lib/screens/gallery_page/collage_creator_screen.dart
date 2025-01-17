import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_parent/services/database/local/models/pictures_model.dart';

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
  int? selectedImageIndex;

  @override
  void initState() {
    super.initState();
    pictures = List.from(widget.selectedPictures);
    imageAlignments = List.generate(
      pictures.length,
      (index) => Alignment.center,
    );
  }

Widget _buildImageTile(int index, int crossAxisCount, double mainAxisCount) {
    return StaggeredGridTile.count(
      crossAxisCellCount: crossAxisCount,
      mainAxisCellCount: mainAxisCount,
      child: GestureDetector(
        onTap: () => _showOptions(index),
        // Add long press to directly enter adjustment mode
        onLongPress: () => _showImageAdjustment(index),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(pictures[index].photoPath),
                fit: BoxFit.cover,
                alignment: imageAlignments[index],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
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
                    'Adjust Image Position',
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
                          // Convert the drag into alignment values
                          setModalState(() {
                            final currentAlignment = imageAlignments[index];
                            final dx = details.delta.dx / 100;
                            final dy = details.delta.dy / 100;

                            // Ensure alignment stays within bounds (-1 to 1)
                            final newX = (currentAlignment.x + dx).clamp(-1.0, 1.0);
                            final newY = (currentAlignment.y + dy).clamp(-1.0, 1.0);

                            imageAlignments[index] = Alignment(newX, newY);

                            // Update the main state as well
                            setState(() {});
                          });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(pictures[index].photoPath),
                            fit: BoxFit.cover,
                            alignment: imageAlignments[index],
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
                            setState(() {});
                          });
                        },
                        child: const Text('Reset Position'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: const Text('Create Collage', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        actions: [
          Tooltip(
            message: "Finish Creation",
            child: IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: () {
                // TODO: Implement save collage functionality
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            height: 900,
            width: 900,
            child: StaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: _createCollageLayout(),
            ),
          ),
        ),
      ),
    );
  }
}
