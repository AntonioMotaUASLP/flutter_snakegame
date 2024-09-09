import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para captar eventos de teclado

void main() {
  runApp(MaterialApp(
    home: SnakeGame(),
  ));
}

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int rowCount = 20;
  static const int colCount = 20;
  static const int initialSnakeLength = 5;
  List<int> snake = [];
  int food = 0;
  String direction = 'right'; // Inicializamos la dirección de la serpiente
  Timer? gameLoop;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    snake = List.generate(initialSnakeLength, (index) => index);
    direction = 'right';
    generateFood();
    gameLoop = Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        moveSnake();
      });
    });
  }

  void generateFood() {
    Random random = Random();
    food = random.nextInt(rowCount * colCount);
    while (snake.contains(food)) {
      food = random.nextInt(rowCount * colCount);
    }
  }

  void moveSnake() {
    int newHead;
    switch (direction) {
      case 'right':
        newHead = snake.last % colCount == colCount - 1 ? snake.last - (colCount - 1) : snake.last + 1;
      case 'left':
        newHead = snake.last % colCount == 0 ? snake.last + (colCount - 1) : snake.last - 1;
      case 'up':
        newHead = snake.last < colCount ? snake.last + (rowCount * colCount) - colCount : snake.last - colCount;
      case 'down':
        newHead = snake.last + colCount >= rowCount * colCount ? snake.last % colCount : snake.last + colCount;
      default:
        return;
    }

    if (snake.contains(newHead)) {
      gameOver();
      return;
    }

    snake.add(newHead);

    if (newHead == food) {
      generateFood();
    } else {
      snake.removeAt(0); // Si no come, eliminar la cola de la serpiente
    }
  }

  void gameOver() {
    gameLoop?.cancel();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("Puntuación: ${snake.length}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
              child: Text("Jugar de nuevo"),
            )
          ],
        );
      },
    );
  }

  // Detectar teclas de W, A, D
  void onKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyW && direction != 'down') {
        setState(() {
          direction = 'up';
        });
      } else if (event.logicalKey == LogicalKeyboardKey.keyA && direction != 'right') {
        setState(() {
          direction = 'left';
        });
      } else if (event.logicalKey == LogicalKeyboardKey.keyD && direction != 'left') {
        setState(() {
          direction = 'right';
        });
      } else if (event.logicalKey == LogicalKeyboardKey.keyS && direction != 'up') {
        setState(() {
          direction = 'down';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Snake Game'),
        ),
        body: RawKeyboardListener(
          focusNode: FocusNode(), // Necesario para captar eventos de teclado
          autofocus: true, // Captar el foco automáticamente
          onKey: onKey, // Función para manejar las teclas
          child: GridView.builder(
            itemCount: rowCount * colCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: colCount,
            ),
            itemBuilder: (BuildContext context, int index) {
              bool isSnakeBody = snake.contains(index);
              bool isFood = index == food;
              return Container(
                margin: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: isSnakeBody ? Colors.green : isFood ? Colors.red : Colors.grey[800],
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    super.dispose();
  }
}
