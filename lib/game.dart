import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

enum GameState { SPLASH, RUNNING, SUCCESS, FAILURE }
enum Directions { UP, DOWN, LEFT, RIGHT }

class _GamePageState extends State<GamePage> {
  static List _snakePiecePositions = [45, 63, 81, 99];
  Directions _directions = Directions.DOWN;
  bool isRunning = false;
  bool isStarted = true;
  static var randomNumer = Random();
  var food = randomNumer.nextInt(500);
  int score = 0;
  int speed = 300;
  var duration = Duration(milliseconds: 300);

  void generateNewFood() {
    if (score % 2 == 0) {
      print('object');
      setState(() {
        duration = Duration(milliseconds: speed + 100);
      });
    }
    food = randomNumer.nextInt(500);
  }

  void startGame() {
    isRunning = true;
    isStarted = false;

    Timer.periodic(duration, (timer) {
      if (isRunning) {
        updateSnake();
      } else {
        timer.cancel();
      }
    });
  }

  updateSnake() {
    setState(() {
      switch (_directions) {
        case Directions.DOWN:
          if ((_snakePiecePositions.last +
                  _snakePiecePositions.last % 18 +
                  30) >
              540) {
            endgame();
          } else {
            _snakePiecePositions.add(_snakePiecePositions.last + 18);
          }
          break;
        case Directions.UP:
          if ((_snakePiecePositions.last +
                  _snakePiecePositions.last % 18 -
                  30) <
              0) {
            endgame();
          } else {
            _snakePiecePositions.add(_snakePiecePositions.last - 18);
          }
          break;
        case Directions.RIGHT:
          if (_snakePiecePositions.last % 18 == 17) {
            endgame();
          } else {
            _snakePiecePositions.add(_snakePiecePositions.last + 1);
          }
          break;
        case Directions.LEFT:
          if (_snakePiecePositions.last % 18 == 0) {
            endgame();
          } else {
            _snakePiecePositions.add(_snakePiecePositions.last - 1);
          }
          break;
        default:
      }

      if (_snakePiecePositions.last == food) {
        ++score;
        generateNewFood();
      } else {
        _snakePiecePositions.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.width * 1.8,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (_directions != Directions.UP && details.delta.dy > 0) {
                    setState(() {
                      _directions = Directions.DOWN;
                    });
                  } else if (_directions != Directions.DOWN &&
                      details.delta.dy < 0) {
                    setState(() {
                      _directions = Directions.UP;
                    });
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (_directions != Directions.LEFT && details.delta.dx > 0) {
                    setState(() {
                      _directions = Directions.RIGHT;
                    });
                  } else if (_directions != Directions.RIGHT &&
                      details.delta.dx < 0) {
                    setState(() {
                      _directions = Directions.LEFT;
                    });
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 540,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 18,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      if (_snakePiecePositions.contains(index)) {
                        return Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.deepOrangeAccent[400],
                              ),
                            ),
                          ),
                        );
                      } else if (index == food) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            color: Colors.limeAccent,
                          ),
                        );
                      } else {
                        return ClipRRect(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.purple[100],
                            ),
                          ),
                        );
                      }
                    }),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                  color: Colors.white),
              child: isStarted
                  ? GestureDetector(
                      onTap: () {
                        startGame();
                      },
                      child: Text(
                        'Start Game',
                        style: TextStyle(
                            color: Colors.deepOrangeAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            resetGame();
                          },
                          child: Text(
                            isRunning ? ' Score $score' : 'Reset Game',
                            style: TextStyle(
                                color: Colors.deepOrangeAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (isRunning) {
                              setState(() {
                                isRunning = false;
                              });
                            } else {
                              setState(() {
                                startGame();
                                isRunning = true;
                              });
                            }
                          },
                          child: Text(
                            !isRunning ? 'Resume' : 'Pause',
                            style: TextStyle(
                                color: Colors.deepOrangeAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }

  void resetGame() {
    setState(() {
      isStarted = true;
      _snakePiecePositions = [45, 63, 81, 99];
      _directions = Directions.DOWN;
      isRunning = false;
      score = 0;
    });
  }

  void endgame() {
    setState(() {
      showDialog(
          context: context,
          child: CupertinoAlertDialog(
            title: Text(
              'Game Ended',
              style: TextStyle(
                  color: Colors.deepOrangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
            content: Text(
              'Final Score $score',
              style: TextStyle(
                  color: Colors.deepOrangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  resetGame();
                  Navigator.pop(context);
                },
                child: Text(
                  'Play Again',
                  style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
                child: Text(
                  'Exit',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              )
            ],
          ));
      print('done');
      isRunning = false;
    });
  }
}
