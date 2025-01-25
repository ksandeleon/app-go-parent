

import 'package:go_parent/services/database/local/helpers/baby_helper.dart';
import 'package:go_parent/services/database/local/helpers/user_helper.dart';

class ProfileBrain {
  final UserHelper userHelper;
  final BabyHelper babyHelper;

  ProfileBrain(this.userHelper, this.babyHelper);

}
