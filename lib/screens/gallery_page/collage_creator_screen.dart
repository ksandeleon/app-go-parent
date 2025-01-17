

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



List<StaggeredGridTile> _createEvenLayout(List<Widget> images, int count) {
  List<StaggeredGridTile> tiles = [];

  switch (count) {
    case 2:
      tiles = [
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 3,
          child: images[0],
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 3,
          child: images[1],
        ),
      ];
      break;

    case 4:
      for (int i = 0; i < 4; i++) {

        if (i == 0 || i == 2) {
          tiles.add(
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 1.5,
            child: images[i],
          ),
        );
        continue;
        }
        tiles.add(
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 1,
            child: images[i],
          ),
        );
      }
      break;

    case 6:
      for (int i = 0; i < 6; i++) {

        if (i == 1 || i == 4) {
          tiles.add(
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 1.5,
            child: images[i],
          ),
        );
        continue;
        }

        tiles.add(
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 1,
            child: images[i],
          ),
        );
      }
      break;

    default:
      throw Exception("Unsupported even count: $count");
  }

  return tiles;
}

List<StaggeredGridTile> _createOddLayout(List<Widget> images, int count) {
  List<StaggeredGridTile> tiles = [];

  switch (count) {
    case 3:
      tiles = [
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 1.5,
          child: images[0],
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 1.5,
          child: images[1],
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 4,
          mainAxisCellCount: 2,
          child: images[2],
        ),
      ];
      break;

    case 5:
      for (int i = 0; i < 5; i++) {

        if (i == 2) {
          tiles.add(
          StaggeredGridTile.count(
            crossAxisCellCount: 4,
            mainAxisCellCount: 1.5,
            child: images[i],
          ),
        );
        continue;
        }

        tiles.add(
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 1,
            child: images[i],
          ),
        );
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
        title: const Text('Create Collage', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        actions: [
          Tooltip(
            message: "Finish Creation",
            child: IconButton(
              icon: const Icon(Icons.check, color: Colors.white,),
              onPressed: () {
                // TODO: Implement save collage functionality
                // This is where you'll save the collage and add it to your database
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
              children: collageLayout,
            ), 
          ),
        ),
      ),
    );
  }
}
