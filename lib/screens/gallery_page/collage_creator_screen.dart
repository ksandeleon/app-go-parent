

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
  late List<Widget> collageLayout;

  @override
  void initState() {
    super.initState();
    collageLayout = _createCollageLayout();
  }

  List<Widget> _createCollageLayout() {
    final int photoCount = widget.selectedPictures.length;

    // Create image widgets from the selected pictures
    List<Widget> imageWidgets = widget.selectedPictures.map((picture) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(picture.photoPath),
          fit: BoxFit.cover,
        ),
      );
    }).toList();

    if (photoCount % 2 == 0) {
      // Even number of photos
      return _createEvenLayout(imageWidgets, photoCount);
    } else {
      // Odd number of photos
      return _createOddLayout(imageWidgets, photoCount);
    }
  }

  List<Widget> _createEvenLayout(List<Widget> images, int count) {
    List<StaggeredGridTile> tiles = [];

    switch (count) {
      case 2:
        // 1x2 grid
        tiles = [
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 2,
            child: images[0],
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 2,
            child: images[1],
          ),
        ];
        break;

      case 4:
        // 2x2 grid
        for (int i = 0; i < 4; i++) {
          tiles.add(
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: images[i],
            ),
          );
        }
        break;

      case 6:
        // 2x3 grid
        for (int i = 0; i < 6; i++) {
          tiles.add(
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: images[i],
            ),
          );
        }
        break;

      case 8:
        // 3x3 grid (with center empty)
        for (int i = 0; i < 8; i++) {
          if (i == 4) continue; // Skip center tile
          tiles.add(
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: images[i],
            ),
          );
        }
        break;
    }

    return tiles;
  }

  List<Widget> _createOddLayout(List<Widget> images, int count) {
    List<StaggeredGridTile> tiles = [];

    switch (count) {
      case 3:
        // One large + two small
        tiles = [
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 2,
            child: images[0],
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: images[1],
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: images[2],
          ),
        ];
        break;

      case 5:
        // One large + four small
        tiles = [
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 2,
            child: images[0],
          ),
          ...List.generate(4, (index) =>
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: images[index + 1],
            ),
          ),
        ];
        break;

      case 7:
        // One large center + six around
        tiles = [
          // Center large image
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 2,
            child: images[0],
          ),
          // Top row
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: images[1],
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: images[2],
          ),
          // Middle row (sides)
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: images[3],
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: images[4],
          ),
          // Bottom row
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: images[5],
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: images[6],
          ),
        ];
        break;
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Collage'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // TODO: Implement save collage functionality
              // This is where you'll save the collage and add it to your database
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: collageLayout,
        ),
      ),
    );
  }
}
