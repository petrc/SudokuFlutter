import 'package:flutter/material.dart';

class WinPage extends StatefulWidget {
  WinPage({Key key}) : super(key: key);

  @override
  _WinPageState createState() => _WinPageState();
}

class _WinPageState extends State<WinPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sudoku"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("Congratulations"),
          ],
        ),
      ),
    );
  }
}
