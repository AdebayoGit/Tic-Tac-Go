class Validator{

  String usernameValidator(String username){
    if(username.isEmpty){
      return 'Username is required';
    }else if(username.length < 5){
      return 'Username should be five characters or more';
    }

    return null;
  }

  String emailValidator(String email){

    if(email.isEmpty){
      return 'Email is required';
    }

    return null;
  }

  String passwordValidator(String password){
    if(password.isEmpty){
      return 'Password is required';
    }

    return null;
  }
}