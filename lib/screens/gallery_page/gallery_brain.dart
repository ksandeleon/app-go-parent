import 'package:go_parent/services/database/local/helpers/pictures_helper.dart';
import 'package:go_parent/services/database/local/models/pictures_model.dart';

class GalleryBrain {
  final PictureHelper pictureHelper;


  GalleryBrain(this.pictureHelper);

  Future<List<PictureModel>> getPicturesByUserId(int userId) async {
    return await pictureHelper.getPicturesByUserId(userId);
  }

}
