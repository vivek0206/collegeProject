


import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:flutter/material.dart';
import 'package:sale_spot/services/toast.dart';

class EmergencyMsg extends StatefulWidget {
  final User _user;
  EmergencyMsg(this._user);

  @override
  _EmergencyMsgState createState() => _EmergencyMsgState(_user);
}

class _EmergencyMsgState extends State<EmergencyMsg> {

  final User _user;
  _EmergencyMsgState(this._user);
  Widget _bloodInfo,_msgInfo;
  String _bloodType,_msg;
  var _emergencyForm = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    _bloodInfo=TextFormField(
      onSaved: (value){

        _bloodType=value;
      },
      validator: (value){
        if(value.length==0)
          return 'Enter valid Blood Type';
        else
          return null;
      },
      decoration: InputDecoration(
          labelText: 'Blood Type',
          errorStyle: TextStyle(color: Colors.red),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0)
          )
      ),
    );
    _msgInfo=TextFormField(
      onSaved: (value){
        _msg=value;
      },
      validator: (value){
        if(value.length==0)
          return 'Enter valid msg';
        else
          return null;
      },
      decoration: InputDecoration(
          labelText: 'Message',
          errorStyle: TextStyle(color: Colors.red),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0)
          )
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text('Emergency'),
        ),
        body:Padding(
            padding: const EdgeInsets.all(10.0),
          child:Form(
            key:_emergencyForm,
            child: ListView(
              children: <Widget>[
                Text("send notification here"),
                Container(height: 10.0,),
                _bloodInfo,
                Container(height: 10.0,),
                _msgInfo,
                Container(height: 10.0,),
                RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.black)),
                  color: Colors.black,
                  textColor: Colors.white,
                  child:Text("Send Notification"),
                  onPressed: (){
                  if (_emergencyForm.currentState.validate()) {
                    _emergencyForm.currentState.save();
                    _submitData();


                    toast('In Process');
                  }
                  },
                ),
              ],
            ),
          )
        )
    );

  }

  void _submitData() {
    print(_bloodType+" "+_msg);
    Firestore.instance.collection('emergency').add({"bloodType":_bloodType,"msg":_msg,"flag":0 });
    toast("added");
    _bloodType="";
    _msg="";
    setState(() {
    });

  }


}