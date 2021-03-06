import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tic_tac_go_project/blocs/bloc_provider.dart';
import 'package:tic_tac_go_project/models/User.dart';
import 'package:tic_tac_go_project/models/Score.dart';
import 'package:rxdart/rxdart.dart';

class HighScoreBloc extends BlocBase{

  final _highscores  = BehaviorSubject<List<ScoreDetail>>(seedValue:  []);
  final _fetchHighScores = BehaviorSubject<Null>();


  Function() get fetchHighScores => () => _fetchHighScores.sink.add(null);


  Stream<List<ScoreDetail>> get highScores => _highscores.stream;


  HighScoreBloc(){
    _fetchHighScores.stream.listen(_handleFetchHighScores);
  }

  _handleFetchHighScores(_){
    List<ScoreDetail> highScores = [];
    Firestore.instance.collection('scores').
    orderBy('wins', descending: true).limit(10).snapshots().listen((scoreSnapshot) async{

      if(scoreSnapshot.documents.isNotEmpty){
        for(int i = 0 ; i < scoreSnapshot.documents.length; i++){
          DocumentSnapshot userDoc =  await Firestore.instance.collection('users').document(scoreSnapshot.documents[i].documentID).get();
          final userDetails = userDoc.data;
          final scoreDetails = scoreSnapshot.documents[i].data;
          highScores.add(ScoreDetail(user: User(id: userDoc.documentID, name: userDetails['displayName']), losses: scoreDetails['losses'], wins: scoreDetails['wins'], wonLast: scoreDetails['wonLast']));
        }
        _highscores.sink.add(highScores);
      }
    })..onError((err){
      print(err);
    });
  }


  @override
  void dispose() {
    _highscores.close();
    _fetchHighScores.close();
  }

}