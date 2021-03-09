import 'dart:math';

import 'package:flutter/material.dart';

import 'WinPage.dart';

class GamePage extends StatefulWidget {
  final int generateDelay;

  GamePage({Key key, this.generateDelay = 0}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<Block> blocks;
  bool setNote = false;

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
        block.correctValue = block.value;
      }
    }

    setState(() {});

    for (Block block in blocks) {
      if (block.value == 0) {
        if (widget.generateDelay > 0) {
          Future.delayed(Duration(milliseconds: widget.generateDelay), generateValues);
        } else {
          generateValues();
        }
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
    int solvedBlocks = 0;

    for (var b = 0; b < blocks.length; b++) {
      var currentBlock = blocks[b];

      if (currentBlock.value > 0) {
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

        if (!currentBlock.conflict) {
          solvedBlocks++;
        }
      }
    }

    if (solvedBlocks == 81) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WinPage()),
      );
    }
  }

  void removeValues(int num) {
    var rnd = Random();

    while (num > 0) {
      int index = rnd.nextInt(blocks.length);
      if (blocks[index].value > 0) {
        blocks[index].value = 0;
        blocks[index].static = false;
        num--;
      }
    }
  }

  @override
  void initState() {
    generateValues();
    removeValues(52);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sudoku"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                generateValues();
                removeValues(55);
              });
            },
          ),
        ],
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
                  var backColor = blocks[index].value > 0 ? Colors.white : Colors.grey[100];

                  if (blocks[index] == selectedBlock) {
                    backColor = Colors.blueAccent[100];
                  }

                  return GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        border: getBorder(index),
                        color: backColor,
                      ),
                      child: Center(
                        child: getText(index),
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
            margin: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                  child: Text("Hint"),
                  onPressed: () {
                    setState(() {
                      if (selectedBlock != null) {
                        setState(() {
                          selectedBlock.value = selectedBlock.correctValue;
                          validateBlockValues();
                        });
                      }
                    });
                  },
                ),
                Row(
                  children: <Widget>[
                    Text("Notes"),
                    Checkbox(
                      value: setNote,
                      onChanged: (value) {
                        setState(() {
                          setNote = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
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
                    if (selectedBlock.static) {
                      return;
                    }

                    if (setNote) {
                      if (index > 0) {
                        if (selectedBlock.notes[index - 1] == 0) {
                          selectedBlock.notes[index - 1] = index;
                        } else {
                          selectedBlock.notes[index - 1] = 0;
                        }
                      } else {
                        selectedBlock.clearNotes();
                      }
                    } else {
                      if (selectedBlock.value == index) {
                        selectedBlock.value = 0;
                      } else {
                        selectedBlock.value = index;
                      }
                      validateBlockValues();
                    }

                    setState(() {});
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget getText(int index) {
    Block block = blocks[index];

    if (block.value > 0) {
      var text = blocks[index].value > 0 ? blocks[index].value.toString() : "";
      var textColor = blocks[index].conflict
          ? Colors.red
          : blocks[index].static
              ? Colors.black
              : Colors.blue[900];

      return Text(
        text,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
      );
    } else if (block.hasNotes()) {
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        children: List.generate(
          9,
          (index) {
            return Center(
              child: block.notes[index] > 0
                  ? Text(
                      block.notes[index].toString(),
                      style: TextStyle(fontSize: 10, color: Colors.blue[900]),
                    )
                  : SizedBox.shrink(),
            );
          },
        ),
      );
    } else {
      return SizedBox.shrink();
    }
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
}

class Block {
  int correctValue = 0;
  int value = 0;
  var notes = [0, 0, 0, 0, 0, 0, 0, 0, 0];
  bool conflict = false;
  bool static = true;

  Block();

  bool hasNotes() {
    for (int note in notes) {
      if (note > 0) return true;
    }
    return false;
  }

  void clearNotes() {
    for (int i = 0; i < notes.length; i++) {
      notes[i] = 0;
    }
  }
}
