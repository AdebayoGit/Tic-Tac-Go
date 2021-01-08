import 'package:tic_tac_go_project/models/User.dart';

class ScoreDetail{


  final User user;
  final int wins;
  final int losses;
  final bool wonLast;

  ScoreDetail({this.user, this.wins, this.losses, this.wonLast});
}