import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:game_poker/core/app_size.dart';
import 'package:game_poker/data/services/data_manager.dart';
import 'package:game_poker/test/data.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final DataManager _dataManager = DataManager();
  final TextEditingController _user = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  bool _obscuretext = true;
  String _errorMessage = '';
  bool isLogin = false;

  Future<void> _handleAuth() async {
    final username = _user.text.trim();
    final password = _pass.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Please fill all fields";
      });
      return;
    }

    setState(() {
      _errorMessage = '';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    // Find user by username
    final userByName = testUsers.where((p) => p.name == username).toList();
    bool success = false;

    if (isLogin) {
      if (userByName.isEmpty) {
        setState(() {
          _errorMessage = 'User not found';
        });
        return;
      }

      // Check if password matches
      final userByPass = testUsers
          .where((p) => p.name == username && p.pass == password)
          .toList();

      if (userByPass.isEmpty) {
        setState(() {
          _errorMessage = 'Incorrect password';
        });
        return;
      }

      // Login successful
      success = _dataManager.login(username, password);
    } else {
      // Registration: username must not exist
      if (userByName.isNotEmpty) {
        setState(() {
          _errorMessage = 'Username already exists';
        });
        return;
      }

      // Register new user
      success = true;
    }

    if (success) {
      print('Success!');
      print('Username: $username');
      print('Password: $password');
    }

    // Optionally reset isLogin
    setState(() {
      isLogin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            // image background
            SizedBox(
              width: double.infinity,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Image.asset("assets/login.webp", fit: BoxFit.cover),
              ),
            ),
            // color blur
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.8)),
            ),
            // logo
            Positioned(
              left: 0,
              top: 0,
              child: SizedBox(
                width: 100,
                child: Image.asset('assets/logo.png'),
              ),
            ),
            // sign up
            Positioned(
              left: 20,
              right: 0,
              top: MediaQuery.of(context).size.height * 0.1,
              child: Text(
                "Sign in to your Account",
                style: TextStyle(
                  letterSpacing: 2,
                  height: 1,
                  fontSize: MediaQuery.of(context).size.width * 0.11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // don't have account
            Positioned(
              left: 20,
              right: 0,
              top: MediaQuery.of(context).size.height * 0.21,
              child: Row(
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      height: 1,
                      fontSize: MediaQuery.of(context).size.width * 0.03,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      height: 2,
                      fontSize: MediaQuery.of(context).size.width * 0.03,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue[800],
                      decorationThickness: 2,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
            ),
            // login
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: AppSize.heigth(context) * 0.7,
                decoration: BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.width(context) * 0.08,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _text(context, 'Email'),
                      SizedBox(height: 10),
                      _inputText(context, _user),
                      SizedBox(height: 40),
                      _text(context, 'Password'),
                      SizedBox(height: 10),
                      _inputPassword(context, _pass),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: EdgeInsetsGeometry.all(20),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(height: 70),
                      _btn(context, _handleAuth),
                      SizedBox(height: 40),
                      _textOrLogin(),
                      SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: _btnLoginWith('Google', 'assets/google.png'),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: _btnLoginWith(
                              'Facebook',
                              'assets/facebook.png',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btnLoginWith(String text, String image) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {},
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image),
            SizedBox(width: 5),
            Text(text, style: TextStyle(color: Colors.black, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Center _textOrLogin() {
    return Center(
      child: Text(
        "Or login with",
        style: TextStyle(fontSize: 15, color: Color(0xff6C7278)),
      ),
    );
  }

  Widget _btn(BuildContext context, VoidCallback callback) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: callback,
        child: Text(
          "Log In",
          style: TextStyle(
            fontSize: AppSize.width(context) * 0.04,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _inputText(BuildContext context, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: AppSize.width(context) * 0.04,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: 'example@gmail.com',
        hintStyle: TextStyle(
          fontSize: AppSize.width(context) * 0.04,
          color: Colors.grey,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _inputPassword(
    BuildContext context,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      obscureText: _obscuretext,
      style: TextStyle(
        fontSize: AppSize.width(context) * 0.04,
        color: Colors.black,
      ),

      decoration: InputDecoration(
        hintText: '*******',
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscuretext = !_obscuretext;
            });
          },
          icon: !_obscuretext
              ? Icon(Icons.visibility_rounded)
              : Icon(Icons.visibility_off),
        ),
        hintStyle: TextStyle(
          fontSize: AppSize.width(context) * 0.04,
          color: Colors.grey,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _text(BuildContext context, text) {
    return Text(
      text,
      style: TextStyle(
        color: Color(0xff6C7278),
        fontSize: AppSize.width(context) * 0.04,
      ),
    );
  }
}
