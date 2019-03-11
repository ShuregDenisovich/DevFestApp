import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devfest_flutter_app/src/bloc/data/data_bloc.dart';
import 'package:devfest_flutter_app/src/bloc/events/event.dart';
import 'package:devfest_flutter_app/src/providers/bloc_provider.dart';
import 'package:devfest_flutter_app/src/resources/repository.dart';
import 'package:devfest_flutter_app/src/ui/screens/main/main_page.dart';
import 'package:devfest_flutter_app/src/bloc/auth/auth_bloc.dart';
import 'package:devfest_flutter_app/src/resources/abstracts/abstract_repositories.dart';
import 'package:devfest_flutter_app/src/resources/user_repository.dart';
import 'package:devfest_flutter_app/src/ui/screens/login/sign_in_page.dart';
import 'package:devfest_flutter_app/src/ui/screens/login/splash_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: MyApp(),
    );
  }
}

//TODO - remove old code
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'DevFest Gorky 2018',
        theme: new ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            fontFamily: "GoogleSans"),
        home: AppPage(
            userRepository:
                FirebaseUserRepository(FirebaseAuth.instance, GoogleSignIn())),
        //navigatorObservers: <NavigatorObserver>[observer],
        routes: <String, WidgetBuilder>{
          '/HomePage': (BuildContext context) => MainPage(),
          '/LoginPage': (BuildContext context) => SignInPage(),
          '/AppPage': (BuildContext context) => AppPage(),
        });
  }
}

class AppPage extends StatelessWidget{
  final UserRepository userRepository;
  AuthBloc _authenticationBloc;
  DataBloc _dataBloc;

  AppPage({Key key, @required this.userRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _authenticationBloc = AuthBloc(userRepository);
    return BlocProvider(
        child: MaterialApp(
            home: StreamBuilder(
                stream: _authenticationBloc.authStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SplashPage();
                  } else {
                    BlocEvent event = snapshot.data;
                    if (event is LoggingInEvent) {
                      return MainPage(user: _authenticationBloc.user);
                    }
                    if (event is LoggingOutEvent) {
                      return SignInPage();
                    }
                    return SplashPage();
                  }
                })),
        data: DataBloc(FirestoreRepository(Firestore.instance)),
        auth: _authenticationBloc);
  }

  @override
  void dispose() {

    _authenticationBloc.dispose();
    _dataBloc.dispose();
  }
}
