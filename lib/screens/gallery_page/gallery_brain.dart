import 'package:go_parent/services/database/local/helpers/collage_helper.dart';
import 'package:go_parent/services/database/local/helpers/collage_pictures_helper.dart';
import 'package:go_parent/services/database/local/helpers/pictures_helper.dart';
import 'package:go_parent/services/database/local/models/colllage_pictures_model.dart';
import 'package:go_parent/services/database/local/models/pictures_model.dart';

class GalleryBrain {
  final PictureHelper pictureHelper;
  final CollageHelper collageHelper;
  final CollagePicturesHelper collagePicturesHelper;


  GalleryBrain(this.pictureHelper, this.collageHelper, this.collagePicturesHelper); 

  Future<List<PictureModel>> getPicturesByUserId(int userId) async {
    return await pictureHelper.getPicturesByUserId(userId);
  }

}
