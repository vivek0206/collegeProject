
import 'package:sale_spot/classes/user.dart';
import 'package:flutter/material.dart';

class Emergency extends StatefulWidget {
  final User _user;
  Emergency(this._user);

  @override
  _EmergencyState createState() => _EmergencyState(_user);
}

class _EmergencyState extends State<Emergency> {

  final User _user;
  _EmergencyState(this._user);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency'),
      ),
      body:Column(
        children: <Widget>[
          Text("hi i am vicky"),
        ],
      )
    );

  }
}