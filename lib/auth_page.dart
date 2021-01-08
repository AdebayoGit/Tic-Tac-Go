import 'package:flutter/material.dart';
import 'package:tic_tac_go_project/custom_widgets/constants.dart';
import 'package:tic_tac_go_project/blocs/auth_bloc.dart';
import 'package:tic_tac_go_project/blocs/bloc_provider.dart';
import 'package:tic_tac_go_project/blocs/user_bloc.dart';
import 'package:tic_tac_go_project/menu.dart';
import 'package:tic_tac_go_project/models/User.dart';
import 'package:tic_tac_go_project/models/Auth.dart';
import 'package:tic_tac_go_project/models/BlocCompleter.dart';
import 'package:tic_tac_go_project/models/Status.dart';
import 'package:tic_tac_go_project/services/auth_service.dart';
import 'package:tic_tac_go_project/utils/validator.dart';
import 'package:tic_tac_go_project/custom_widgets/logo_text.dart';
import 'package:tic_tac_go_project/custom_widgets/main_background.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthPage extends StatefulWidget {
  final bool signUp;
  AuthPage(this.signUp, {Key key}) : super(key: key);

  @override
  _AuthPageState createState() => new _AuthPageState();
}

class _AuthPageState extends State<AuthPage> implements BlocCompleter<User> {
  final _formKey = GlobalKey<FormState>();
  Validator _validator;
  BuildContext _context;

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  AuthBloc _authBloc;
  UserBloc _userBloc;

  bool signUp = false;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userBloc = BlocProvider.of<UserBloc>(context);
    _authBloc = AuthBloc(UserService(), this);
  }

  @override
  void initState() {
    super.initState();

    _validator = Validator();
    signUp = widget.signUp;
  }

  @override
  void dispose() {
    super.dispose();
    _authBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Builder(
        builder: (context) {
          _context = context;
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListView(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      LogoText(),
                      SizedBox(
                        height: 30.0,
                      ),
                      (signUp)
                          ? _authTextField(
                          controller: _usernameController,
                          hintText: 'john_doe',
                          labelText: 'Username',
                          //color: Colors.deepPurple,
                          prefixIcon: Icons.supervised_user_circle,
                          validator: _validator.usernameValidator)
                          : Container(),
                      SizedBox(
                        height: 20.0,
                      ),
                      _authTextField(
                          controller: _emailController,
                          hintText: 'email@example.com',
                          labelText: 'Email',
                          prefixIcon: Icons.email,
                          validator: _validator.emailValidator),
                      SizedBox(
                        height: 20.0,
                      ),
                      _authTextField(
                          controller: _passwordController,
                          hintText: 'password@123',
                          labelText: 'Password',
                          prefixIcon: Icons.lock,
                          obscureText: true,
                          validator: _validator.passwordValidator),
                      SizedBox(
                        height: 20.0,
                      ),
                      StreamBuilder(
                        initialData: LoadStatus.loaded,
                        stream: _authBloc.loadStatus,
                        builder: (context, snapshot) {
                          final loadStatus = snapshot.data;
                          return SizedBox(
                            width: double.infinity,
                            child: RaisedButton(
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: (loadStatus == LoadStatus.loading)
                                      ? CircularProgressIndicator()
                                      : Text(
                                    (signUp) ? 'SIGN UP' : 'LOGIN',
                                    style: TextStyle(
                                        fontSize: 22.0,
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                onPressed: (loadStatus == LoadStatus.loading)
                                    ? null
                                    : () {
                                  if (_formKey.currentState.validate()) {
                                    if (signUp) {
                                      _authBloc.signUp(
                                          _usernameController.text,
                                          _emailController.text,
                                          _passwordController.text);
                                    } else {
                                      _authBloc.login(
                                          _emailController.text,
                                          _passwordController.text);
                                    }
                                  }
                                }),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            (signUp)
                                ? 'Already registered?'
                                : 'Need to join ?',
                            style: TextStyle(fontSize: 20.0,
                                color: Colors.grey[850]),
                          ),
                          FlatButton(
                            child: Text(
                              (signUp) ? 'Login' : 'Sign Up',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 20.0,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                signUp = !signUp;
                              });
                            },
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      _socialLoginBox()
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  _socialLoginBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _socialIconButton(
            icon: FontAwesomeIcons.facebookF,
            color: Colors.blue[900],
            onTap: () {
              _authBloc.loginWithSocial(SocialLoginType.facebook);
            }),
        SizedBox(
          width: 10.0,
        ),
        _socialIconButton(
            icon: FontAwesomeIcons.googlePlusG,
            color: Colors.red,
            onTap: () {
              _authBloc.loginWithSocial(SocialLoginType.google);
            })
      ],
    );
  }

  _socialIconButton({IconData icon, Function onTap, Color color}) {
    return InkWell(
      child: CircleAvatar(
        backgroundColor: color,
        child: Icon(icon),
      ),
      onTap: onTap,
    );
  }

  _authTextField(
      {TextEditingController controller,
        String hintText,
        String labelText,
        Function validator,
        bool obscureText: false,
        IconData prefixIcon}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 22.0),
          labelText: labelText,
          labelStyle: TextStyle(color: primaryColor, fontSize: 23.0),
          prefixIcon: Icon(
            prefixIcon,
            color: Theme.of(context).hintColor,
          ),
          prefixStyle: TextStyle(color: Colors.red)),
      style: TextStyle(color: primaryColor, fontSize: 22.0),
    );
  }

  @override
  completed(user) {
    _userBloc.changeCurrentUser(user);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MenuPage()));
  }

  @override
  error(error) {
    Scaffold.of(_context).showSnackBar(SnackBar(
      content: Text('Error: ' + error.message),
    ));
  }
}
