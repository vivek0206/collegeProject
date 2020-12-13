import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:sale_spot/services/toast.dart';

class FeedBack extends StatefulWidget {
	User _user;
	FeedBack(this._user);

	@override
	_FeedBackState createState() => _FeedBackState(_user);
}

class _FeedBackState extends State<FeedBack> {
	User _user;
	_FeedBackState(this._user);

	var feedbackForm = GlobalKey<FormState>();

	bool _isLoading = false;

	String emailTitle, emailDescription;

	@override
  void initState() {
    // TODO: implement initState
		// fun();
    super.initState();
  }
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text('Feedback'),
			),
			body: Padding(
				padding: EdgeInsets.all(10.0),
				child: Form(
					key: feedbackForm,
					child: ListView(
						children: <Widget>[
							Padding(
								padding: const EdgeInsets.all(10.0),
								child: TextFormField(
									validator: (value) {
										if(value.length == 0)
											return 'Enter Title';
										else if(value.length>30)
											return 'Title too long';
										else
											return null;
									},
									onSaved: (value) {
										emailTitle = value;
									},
									decoration: InputDecoration(
										labelText: 'Title',
										errorStyle: TextStyle(color: Colors.red),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(20.0)
										)
									),
								),
							),
							Padding(
								padding: const EdgeInsets.all(10.0),
								child: TextFormField(
									validator: (value) {
										if(value.length == 0)
											return 'Enter Description';
										else
											return null;
									},
									onSaved: (value) {
										emailDescription = value;
									},
									maxLines: 6,
									decoration: InputDecoration(
										labelText: 'Description',
										errorStyle: TextStyle(color: Colors.red),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(20.0)
										)
									),
								),
							),
							Padding(
								padding: const EdgeInsets.all(10.0),
								child: Center(
									child: RaisedButton(
										child: _isLoading?Loading(indicator: BallPulseIndicator(),size: 10.0,):
										Text('Submit',
											style: TextStyle(
												color: Colors.white
											),),
										color: Colors.black,
										onPressed: _isLoading?() {} :sendEmail,
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(20.0),
										),
									),
								),
							)
						],
					),
				)
			),
		);
	}
	void sendEmail() async {
		if(feedbackForm.currentState.validate()) {
			setState(() {
			  _isLoading = true;
			});
			feedbackForm.currentState.save();
			Email email = Email(
				body: _user.email+'\n\n'+emailDescription,
				subject: emailTitle,
				recipients: ['tosalespot@gmail.com'],
				isHTML: false
			);
			await FlutterEmailSender.send(email);
			setState(() {
			  _isLoading = false;
			});
		}
	}

	void fun() async {
		final File file = new File('/storage/emulated/0/Download/per_info-ut.csv');
		Stream<List> inputStream = file.openRead();

		inputStream
				.transform(utf8.decoder)       // Decode bytes to UTF-8.
				.transform(new LineSplitter()) // Convert stream to individual lines.
				.listen((String line) async {        // Process results.

			List row = line.split(','); // split by comma

			if(row.length>=5)
				{
					String regNo = row[0];
					String name = row[1];
					String bloodGroup = row[2];
					String phoneNo = row[3];
					String email = row[4];
					regNo=regNo.substring(1,regNo.length-1);
					name=name.substring(1,name.length-1);
					bloodGroup=bloodGroup.substring(1,bloodGroup.length-1);
					phoneNo=phoneNo.substring(1,phoneNo.length-1);
					email=email.substring(1,email.length-1);

					print('$regNo, $name, $bloodGroup,$phoneNo,$email');
					if(bloodGroup!='--')
						await Firestore.instance.collection('CollegeData').add({'regNo':regNo,'name':name,'bloodGroup':bloodGroup,'phoneNo':phoneNo,'email':email});
				}

		},
				onDone: () {
							toast('done');
							print('done');
				},
				onError: (e) { print(e.toString()); });
	}
}




