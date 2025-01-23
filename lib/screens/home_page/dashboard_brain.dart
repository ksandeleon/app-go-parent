import 'package:go_parent/services/database/local/helpers/pictures_helper.dart';
import 'package:go_parent/services/database/local/helpers/baby_helper.dart';
import 'package:go_parent/services/database/local/helpers/user_helper.dart';

class DashboardBrain {
  final UserHelper userHelper;
  final BabyHelper babyHelper;
  final PictureHelper pictureHelper;

  DashboardBrain(this.userHelper, this.babyHelper, this.pictureHelper);


}
