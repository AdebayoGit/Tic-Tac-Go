import 'package:flutter/material.dart';
import 'package:tic_tac_go_project/blocs/game_bloc.dart';
import 'package:tic_tac_go_project/blocs/bloc_provider.dart';
import 'package:tic_tac_go_project/blocs/user_bloc.dart';
import 'package:tic_tac_go_project/menu.dart';
import 'package:tic_tac_go_project/services/game_service.dart';
import 'package:tic_tac_go_project/services/auth_service.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    UserService userService = UserService();
    return BlocProvider<UserBloc>(
      bloc: UserBloc(userService: userService),
      child: BlocProvider<GameBloc>(
        bloc: GameBloc(gameService: GameService(), userService: userService),
        child: MaterialApp(
          title: 'Tic Tac Go',
          home:MenuPage(),
        ),
      ),
    )


    ;
  }
}