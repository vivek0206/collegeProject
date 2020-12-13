


import 'dart:collection';
import 'dart:io';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
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

  List<Widget> _productImageSlides;
  Widget _productImageSlider;
  Widget _productImageSelect;
  List<Widget> _productStateList=<Widget>[];
  List<File> _images=[];
  int _currIndex=0;
  int _prevIndex=0;
  var _productImageSelectCount;

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
    _productImageSelectCount=0;
    _productImageSlides=List<Widget>();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    _productImageSelect=Container(
        height:screenHeight(context)*0.3,
        width:screenWidth(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(mainAxisAlignment:MainAxisAlignment.center,children: <Widget>[Icon(Icons.file_upload),Text('Upload Image'),],),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.black)),
                  color: Colors.black,
                  textColor: Colors.white,
                  child:Icon(Icons.camera),
                  onPressed: (){_imagePickCamera();},
                ),
                Container(width: 20.0,),
                RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.black)),
                  color: Colors.black,
                  textColor: Colors.white,
                  child:Icon(Icons.photo_library),
                  onPressed: (){_imagePickGallery();},
                ),

              ],
            )
          ],
        )
    );

    if(_productImageSlides.length==0)
      _productImageSlides.add(_productImageSelect);

    _productImageSlider=Container(
        height: screenHeight(context)*0.3,
        child: Carousel(
          boxFit: BoxFit.cover,
          dotBgColor: Colors.transparent,
          dotColor: Colors.black,
          dotIncreasedColor: Colors.black,
          dotSize: 4.0,
          indicatorBgPadding: 0.0,
          autoplay: false,
          animationCurve: Curves.fastOutSlowIn,
          animationDuration: Duration(milliseconds: 1000),
          images: _productImageSlides,
          onImageChange: (prev,curr){
            _prevIndex=prev;
            _currIndex=curr;
          },
        )
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
                _productImageSlider,
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

                    if(_images.length==0)
                      toast('Select atleast one image');
                    else{
                      toast('In Processing..');
                      _submitData();
                    }



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

    String imageCount=_images.length.toString();
    int _currentTime = DateTime.now().millisecondsSinceEpoch;
    print(DateTime.now().toString()+"**");
    Firestore.instance.collection('emergency').add({"flag":0,"bloodType":m[_bloodType],"msg":_msg,"phoneNumber":_phone,"dateTime":_currentTime,"imageCount":imageCount }).then((snapshot){
      String docId=snapshot.documentID.toString();
      _uploadPic(docId);
    });
    toast("Done");
    Navigator.pop(context);

  }
  _uploadPic(String docId)async{
    for(int i=1;i<=_images.length;i++){
      String fileName = docId+i.toString();
      StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child('emergency').child(fileName);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(_images[i-1]);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    }
    toast('Your request is sent to Admin for verification');
  }
  _imagePickCamera() async {
    if(_images.length>=3){
      toast('Max images selected');
      return;
    }
    var image =await ImagePicker.pickImage(source: ImageSource.camera);
    toast('Please wait');
    _cropImage(image);
    return;
  }

  _imagePickGallery() async {
    if(_images.length>=3){
      print('Max images selected');
      return;
    }
    var image =await ImagePicker.pickImage(source: ImageSource.gallery);
//    toast('Please wait');
//    print(image.lengthSync());
    _cropImage(image);
    return;

  }
  _cropImage(var image) async {
    if(image==null){
      print('Image not clicked');
      return;
    }
    File croppedFile=await ImageCropper.cropImage(
      sourcePath: image.path,
      compressFormat: ImageCompressFormat.jpg,
//      compressQuality: 10,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop image',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false),
    );
    if(croppedFile==null){
      toast('Crop undone');
      return;
    }
    File compressedFile= await FlutterImageCompress.compressAndGetFile(croppedFile.path,croppedFile.path.replaceAll('.jpg', _currIndex.toString()+'.jpg'),quality: 30);
    if(compressedFile==null){
      toast('Compress failed');
      return;
    }
    print(croppedFile.path );
    print(croppedFile.lengthSync());
    print(compressedFile.path );
    print(compressedFile.lengthSync());
    _images.add(compressedFile);
    _productImageSlides.insert(_currIndex, _imageSlide());
    setState(() {});
    return;
  }

  Widget _imageSlide(){
    Widget widget=Container(
        child: Stack(
          alignment:AlignmentDirectional.topEnd,
          children: <Widget>[
            Center(
              child: Image.file(_images.last),
            ),
            RaisedButton(
              color: Colors.white,
              child: Icon(Icons.delete),
              onPressed: (){
                print(_currIndex.toString());
                _images.removeAt(_currIndex);
                _productImageSlides.removeAt(_currIndex);
                setState(() {

                });
              },
            ),
          ],
        )
    );
    return widget;
  }


}