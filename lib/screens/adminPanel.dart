
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sale_spot/screens/emergencyPostDetail.dart';
import 'package:sale_spot/services/manualTools.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body:getNotificationList(),
    );
  }
  getNotificationList() {

    return StreamBuilder<QuerySnapshot> (
      stream: Firestore.instance.collection('emergency').where('flag',isEqualTo: 0).orderBy('dateTime',descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> Snapshot) {
        if(!Snapshot.hasData||Snapshot.data.documents.length==0)
          return Center(
            child: Text("No Request to verify"),
          );
        // print(Snapshot.data.documents[0].data['msg']);
        int itemCount=Snapshot.data.documents.length;
        return ListView.builder(itemCount: itemCount,itemBuilder: (BuildContext context, int index){
          DocumentSnapshot documentSnapshot=Snapshot.data.documents[index];
          String docId=Snapshot.data.documents[index].documentID;
          DateTime postTime=DateTime.fromMillisecondsSinceEpoch((documentSnapshot.data['dateTime']));

          return InkWell(
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>EmergencyPostDetail(docId,'admin')));
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
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          color: Colors.green,
                          textColor: Colors.white,
                          child: Text("Verify Request"),
                          onPressed:() async {
                            await Firestore.instance.collection('emergency').document(docId).updateData({'flag':1});
                            setState(() {});
                          },
                        ),
                        RaisedButton(
                          color: Colors.redAccent,
                          textColor: Colors.white,
                          child: Text("Cancel Request"),
                          onPressed:() async {
                            await Firestore.instance.collection('emergency').document(docId).delete();
                            setState(() {});
                          },
                        )
                      ],
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
