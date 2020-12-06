import 'dart:convert';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class MakeProfile extends StatefulWidget {
	AuthResult authResult;
	MakeProfile(this.authResult);

	@override
	_MakeProfileState createState() => _MakeProfileState(authResult);
}

class _MakeProfileState extends State<MakeProfile> {
	AuthResult authResult;
	_MakeProfileState(this.authResult);

	GoogleSignIn _googleSignIn = GoogleSignIn();

	var _profileForm = GlobalKey<FormState>();

	User _user = User();
	bool _isLoading = false;
	String _bloodType;
	final List<String> nameList = <String>["O+", "O-", "A+", "A-", "B-", "B+", "AB+", "AB-"];
	List<String> myTopics = List<String>();
	Map<String,String>m=Map();
	String bloodGroup;
	void initState() {
		super.initState();
		_user.name = authResult.user.displayName;
		_user.email = authResult.user.email;
		_user.blockedNo = 0;
		_user.photoUrl = authResult.user.photoUrl;
		m['O+']='OPlus';
		m['O-']='OMinus';
		m['A+']='APlus';
		m['A-']='AMinus';
		m['B-']='BMinus';
		m['B+']='BPlus';
		m['AB+']='ABPlus';
		m['AB-']='ABMinus';
		_bloodType = nameList[0];
		_user.bloodType=_bloodType;

		bloodGroup=_user.bloodType;
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


	}

	@override
	Widget build(BuildContext context) {
		double screenWidth = MediaQuery.of(context).size.width;
		double screenHeight = MediaQuery.of(context).size.height;
		return Scaffold(
			appBar: AppBar(
				title: Text('Make Profile'),
			),
			body: WillPopScope(
				onWillPop: () {
					Navigator.pop(context);
					_googleSignIn.signOut();
				},
				child: Center(
				  child: Container(
				  	width: screenWidth*0.7,
				  	height: screenHeight*0.7,
				  	child: Column(
				  		children: <Widget>[
				  			Padding(
				  				padding: const EdgeInsets.all(20.0),
				  				child: CircularProfileAvatar(
				  					_user.photoUrl,
				  					radius: screenWidth*0.1,
				  					backgroundColor: Colors.transparent,
				  					borderWidth: 3.0,
				  					borderColor: Colors.black,
				  				),
				  			),
				  			Form(
				  				key: _profileForm,
				  				child: Flexible(
				  					child: ListView(
				  						children: <Widget>[
											Padding(
												padding: EdgeInsets.all(10.0),
												child: TextFormField(
													readOnly: true,
													initialValue: _user.name,
													decoration: InputDecoration(
														labelText: 'Name',
														errorStyle: TextStyle(color: Colors.red),
														border: OutlineInputBorder(
															borderRadius: BorderRadius.circular(20.0)
														)
													),
												),
											),
											Padding(
												padding: EdgeInsets.all(10.0),
												child: TextFormField(
													readOnly: true,
													initialValue: _user.email,
													decoration: InputDecoration(
														labelText: 'Email',
														errorStyle: TextStyle(color: Colors.red),
														border: OutlineInputBorder(
															borderRadius: BorderRadius.circular(20.0)
														)
													),
												),
											),
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
																	_user.bloodType=value;
																});
															}),
												),
				  							Padding(
				  								padding: EdgeInsets.all(10.0),
				  								child: TextFormField(
													inputFormatters: [LengthLimitingTextInputFormatter(10)],
				  									keyboardType: TextInputType.number,
				  									onSaved: (value) {
				  										_user.mobile = value;
				  									},
				  									validator: (value) {
				  										if(!RegExp("[0-9]").hasMatch(value) || value.length!=10)
				  											return 'Enter Valid Number';
				  										else
				  											return null;
				  									},
				  									decoration: InputDecoration(
				  										labelText: 'Mobile Number',
				  										errorStyle: TextStyle(color: Colors.red),
				  										border: OutlineInputBorder(
				  											borderRadius: BorderRadius.circular(20.0)
				  										)
				  									),
				  								),
				  							),
				  							Padding(
				  								padding: EdgeInsets.all(10.0),
				  								child: TextFormField(
				  									onSaved: (value) {
				  										_user.address = value;
				  									},
				  									validator: (value) {
				  										if(value.length==0)
				  											return 'Enter Valid Address';
				  										else if(value.length>50)
				  											return 'Address cannot be greater than 50 Characters';
				  										else
				  											return null;
				  									},
				  									decoration: InputDecoration(
				  										labelText: 'Address',
				  										errorStyle: TextStyle(color: Colors.red),
				  										border: OutlineInputBorder(
				  											borderRadius: BorderRadius.circular(20.0)
				  										)
				  									),
				  								),
				  							),

				  							Padding(
				  								padding: EdgeInsets.all(10.0),
				  								child: Center(
				  									child: RaisedButton(
				  										child: _isLoading?Loading(indicator: BallPulseIndicator(),size: 10.0,):Text('Submit'),
				  										color: Colors.blue,
				  										onPressed: _isLoading?() {}:saveAndUpload,
				  										shape: RoundedRectangleBorder(
				  											borderRadius: BorderRadius.circular(20.0),
				  										),
				  									),
				  								),
				  							)
				  						],
				  					),
				  				),
				  			)
				  		],
				  	),
				  ),
				),
			),
		);
	}

	Future<void> saveAndUpload() async {
		if(_profileForm.currentState.validate()) {
			setState(() {
				_isLoading = true;
			});
			_profileForm.currentState.save();
			print(_user.bloodType);
			_user.bloodType=m[_user.bloodType];
			await Firestore.instance.collection('user').add(_user.toMap()).then((docRef) {
				_user.documentId = docRef.documentID;
			});
			FirebaseAuth auth = FirebaseAuth.instance;
			FirebaseUser tempUser = await auth.currentUser();
			Firestore.instance.collection('user').document(_user.documentId).updateData({'uid': tempUser.uid});
			// Firestore.instance.collection('user').document(_user.documentId).updateData({'bloodType': _user.bloodType});
			for(String topic in myTopics)
				Home.fcm.subscribeToTopic(m[topic]);

			Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Home(_user)), (Route<dynamic> route) => false);
		}
	}
}
