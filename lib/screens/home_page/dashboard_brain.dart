import 'package:go_parent/services/database/local/helpers/pictures_helper.dart';
import 'package:go_parent/services/database/local/helpers/baby_helper.dart';
import 'package:go_parent/services/database/local/helpers/user_helper.dart';
import 'package:go_parent/services/database/local/helpers/user_mission_helper.dart';
import 'package:go_parent/services/database/local/models/missions_model.dart';
import 'package:go_parent/services/database/local/sqlite.dart';

class DashboardBrain {
  final UserHelper userHelper;
  final BabyHelper babyHelper;
  final PictureHelper pictureHelper;
  final UserMissionHelper userMissionHelper;

  DashboardBrain(this.userHelper, this.babyHelper, this.pictureHelper, this.userMissionHelper);


}
