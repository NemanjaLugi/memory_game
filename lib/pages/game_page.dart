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

  int time = 0;
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
    startTimer();
    data.shuffle();
  }

  startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        time = time + 1;
      });
    });
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
        title: Text('Memory game'),
        backgroundColor: AppColors.green.withOpacity(0.8),
      ),
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/background-img.png'),
                  fit: BoxFit.cover)),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "$time",
                    style: Theme.of(context).textTheme.display2,
                  ),
                ),
                Theme(
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
                                cardStateKeys[previousIndex]
                                    .currentState
                                    .toggleCard();
                                previousIndex = index;
                              } else {
                                cardFlips[previousIndex] = false;
                                cardFlips[index] = false;
                                print(cardFlips);

                                if (cardFlips.every((t) => t == false)) {
                                  print("Won");
                                  timer.cancel();
                                  showResult(context);
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
                        ),
                        back: Container(
                          margin: EdgeInsets.all(4.0),
                          color: AppColors.green,
                          child: Center(
                            child: Text(
                              "${data[index]}",
                              style: Theme.of(context).textTheme.display2,
                            ),
                          ),
                        ),
                      ),
                      itemCount: data.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

  showResult(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Won!!!"),
        content: Text(
          "Time $time",
          style: Theme.of(context).textTheme.display2,
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => GamePage(size: 16)),
                  (Route<dynamic> route) => false);
            },
            child: Text("RESTART"),
          ),
          FlatButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false);
            },
            child: Text("HOME"),
          ),
        ],
      ),
    );
  }
}
