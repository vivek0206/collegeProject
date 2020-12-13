import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:flutter/material.dart';
import 'package:sale_spot/services/manualTools.dart';
import 'package:sale_spot/services/toast.dart';

import 'emergencyPostDetail.dart';

class EmergencyNotification extends StatefulWidget {
  final User _user;
  EmergencyNotification(this._user);

  @override
  _EmergencyNotification createState() => _EmergencyNotification(_user);
}

class _EmergencyNotification extends State<EmergencyNotification> {

  final User _user;
  _EmergencyNotification(this._user);
  List<String> myTopics = List<String>();
  String bloodGroup;
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    bloodGroup=BloodMap.StringToBlood[_user.bloodType];
    print(bloodGroup);
    if(bloodGroup=='O-')
      myTopics=['O-','O+','AB-','AB+','B-','B+','A-','A+'];
    else if(bloodGroup=='O+')
      myTopics=['O+','AB+','A+'];
    else if(bloodGroup=='AB-')
      myTopics=['AB-','AB+'];
    else if(bloodGroup=='AB+')
      myTopics=['AB+'];
    else if(bloodGroup=='B-')
      myTopics=['AB-','AB+','B-','B+'];
    else if(bloodGroup=='B+')
      myTopics=['AB+','B+'];
    else if(bloodGroup=='A-')
      myTopics=['AB-','AB+','A-','A+'];
    else if(bloodGroup=='A+')
      myTopics=['AB+','A+'];
    print(myTopics.length);


  }

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
        List<String>topics=myTopics;
        print(myTopics.length);
        for(int i=0;i<myTopics.length;i++)
          {
              topics[i]=BloodMap.BloodToString[topics[i]];
              // print(myTopics[i]);
          }
        return StreamBuilder<QuerySnapshot> (
          stream: Firestore.instance.collection('emergency').where('bloodType',whereIn: topics).where('flag',isEqualTo: 1).orderBy('dateTime',descending: true).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> Snapshot) {
            if(!Snapshot.hasData||Snapshot.data.documents.length==0)
              return Center(
                child: Text("No notification yet"),
              );
            // print(Snapshot.data.documents[0].data['msg']);
            int itemCount=Snapshot.data.documents.length;
            return ListView.builder(itemCount: itemCount,itemBuilder: (BuildContext context, int index){
              DocumentSnapshot documentSnapshot=Snapshot.data.documents[index];
              String docId=Snapshot.data.documents[index].documentID;
              DateTime postTime=DateTime.fromMillisecondsSinceEpoch((documentSnapshot.data['dateTime']));
              return InkWell(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>EmergencyPostDetail(docId,'user')));

                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            alignment: AlignmentDirectional.bottomEnd,
                            child: Text(DateFormat.yMd().add_jm().format(postTime)
                              ,style: TextStyle(fontWeight:FontWeight.bold),)
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Recipient : '+BloodMap.StringToBlood[documentSnapshot.data['bloodType']],maxLines: 5,),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Message: '+documentSnapshot.data['msg'],maxLines: 5,),
                        ),

                         Padding(
                           padding: EdgeInsets.all(8.0),
                           child: SelectableText('Phone Number: '+documentSnapshot.data['phoneNumber'],
                              cursorColor: Colors.red,
                              showCursor: true,
                              toolbarOptions: ToolbarOptions(
                                  copy: true,
                                  selectAll: true,
                                  cut: false,
                                  paste: false
                              ),),
                         )
                      ],
                    ),
                  ),
                ),
              );


            });
          },
        );


  }


}