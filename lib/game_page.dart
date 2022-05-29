import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:ponggo/brick.dart';
import 'package:ponggo/highscore.dart';
import 'package:provider/provider.dart';

enum Direction { up, down, left, right }

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool isGameOn = false;
  bool isInit = false;
  Timer? timer;
  double brickWidth = Get.width * 0.2, brickHeight = 20, ballRadius = 10;
  Color ballColor = Colors.pink;
  late int score, localHScore;
  late HighScore highScore;
  late double leftBoundry, rightBoundry, topBoundry, bottomBoundry;
  late double midX, midY;
  late double playerX, playerY;
  late double availableWidth, availableHeight;
  late double ballX, ballY;
  late double aiY;
  late Direction horizontal, vertical;
  late double speed;
  late DateTime startTime;

  @override
  void didChangeDependencies() {
    if (!isInit) {
      setState(() {
        highScore = Provider.of<HighScore>(context);

        isInit = true;
      });
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    availableHeight = Get.height - Get.bottomBarHeight - Get.statusBarHeight;
    availableWidth = Get.width;
    midX = availableWidth / 2;
    midY = Get.statusBarHeight + (availableHeight * 0.8) / 2;
    leftBoundry = 0;
    rightBoundry = availableWidth;
    topBoundry = Get.statusBarHeight;
    bottomBoundry = (availableHeight * 0.8) + Get.statusBarHeight;
    playerX = midX;
    playerY = bottomBoundry;
    ballX = midX;
    ballY = midY;
    aiY = Get.statusBarHeight;
    speed = 2.5;
    horizontal = Direction.left;
    vertical = Direction.up;
    localHScore = 0;
    score = 0;
    startTime = DateTime.now();
    super.initState();
  }

  updateDirections() async {
    setState(() {
      //left
      if (ballX - ballRadius <= leftBoundry) {
        horizontal = Direction.right;
      }
      //right
      if (ballX + ballRadius >= rightBoundry) {
        horizontal = Direction.left;
      }
      //top
      if (ballY - ballRadius <= topBoundry + brickHeight) {
        if (vertical == Direction.up) {
          ballColor = Colors.pink;
        }
        vertical = Direction.down;
      }
      if (ballY + ballRadius >= bottomBoundry) {
        timer?.cancel();
        isGameOn = false;
        localHScore = score;
        reset();
      }

      //bottom
      else if (ballY + ballRadius >= bottomBoundry - brickHeight) {
        if (ballX >= playerX - brickWidth / 2 &&
            ballX <= playerX + brickWidth / 2) {
          if (vertical == Direction.down) {
            ballColor = Colors.white;
            score += 1;
          }
          vertical = Direction.up;
        } else {
          if (ballY + ballRadius >= bottomBoundry - brickHeight / 2) {
            if (ballX >= playerX - brickWidth / 2 &&
                ballX <= playerX + brickWidth / 2) {
              if (vertical == Direction.down) {
                ballColor = Colors.white;
                score += 1;
              }
              vertical = Direction.up;
            } else {
              if (score > localHScore) {
                timer?.cancel();
                isGameOn = false;
                localHScore = score;
                reset();
              }
            }
          }
        }
      }
    });
  }

  reset() async {
    if (score > highScore.score) {
      await highScore.setScore(score);
    }

    setState(() {
      if (score > highScore.score) {
        localHScore = score;
      }

      playerX = midX;
      playerY = bottomBoundry;
      ballX = midX;
      ballY = midY;
      aiY = Get.statusBarHeight;
      speed = 2.5;
      horizontal = Direction.left;
      vertical = Direction.up;

      isGameOn = false;
      score = 0;
    });
  }

  moveBall() {
    setState(() {
      if (horizontal == Direction.left) {
        ballX -= speed;
      } else {
        ballX += speed;
      }
      if (vertical == Direction.down) {
        ballY += speed;
      } else {
        ballY -= speed;
      }
    });
  }

  startGame() {
    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      //update directions
      updateDirections();
      //move ball position
      moveBall();
      if (DateTime.now().difference(startTime).inSeconds > 10) {
        setState(() {
          speed = speed * 1.15;
          startTime = DateTime.now();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isGameOn) {
          setState(() {
            isGameOn = true;
            startTime = DateTime.now();
          });
          startGame();
        }
      },
      onHorizontalDragUpdate: (details) {
        if (isGameOn) {
          double currentX = details.globalPosition.dx;
          setState(() {
            if (currentX >= Get.width * 0.1 && currentX <= Get.width * 0.9) {
              playerX = currentX;
            } else {
              if (currentX < Get.width * 0.1) {
                playerX = Get.width * 0.1;
              } else {
                playerX = Get.width * 0.9;
              }
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            if (isGameOn)
              Positioned(
                top: midY - 50,
                width: availableWidth,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    score.toString(),
                    style: const TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                ),
              ),
            Positioned(
              top: bottomBoundry + 25,
              width: availableWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const AutoSizeText(
                        'HIGH SCORE',
                        minFontSize: 12,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey),
                      ),
                      AutoSizeText(
                        highScore.score.toString(),
                        minFontSize: 12,
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w400,
                            color: Colors.pink),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const AutoSizeText(
                        'CURRENT HIGH',
                        minFontSize: 12,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey),
                      ),
                      AutoSizeText(
                        localHScore.toString(),
                        minFontSize: 12,
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w400,
                            color: Colors.pink),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isGameOn)
              Positioned(
                top: midY + 50,
                width: availableWidth,
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Tap to Start',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                ),
              ),
            // Positioned(
            //   left: leftBoundry,
            //   top: topBoundry,
            //   width: availableWidth,
            //   height: availableHeight * 0.8,
            //   child: AnimatedContainer(
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.red),
            //     ),
            //     duration: const Duration(milliseconds: 1000 ~/ 60),
            //   ),
            // ),
            Brick(
              left: ballX,
              top: aiY,
              color: Colors.pink,
              height: brickHeight,
              width: brickWidth,
              shift: false,
            ),
            Positioned(
              left: ballX - ballRadius,
              top: ballY - ballRadius,
              width: ballRadius * 2,
              height: ballRadius * 2,
              child: AnimatedContainer(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ballColor,
                ),
                duration: const Duration(milliseconds: 10),
              ),
            ),
            if (!isGameOn)
              Positioned(
                left: ballX - 30,
                top: ballY - 30,
                child: LoadingFlipping.circle(
                  borderColor: Colors.pink.withOpacity(0.25),
                  size: 60,
                ),
              ),
            if (!isGameOn)
              Positioned(
                left: ballX - 30,
                top: ballY - 30,
                child: LoadingFlipping.circle(
                  borderColor: Colors.white.withOpacity(0.25),
                  size: 60,
                ),
              ),
            if (!isGameOn)
              Positioned(
                left: ballX - 10,
                top: ballY - 10,
                child: LoadingFlipping.circle(
                  borderColor: Colors.white.withOpacity(0.25),
                  size: 20,
                  borderSize: 10,
                ),
              ),
            Brick(
              left: playerX,
              top: playerY,
              color: Colors.white,
              height: brickHeight,
              width: brickWidth,
              shift: true,
            ),
          ],
        ),
      ),
    );
  }
}
