


import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:flutter/material.dart';
import 'package:sale_spot/services/toast.dart';

import 'emergencyNotification.dart';

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
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>EmergencyNotification(_user)));
                },
                child: Icon(
                  LineIcons.bell,
                  size: 26.0,
                ),
              )
          ),
        ],
      ),
      body:Column(
        children: <Widget>[
          Text("select Icard Image to detect your blood group"),
          RaisedButton(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.black)),
            color: Colors.black,
            textColor: Colors.white,
            child:Icon(Icons.camera),
            onPressed: (){_imagePickCamera();},
          ),
          _images.length>0?Center(
            child: Image.file(_images.last),
          ):Center(),
        ],
      ),

    );

  }

  _imagePickCamera() async {
    if(_images.length>=2){
      toast('Max images selected');
      return;
    }
    var image =await ImagePicker.pickImage(source: ImageSource.camera);
    _images.add(image);
    toast('Please wait');
    setState(() {

    });
    // _cropImage(image);
    return;




  }
}