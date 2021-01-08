import 'package:tic_tac_go_project/models/User.dart';
import 'package:tic_tac_go_project/models/GamePiece.dart';

class Player{

  final User user;
  final GamePiece gamePiece;
  final int score;

  Player({this.user, this.gamePiece, this.score});

  Player copyWith({User user, GamePiece gamePiece, int score}){

    return Player(
        user: user ?? this.user,
        gamePiece:  gamePiece ?? this.gamePiece,
        score:  score ?? this.score
    );
  }
}