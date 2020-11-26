import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:flutter/material.dart';
import 'package:sale_spot/services/toast.dart';

class EmergencyNotification extends StatefulWidget {
  final User _user;
  EmergencyNotification(this._user);

  @override
  _EmergencyNotification createState() => _EmergencyNotification(_user);
}

class _EmergencyNotification extends State<EmergencyNotification> {

  final User _user;
  _EmergencyNotification(this._user);

  List<File> _images=[];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text('Emergency Notification'),
        ),
        body:getNotificationList(),
    );

  }

  getNotificationList() {
    return StreamBuilder(
      stream: Firestore.instance.collection('user').document(_user.documentId).snapshots(),
      builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> docSnapshots){
        if(!docSnapshots.hasData)
          return Center(child: Icon(Icons.cloud_queue));
        // int itemCount=docSnapshots.data.documents[0].length;
        // if(itemCount==0)
        // {
        //
        // }
        String userBlood=docSnapshots.data['bloodType'];
        return StreamBuilder<QuerySnapshot> (
          stream: Firestore.instance.collection('emergency').where('bloodType',isEqualTo: userBlood).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> Snapshot) {
            if(!Snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            print(Snapshot.data.documents[0].data['msg']);
            int itemCount=Snapshot.data.documents.length;
            return ListView.builder(itemCount: itemCount,itemBuilder: (BuildContext context, int index){
              DocumentSnapshot documentSnapshot=Snapshot.data.documents[index];
              return ListTile(
                title: Text(documentSnapshot.data['msg']),
              );


            });
          },
        );
      },
    );
  }


}