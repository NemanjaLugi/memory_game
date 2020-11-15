import 'dart:async';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:memory_card/config.dart';

import '../app.dart';

class GamePage extends StatefulWidget {
  final int size;

  const GamePage({Key key, this.size = 16}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<GlobalKey<FlipCardState>> cardStateKeys = [];
  List<bool> cardFlips = [];
  List<String> data = [];
  int previousIndex = -1;
  bool flip = false;

  int time = 60;
  Timer timer;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.size; i++) {
      cardStateKeys.add(GlobalKey<FlipCardState>());
      cardFlips.add(true);
    }
    for (var i = 0; i < widget.size ~/ 2; i++) {
      data.add(i.toString());
    }
    for (var i = 0; i < widget.size ~/ 2; i++) {
      data.add(i.toString());
    }
    _startTimer();
    data.shuffle();
  }

  _startTimer() {
    const oneSec = const Duration(seconds: 1);
    timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (time < 1) {
            timer.cancel();
            _showResult(false);
          } else {
            time = time - 1;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.appTitle),
        backgroundColor: AppColors.green.withOpacity(0.8),
      ),
      body: SafeArea(
          child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/background-img.png'),
                    fit: BoxFit.cover)),
          ),
          Align(
            alignment: Alignment.center,
            child: _buildCardGrid(),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _buildCounter(context),
          )
        ],
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.green.withOpacity(0.8),
        child: Icon(
          Icons.exit_to_app_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false);
        },
      ),
    );
  }

  Padding _buildCounter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 60.0),
      child: Text(
        "$time",
        style: Theme.of(context).textTheme.headline2,
      ),
    );
  }

  Theme _buildCardGrid() {
    return Theme(
      data: ThemeData.dark(),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
          itemBuilder: (context, index) => FlipCard(
            key: cardStateKeys[index],
            onFlip: () {
              if (!flip) {
                flip = true;
                previousIndex = index;
              } else {
                flip = false;
                if (previousIndex != index) {
                  if (data[previousIndex] != data[index]) {
                    cardStateKeys[previousIndex].currentState.toggleCard();
                    previousIndex = index;
                  } else {
                    cardFlips[previousIndex] = false;
                    cardFlips[index] = false;
                    print(cardFlips);

                    if (cardFlips.every((t) => t == false)) {
                      print("Won");
                      timer.cancel();
                      _showResult(true);
                    }
                  }
                }
              }
            },
            direction: FlipDirection.HORIZONTAL,
            flipOnTouch: cardFlips[index],
            front: Container(
              margin: EdgeInsets.all(4.0),
              color: AppColors.green.withOpacity(0.3),
              child: Image.asset(
                'assets/Card-Cover.png',
                alignment: Alignment.center,
                fit: BoxFit.cover,
              ),
            ),
            back: Container(
              margin: EdgeInsets.all(4.0),
              color: AppColors.green,
              child: Image.asset(
                'assets/Card-${int.parse(data[index]) + 1}.png',
                alignment: Alignment.center,
                fit: BoxFit.cover,
              ),
            ),
          ),
          itemCount: data.length,
        ),
      ),
    );
  }

  _showResult(bool isWon) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isWon ? Strings.wonTitle : Strings.loseTitle,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
        content: Text(
            isWon
                ? '${Strings.wonDescription} $time ${Strings.wonDescription2}'
                : Strings.loseDescription,
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18)),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GamePage(size: AppConfigs.fieldNumber)),
                  (Route<dynamic> route) => false);
            },
            child: Text(Strings.restartAction),
          ),
          FlatButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false);
            },
            child: Text(Strings.homeAction),
          ),
        ],
      ),
    );
  }
}
