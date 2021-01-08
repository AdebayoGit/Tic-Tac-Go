import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tic_tac_go_project/custom_widgets/constants.dart';
import 'package:tic_tac_go_project/auth_page.dart';
//import 'package:flutter_firebase_tic_tac_toe/auth/login.dart';
import 'package:tic_tac_go_project/blocs/bloc_provider.dart';
import 'package:tic_tac_go_project/blocs/game_bloc.dart';
import 'package:tic_tac_go_project/blocs/auth_bloc.dart';
import 'package:tic_tac_go_project/blocs/user_bloc.dart';
import 'package:tic_tac_go_project/game_board.dart';
import 'package:tic_tac_go_project/game_process.dart';
import 'package:tic_tac_go_project/highscores.dart';
import 'package:tic_tac_go_project/models/User.dart';
import 'package:tic_tac_go_project/models/game.dart';
import 'package:tic_tac_go_project/users_board.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tic_tac_go_project/custom_widgets/rounded_button.dart';
import 'package:tic_tac_go_project/custom_widgets/main_background.dart';



class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  UserBloc _userBloc;
  GameBloc _gameBloc;
  FirebaseMessaging _messaging = new FirebaseMessaging();

  AnimationController _animationController;
  List<Animation<double>> _menuButtonSlides;


  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _userBloc = BlocProvider.of<UserBloc>(context);
    _gameBloc = BlocProvider.of<GameBloc>(context);
  }

  @override
  void initState() {
    super.initState();

    _animationController = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));

    _menuButtonSlides = [];
    for (int i = 0; i < 4; i++) {
      _menuButtonSlides.add(Tween<double>(begin: -1.0, end: 0.0).animate(
          CurvedAnimation(
              parent: _animationController,
              curve: Interval(i / 3, 1.0, curve: Curves.easeIn))));
    }

    _animationController.forward();

    // ignore: missing_return
    _messaging.configure(onLaunch: (Map<String, dynamic> message) {
      print('ON LAUNCH ----------------------------');
      print(message);
      // ignore: missing_return
    }, onMessage: (Map<String, dynamic> message) {
      String notificationType = message['data']['notificationType'];

      switch (notificationType) {
        case 'challenge':
          User challenger = User(id: message['data']['senderId'], name:  message['data']['senderName'],  fcmToken: message['data']['senderFcmToken']);
          _showAcceptanceDialog(challenger);
          break;
        case 'started':
          _gameBloc.startServerGame(
              message['data']['player1Id'], message['data']['player2Id']);
          break;
        case 'replayGame':
          _gameBloc.changeGameOver(false);
          break;
        case 'rejected':
          _showGameRejectedDialog(message);
          break;
        case 'gameEnd':
          _gameBloc.clearProcessDetails();
          _showGameEndDialog(message);
          break;
        default:
          print('message');
          break;
      }
      // ignore: missing_return
    }, onResume: (Map<String, dynamic> message) {
      // _showAcceptanceDialog(message);
      print('ON RESUME ----------------------------');
      print(message);
      String notificationType = message['notificationType'];
      switch (notificationType) {
        case 'challenge':
          User challenger = User(id: message['senderId'], name:  message['senderName'],  fcmToken:  message['senderFcmToken']);
          _showAcceptanceDialog(challenger);
          break;
        case 'started':
          _gameBloc.startServerGame(message['player1Id'], message['player2Id']);
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => GameProcessPage()));
          break;
        case 'gameEnd':
          _gameBloc.clearProcessDetails();
          break;
      }
    });

    _messaging.getToken().then((token) {
      print('------------------');
      print(token);
      _userBloc.changeFcmToken(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //precacheImage(AssetImage("assets/chat.png"), context);
    return MaterialApp(
        home: new Background(
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Tic Tac Go",
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = ui.Gradient.linear(
                                const Offset(0, 20),
                                const Offset(150, 200),
                                <Color>[
                                  Color(0xFF6F35A5),
                                  Color(0xFFF1E6FF),
                                ],
                              )
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),
                      Image.asset(
                        "assets/chat.png",
                        height: size.height * 0.4,
                      ),
                      SizedBox(height: size.height * 0.01),
                      StreamBuilder(
                        initialData: null,
                        stream: _userBloc.currentUser,
                        builder: (context, currentUserSnapshot) {
                          if (!currentUserSnapshot.hasData) {
                            return Container();
                          }
                          User currentUser = currentUserSnapshot.data;
                          return (currentUser != null)
                              ? Text('currentUser - ' + currentUser.name)
                              : Container();
                        },
                      ),
                      SizedBox(height: size.height * 0.01),
                      RoundedButton(
                        text: 'PLAY WITH COMPUTER',
                        //animation: _menuButtonSlides[0],
                        press: () {
                          _gameBloc.startSingleDeviceGame(GameType.computer);
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (index) => GameBoard()));
                        },
                      ),
                      RoundedButton(
                        text: 'PLAY WITH FRIEND',
                        //animation: _menuButtonSlides[1],
                        color: primaryLightColor,
                        textColor: Colors.black,
                        press: () {
                          _gameBloc.startSingleDeviceGame(GameType.multi_device);
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (index) => GameBoard()));
                        },
                      ),
                      RoundedButton(
                        text: 'PLAY WITH USERS',
                        //animation: _menuButtonSlides[2],
                        press: () {
                          _userBloc.getUsers();
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (index) => UsersBoard()));
                        },
                      ),
                      RoundedButton(
                        text: 'HIGH SCORE',
                        //animation: _menuButtonSlides[3],
                        color: primaryLightColor,
                        textColor: Colors.black,
                        press: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (index) => HighScoreBoard()));
                        },
                      ),
                      StreamBuilder(
                        initialData: null,
                        stream: _userBloc.currentUser,
                        builder: (context, currentUserSnapshot) {
                          if (currentUserSnapshot.hasData &&
                              currentUserSnapshot.data != null) {
                            return FlatButton(
                              child: Text(
                                'Logout',
                                style: TextStyle(fontSize: 18.0, color: primaryColor),
                              ),
                              onPressed: () {
                                _userBloc.logoutUser();
                              },
                            );
                          } else {
                            return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Play with Others?',
                                    style: TextStyle(fontSize: 18.0, color: Colors.grey[850]),
                                  ),
                                  FlatButton(
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(
                                          fontSize: 18.0, color: primaryColor),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (index) => AuthPage(false)));
                                    },
                                  )
                                ]);
                          }
                        },
                      ),

                    ]
                )
            )
        )
    );
  }

  _showGameEndDialog(Map<String, dynamic> message) async {
    Future.delayed(Duration.zero, () {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Game Ended!'),
          content: Text(message['notification']['body']), // get from server

          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MenuPage()));
              },
            ),
          ],
        ),
      );
    });
  }

  _showGameRejectedDialog(Map<String, dynamic> message) async {
    Future.delayed(Duration.zero, () {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Game Rejected!'),
          content: Text(message['notification']['body']), // get from server

          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MenuPage()));
              },
            ),
          ],
        ),
      );
    });
  }

  _showAcceptanceDialog(User challenger) async {

    Future.delayed(Duration.zero, () {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => StreamBuilder<User>(
          stream: _userBloc.currentUser,
          builder: (context, currentUserSnapshot){

            return AlertDialog(
              title: Text('Tic Tac Toe Challeenge'),
              content: Text(challenger.name +
                  ' has Challenged you to a game of tic tac toe'),
              actions: <Widget>[
                FlatButton(
                  child: Text('ACCEPT'),
                  onPressed: () async {
                    _gameBloc.handleChallenge(
                        challenger,
                        ChallengeHandleType.accept);
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => GameProcessPage()));
                  },
                ),
                FlatButton(
                  child: Text('DECLINE'),
                  onPressed: () {
                    _gameBloc.handleChallenge(
                        challenger,
                        ChallengeHandleType.reject);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          },


        ),
      );
    });
  }

}
