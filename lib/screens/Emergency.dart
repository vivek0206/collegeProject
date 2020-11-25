


import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:flutter/material.dart';
import 'package:sale_spot/services/toast.dart';

class Emergency extends StatefulWidget {
  final User _user;
  Emergency(this._user);

  @override
  _EmergencyState createState() => _EmergencyState(_user);
}

class _EmergencyState extends State<Emergency> {

  final User _user;
  _EmergencyState(this._user);

  List<File> _images=[];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency'),
      ),
      body:Column(
        children: <Widget>[
          Text("hi i am vicky"),
          RaisedButton(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.black)),
            color: Colors.black,
            textColor: Colors.white,
            child:Icon(Icons.camera),
            onPressed: (){_imagePickCamera();},
          ),
        ],
      )
    );

  }

  _imagePickCamera() async {
    if(_images.length>=2){
      toast('Max images selected');
      return;
    }
    var image =await ImagePicker.pickImage(source: ImageSource.camera);
    toast('Please wait');
    // _cropImage(image);
    return;




  }
}