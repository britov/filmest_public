import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_create/generated/i18n.dart';
import 'package:flutter_create/model/model.dart';
import 'package:provider/provider.dart';

import 'main_screen.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black,
        child: StreamBuilder(
          stream: Stream.fromIterable([0, 1, 2]).asyncExpand((i) async* {
            switch (i) {
              case 0:
                yield i;
                break;
              case 1:
                await Future.delayed(const Duration(milliseconds: 900));
                yield i;
                break;
              case 2:
                await Future.delayed(const Duration(milliseconds: 1300));
                yield i;
                await Future.delayed(const Duration(milliseconds: 600));
                await Navigator.of(context)
                    .pushReplacement(CupertinoPageRoute(builder: (_) => MainPage(), fullscreenDialog: true));
                break;
            }
          }),
          builder: (context, snapshot) => AnimatedOpacity(
            opacity: snapshot.data == 1 ? 1 : 0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.bounceInOut,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Filmest', style: Theme.of(context).textTheme.headline3.copyWith(fontFamily: 'Oswald')),
                  Text(S.of(context).slashSubtitle,
                      style: Theme.of(context).textTheme.subtitle1.copyWith(fontFamily: 'Oswald')),
                  const SizedBox(height: 10),
                  Text('Used TMDB API', style: Theme.of(context).textTheme.subtitle1.copyWith(fontFamily: 'Oswald')),
                ],
              ),
            ),
          ),
        ),
      );
}
