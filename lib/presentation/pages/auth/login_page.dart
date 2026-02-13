import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_poker/core/app_size.dart';
import 'package:game_poker/data/services/data_manager.dart';
import 'package:game_poker/presentation/pages/home/main_menu_page.dart';

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

    // check all text field is not empty
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Please complete all required fields.";
      });
      return;
    }

    setState(() {
      isLogin = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final success = await _dataManager.login(username, password);
      // check email and pass is worry
      if (!success) {
        setState(() {
          _errorMessage = "The email or password you entered is invalid.";
        });
      }

      if (!mounted) {
        return;
      }
      // true work
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainMenuPage()),
        );
      }
    } catch (_) {
      // false work
      setState(() {
        isLogin = false;
      });
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
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
              child: SafeArea(
                child: SizedBox(
                  width: 100,
                  child: Image.asset('assets/logo.png'),
                ),
              ),
            ),
            // sign up
            Positioned(
              left: 20,
              right: 0,
              top: MediaQuery.of(context).size.height * 0.15,
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
              top: MediaQuery.of(context).size.height * 0.25,
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.width(context) * 0.08,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 50),
                        _text(context, 'Name'),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
        hintText: 'Username',
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
