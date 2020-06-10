import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

enum Directions { UP, DOWN, LEFT, RIGHT }

class _GamePageState extends State<GamePage> {
  static List _snakePiecePositions;
  List _snakeBody;
  Directions _directions;
  bool isRunning;
  bool isStarted;
  var randomNumer = Random();
  var food;
  int score;
  Duration duration = Duration(milliseconds: (250));

  void generateNewFood() {
    food = randomNumer.nextInt(20 * 30);

    if (_snakePiecePositions.contains(food)) {
      generateNewFood();
    }
  }

  void startGame() {
    print(duration);
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
          if ((_snakePiecePositions.last + _snakePiecePositions.last % 20) >
              20 * 30 - 1) {
            endgame();
          } else {
            _snakePiecePositions.add(_snakePiecePositions.last + 20);
          }
          break;
        case Directions.UP:
          if ((_snakePiecePositions.last + _snakePiecePositions.last % 20) <
              0) {
            endgame();
          } else {
            _snakePiecePositions.add(_snakePiecePositions.last - 20);
          }
          break;
        case Directions.RIGHT:
          if (_snakePiecePositions.last % 20 == 19) {
            endgame();
          } else {
            _snakePiecePositions.add(_snakePiecePositions.last + 1);
          }
          break;
        case Directions.LEFT:
          if (_snakePiecePositions.last % 20 == 0) {
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
      } else if (checkForBodyBite()) {
        endgame();
      } else {
        _snakePiecePositions.removeAt(0);
      }
    });
  }

  @override
  void initState() {
    initGame();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
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
              child: AspectRatio(
                aspectRatio: 20 / (30 + 2),
                child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 20 * 30,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 20,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == _snakePiecePositions.last) {
                        return Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.deepOrangeAccent[700],
                              ),
                            ),
                          ),
                        );
                      } else if (_snakePiecePositions.contains(index)) {
                        return Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.deepOrangeAccent[100],
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
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        );
                      }
                    }),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                color: Colors.white),
            child: isStarted
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        isStarted = false;
                        isRunning = true;
                      });
                      startGame();
                    },
                    child: Text(
                      'Start Game',
                      style: TextStyle(
                          color: Colors.deepOrangeAccent,
                          fontSize: 23,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            initGame();
                          });
                        },
                        child: Text(
                          isRunning ? ' Score $score' : 'Reset Game',
                          style: TextStyle(
                              color: Colors.deepOrangeAccent,
                              fontSize: 23,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isRunning = !isRunning;
                            if (isRunning) {
                              startGame();
                            }
                          });
                        },
                        child: Text(
                          !isRunning ? 'Resume' : 'Pause',
                          style: TextStyle(
                              color: Colors.deepOrangeAccent,
                              fontSize: 23,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
          )
        ],
      ),
    );
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
                  setState(() {
                    initGame();
                    Navigator.pop(context);
                  });
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
      isRunning = false;
    });
  }

  void initGame() {
    _snakePiecePositions = [45, 65, 85];
    _directions = Directions.DOWN;
    isRunning = false;
    isStarted = true;
    generateNewFood();
    score = 0;
  }

  bool checkForBodyBite() {
    _snakeBody = _snakePiecePositions.toList();
    _snakeBody.remove(_snakePiecePositions.last);

    if (_snakeBody.contains(_snakePiecePositions.last)) {
      return true;
    } else
      return false;
  }
}
