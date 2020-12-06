


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

  Widget _msgInfo,_phoneNumber;
  String _bloodType,_msg,_phone;
  var _emergencyForm = GlobalKey<FormState>();
  Map<String,String>m=Map();
  final List<String> nameList = <String>[
    "O+",
    "O-",
    "A+",
    "A-",
    "B-",
    "B+",
    "AB+",
    "AB-"
  ];
  @override
  void initState() {

    m['O+']='OPlus';
    m['O-']='OMinus';
    m['A+']='APlus';
    m['A-']='AMinus';
    m['B-']='BMinus';
    m['B+']='BPlus';
    m['AB+']='ABPlus';
    m['AB-']='ABMinus';
    _bloodType = nameList[0];
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

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
    _phoneNumber=TextFormField(
      onSaved: (value){
        _phone=value;
      },
      validator: (value){
        if(value.length==0)
          return 'Enter valid phone number';
        else
          return null;
      },
      decoration: InputDecoration(
          labelText: 'Phone Number',
          errorStyle: TextStyle(color: Colors.red),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0)
          )
      ),
    );


    return Scaffold(
        appBar: AppBar(
          title: Text('Emergency Message'),
        ),
        body:Padding(
            padding: const EdgeInsets.all(10.0),
          child:Form(
            key:_emergencyForm,
            child: ListView(
              children: <Widget>[

              Container(
                padding: EdgeInsets.all(20.0),
                child: DropdownButton(
                    value: _bloodType.isNotEmpty ? _bloodType : 'O+',
                    isExpanded: true,
                    items: nameList.map(
                          (item) {
                        return DropdownMenuItem(
                          value: item,
                          child: new Text(item),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        _bloodType = value;
                      });
                    }),
              ),
                Container(height: 10.0,),
                _msgInfo,
                Container(height: 10.0,),
                _phoneNumber,
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
                    toast('In Processing..');
                    _submitData();



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
    Firestore.instance.collection('emergency').add({"bloodType":m[_bloodType],"msg":_msg,"phoneNumber":_phone });
    toast("Done");
    Navigator.pop(context);

  }


}