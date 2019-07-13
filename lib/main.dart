import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  GamePage({Key key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<Block> blocks;
  int tries = 0;

  Block selectedBlock;

  void generateValues() {
    blocks = List.generate(81, (index) {
      return Block();
    });

    var rnd = Random();

    for (Block block in blocks) {
      var values = getAvailableValues(blocks.indexOf(block));

      if (values.length > 0) {
        block.value = values[rnd.nextInt(values.length)];
      }
    }

    tries++;

    setState(() {});

    for (Block block in blocks) {
      if (block.value == 0) {
//        Future.delayed(const Duration(milliseconds: 50), () {
//          generateValues();
//        });
        generateValues();
        return;
      }
    }
  }

  List<int> getAvailableValues(int index) {
    List<int> values = [1, 2, 3, 4, 5, 6, 7, 8, 9];

    int row = index ~/ 9;
    int col = index % 9;

    // check if number exists in row
    for (var i = 0; i < 9; i++) {
      var blockValue = blocks[row * 9 + i].value;
      if (blockValue > 0) {
        values.remove(blockValue);
      }
    }

    // check if number exists in column
    for (var i = 0; i < 9; i++) {
      var blockValue = blocks[col + i * 9].value;

      if (blockValue > 0) {
        values.remove(blockValue);
      }
    }

    // check if number exists in block
    int blockRow = (row ~/ 3) * 3;
    int blockCol = (col ~/ 3) * 3;
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        var blockValue = blocks[((blockRow + r) * 9) + (blockCol + c)].value;

        if (blockValue > 0) {
          values.remove(blockValue);
        }
      }
    }

    return values;
  }

  void validateBlockValues() {
    for(var b=0; b<blocks.length; b++) {
      var currentBlock = blocks[b];
      currentBlock.conflict = false;

      int row = b ~/ 9;
      int col = b % 9;

      // check if number exists in row
      for (var i = 0; i < 9; i++) {
        var block = blocks[row * 9 + i];
        if (block.value > 0 && block != currentBlock && block.value == currentBlock.value) {
          block.conflict = true;
          currentBlock.conflict = true;
        }
      }

      // check if number exists in column
      for (var i = 0; i < 9; i++) {
        var block = blocks[col + i * 9];
        if (block.value > 0 && block != currentBlock && block.value == currentBlock.value) {
          block.conflict = true;
          currentBlock.conflict = true;
        }
      }

      // check if number exists in block
      int blockRow = (row ~/ 3) * 3;
      int blockCol = (col ~/ 3) * 3;
      for (var r = 0; r < 3; r++) {
        for (var c = 0; c < 3; c++) {
          var block = blocks[((blockRow + r) * 9) + (blockCol + c)];
          if (block.value > 0 && block != currentBlock && block.value == currentBlock.value) {
            block.conflict = true;
            currentBlock.conflict = true;
          }
        }
      }
    }
  }

  @override
  void initState() {
    generateValues();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sudoku"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1.4,
              ),
            ),
            child: GridView.count(
              crossAxisCount: 9,
              shrinkWrap: true,
              children: List.generate(
                blocks.length, // 81
                (index) {
                  var backColor = blocks[index].value > 0 ? Colors.white : Colors.grey[200];

                  if (blocks[index] == selectedBlock) {
                    backColor = Colors.blueAccent;
                  }

                  var text = blocks[index].value > 0 ? blocks[index].value.toString() : "";
                  var textColor = blocks[index].conflict ? Colors.red : Colors.black;

                  return GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        border: getBorder(index),
                        color: backColor,
                      ),
                      child: Center(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 24,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedBlock = blocks[index];
                      });
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            child: Text(
              "Tries: " + tries.toString(),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(10, (index) {
                return GestureDetector(
                  child: Container(
                    padding: EdgeInsets.only(top: 4, bottom: 4, left: 10, right: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.all(Radius.circular(5.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[300],
                            offset: Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ]),
                    child: Center(
                      child: index > 0
                          ? Text(
                              (index).toString(),
                              style: TextStyle(fontSize: 24),
                            )
                          : Icon(Icons.clear),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedBlock.value = index;
                      validateBlockValues();
                    });
                  },
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            tries = 0;
            generateValues();
          });
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  Border getBorder(int index) {
    BorderSide topBorder = BorderSide(width: 0.2, color: Colors.grey[400]);
    BorderSide bottomBorder = BorderSide(width: 0.2, color: Colors.grey[400]);
    BorderSide leftBorder = BorderSide(width: 0.2, color: Colors.grey[400]);
    BorderSide rightBorder = BorderSide(width: 0.2, color: Colors.grey[400]);

    int row = index ~/ 9;
    int col = index % 9;

    if (row == 2 || row == 5) {
      bottomBorder = BorderSide(width: 0.5, color: Colors.black);
    }

    if (row == 3 || row == 6) {
      topBorder = BorderSide(width: 0.5, color: Colors.black);
    }

    if (col == 2 || col == 5) {
      rightBorder = BorderSide(width: 0.5, color: Colors.black);
    }

    if (col == 3 || col == 6) {
      leftBorder = BorderSide(width: 0.5, color: Colors.black);
    }

    return Border(
      top: topBorder,
      bottom: bottomBorder,
      left: leftBorder,
      right: rightBorder,
    );
  }

  Text getText() {
    if (getAvailableValues(blocks.indexOf(selectedBlock)).length == 0) {}
  }
}

class Block {
  int value = 0;
  var hints = [false, false, false, false, false, false, false, false, false];
  bool conflict = false;

  Block();
}
