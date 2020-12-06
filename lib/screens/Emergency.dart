


import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:flutter/material.dart';
import 'package:sale_spot/services/toast.dart';
import 'package:qrscan/qrscan.dart' as scanner;

import 'make_profile.dart';

class Emergency extends StatefulWidget {
  final AuthResult _authResult;
  Emergency(this._authResult);

  @override
  _EmergencyState createState() => _EmergencyState(_authResult);
}

class _EmergencyState extends State<Emergency> {

  final AuthResult _authResult;
  _EmergencyState(this._authResult);
  @override
  void initState() {
    // TODO: implement initState
    scanBarCode();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Scan ID-card'),
      ),
      body:Center(
        child: RaisedButton(
          child: Text("Scan Barcode"),
          onPressed: ()
            {
              scanBarCode();
              },
        ),
      )

    );

  }
  Future<void> scanBarCode() async {
    toast("Scan your Icard Barcode");
    String cameraScanResult = await scanner.scan();
    print(cameraScanResult);
    if(isValidReg(cameraScanResult))
    {
      print("yes");
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MakeProfile(_authResult);
      }));

    }
    else{
      print("no");
      toast("Could not identify as MNNIT student.Please retry");
      scanBarCode();
    }
  }
  bool isValidReg(String cameraScanResult) {
    cameraScanResult=cameraScanResult.trim();
    print(cameraScanResult.length);
    if(cameraScanResult==null || cameraScanResult.length!=8)
      return false;
    cameraScanResult=cameraScanResult.substring(0,4);
    int regYear=int.parse(cameraScanResult);

    int currentYear=DateTime.now().year;
    if(regYear>=currentYear-4&&regYear<=currentYear)
    {
      return true;
    }
    return false;

  }
}