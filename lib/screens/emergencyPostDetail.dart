import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sale_spot/services/manualTools.dart';
import 'package:sale_spot/services/toast.dart';

import 'imageHero.dart';

class EmergencyPostDetail extends StatefulWidget {
  final String _documentId;
  final String _state;
  EmergencyPostDetail(this._documentId,this._state);
  @override
  _EmergencyPostDetailState createState() => _EmergencyPostDetailState(_documentId,_state);
}

class _EmergencyPostDetailState extends State<EmergencyPostDetail> {
  String _state;
  String _documentId;
  _EmergencyPostDetailState(this._documentId,this._state);
  PageController pageController;
  List<String> imagesUrl=<String>[];
  List<String> tags=[];
  List<dynamic>imagesHero=<dynamic>[];
  List<Image> images=[];
  Widget image_slider;
  Future<dynamic> _imageLoader;
  var snapshot;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _imageLoader=imageLoader();
  }
  @override
  Widget build(BuildContext context) {
    pageController=PageController(initialPage: 1,viewportFraction: 0.8);
    image_slider=new Container(
      color: Color(int.parse('0xffececec')),
      height: MediaQuery.of(context).size.height*0.5,
      child:Carousel(
        boxFit:BoxFit.cover,
        dotSize: 4.0,
        dotVerticalPadding: 20.0,
        indicatorBgPadding: 0.0,
        dotBgColor: Colors.transparent,
        overlayShadow: true,
        dotColor: Colors.white,
        dotIncreasedColor: Colors.white,

        overlayShadowColors: Colors.red,
        images:imagesHero,
        autoplay: false,
        animationCurve: Curves.fastOutSlowIn,
        animationDuration: Duration(milliseconds: 1000),


        onImageTap: (int value){
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>ImageHero(images,tags)));
        },

      ),
    );
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Detail'),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[

            FutureBuilder(
                future: _imageLoader,
                builder:(BuildContext context, AsyncSnapshot snapshot){
                  if(snapshot.hasData){
                    return new ListView(
//                      physics: NeverScrollableScrollPhysics(),
//                      shrinkWrap: true,
                      //padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      children: <Widget>[
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              image_slider,
                              SizedBox(height: 30.0),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Card(
                                  elevation: 0.0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                          alignment: AlignmentDirectional.bottomEnd,
                                          child: Text(DateFormat.yMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch((snapshot.data['dateTime'])))
                                            ,style: TextStyle(fontWeight:FontWeight.bold),)
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Recipeint : '+BloodMap.StringToBlood[snapshot.data['bloodType']],maxLines: 5,),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Message: '+snapshot.data['msg'],maxLines: 5,),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: SelectableText('Phone Number: '+snapshot.data['phoneNumber'],
                                          cursorColor: Colors.red,
                                          showCursor: true,
                                          toolbarOptions: ToolbarOptions(
                                              copy: true,
                                              selectAll: true,
                                              cut: false,
                                              paste: false
                                          ),),
                                      ),
                                      _state=='admin'?Container(
                                          margin:EdgeInsets.only(left:4.0,right:4.0,bottom: 2.0),
                                          height: screenHeight(context)/15,
                                          width: MediaQuery.of(context).size.width,
                                          child:  Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              RaisedButton(
                                                color: Colors.green,
                                                textColor: Colors.white,
                                                child: Text("Verify Request"),
                                                onPressed:() async {
                                                  await Firestore.instance.collection('emergency').document(_documentId).updateData({'flag':1});
                                                  toast('Verified successfully');
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              RaisedButton(
                                                color: Colors.redAccent,
                                                textColor: Colors.white,
                                                child: Text("Cancel Request"),
                                                onPressed:() async {
                                                  await Firestore.instance.collection('emergency').document(_documentId).delete();
                                                  toast('Request cancelled');
                                                  Navigator.pop(context);
                                                },
                                              )
                                            ],
                                          )
                                      ):Container()
                                    ],
                                  ),
                                ),
                              ),


                            ],
                          ),
                        ),
                      ],
                    );
                  }else{
                    print("Loading");
//              return Container();
                    return Center(child: CircularProgressIndicator());
                  }
                }

            ),
          ],
        ),
      ),

    );
  }

  Future imageLoader() async{
    snapshot=await Firestore.instance.collection('emergency').document(_documentId).get();
    print(_documentId);
    print(snapshot.data);
    var s;
    for(int i=1;i<=int.parse(snapshot.data['imageCount']);i++) {
      s=await FirebaseStorage.instance.ref().child('emergency').child(_documentId+i.toString()).getDownloadURL();

      if(s!=null) {
        imagesUrl.add(s.toString());
        // print(s.toString());
        images.add(Image.network(
          s.toString(),
        ));
        imagesHero.add(
//          Padding(
//            padding: const EdgeInsets.all(8.0),
//            child: Image.network(s.toString(),fit:BoxFit.fitHeight),
//          ),
          Hero(
            tag: snapshot.documentID+i.toString(),
            child: images.last,
          ),
        );
        tags.add(snapshot.documentID);

      }
    }
    return snapshot;

  }
}
