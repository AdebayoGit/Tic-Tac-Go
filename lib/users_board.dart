import 'package:flutter/material.dart';
import 'package:tic_tac_go_project/auth_page.dart';
import 'package:tic_tac_go_project/custom_widgets/main_background.dart';
import 'package:tic_tac_go_project/blocs/bloc_provider.dart';
import 'package:tic_tac_go_project/blocs/game_bloc.dart';
import 'package:tic_tac_go_project/blocs/user_bloc.dart';
import 'package:tic_tac_go_project/game_process.dart';
import 'package:tic_tac_go_project/models/User.dart';
import 'package:tic_tac_go_project/models/game.dart';
import 'package:tic_tac_go_project/custom_widgets/constants.dart';
import 'package:tic_tac_go_project/utils/user_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UsersBoard extends StatefulWidget {
  UsersBoard({Key key}) : super(key: key);

  @override
  _UsersBoardState createState() => new _UsersBoardState();
}

class _UsersBoardState extends State<UsersBoard> {

  UserBloc _userBloc;
  GameBloc _gameBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userBloc = BlocProvider.of<UserBloc>(context);
    _gameBloc = BlocProvider.of<GameBloc>(context);

  }

  @override
  Widget build(BuildContext context) {


    return StreamBuilder<User>(
        stream: _userBloc.currentUser,
        builder: (context, currentUserSnapshot) {
          return Background(
            child: Scaffold(
              appBar: AppBar(
                title: Text('Tic Tac Toe users'),
                backgroundColor: primaryColor,
              ),
              body: StreamBuilder(
                initialData: [],
                stream: _userBloc.users,
                builder: (context, usersSnapshot){
                  return ListView.builder(
                      itemCount: usersSnapshot.data.length,
                      itemBuilder: (context, index,){
                        return _userTile(usersSnapshot.data[index], currentUserSnapshot.data);
                      });
                },
              ),
            ),
          );

        }
    );
  }


  _userTile(User user, User currentUser){

    return InkWell(
      highlightColor: Colors.grey[850],
      child: ListTile(leading: CircleAvatar(
        backgroundColor: Colors.grey.shade800,
        child: Text(user.name.substring(0,1).toUpperCase()),
      ),
        title: Text(user.name, style: TextStyle(color: Colors.black87, fontSize: 23.0),),
        trailing: _userStateDisplay(user.currentState),
      ),
      onTap: (){

        if(user.currentState == UserState.available){
          _showSendChallengeDialog(user, currentUser);
        }else{
          _showCantPlayDialog(user);
        }

      },
    );
  }

  _userStateDisplay(UserState userState){

    switch (userState) {
      case UserState.playing:
        return Icon(FontAwesomeIcons.gamepad, color: Colors.green,);
        break;
      case UserState.away:
        return _userStateCircle(Colors.amber);
        break;
      case UserState.available:
        return _userStateCircle(Colors.green);
        break;
      case UserState.offline:
      default:
        return _userStateCircle(Colors.grey);

    }
  }

  _userStateCircle(Color color){
    return CircleAvatar(
      backgroundColor: color,
      radius: 10.0,
    );
  }

  _showSendChallengeDialog(User user, User currentUser){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Challenge'),
        content: Text('Do you want to challenge '+user.name),
        actions: <Widget>[
          FlatButton(
            child: Text('CHALLENGE'),
            onPressed: () async{
              if(currentUser != null){
                _gameBloc.handleChallenge(user, ChallengeHandleType.challenge);
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => GameProcessPage()));
              }else{
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (index) => AuthPage(false)));
              }
            },
          ),
          FlatButton(
            child: Text('DECLINE'),
            onPressed: (){
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  _showCantPlayDialog(User user){
    UserUtil userUtil = UserUtil();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Can't Play"),
        content: Text("Can't play with "+user.name+", user is currently "+userUtil.getStringFromState(user.currentState) ),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () async{
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}