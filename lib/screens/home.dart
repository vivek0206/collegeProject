import 'dart:async';
import 'dart:convert';

import 'package:auto_animated/auto_animated.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_group_sliver/flutter_group_sliver.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sale_spot/classes/product.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:sale_spot/screens/cart.dart';
import 'package:sale_spot/screens/chooseCategory.dart';
import 'package:sale_spot/screens/editProfile.dart';
import 'package:sale_spot/screens/emergencyMsg.dart';
import 'package:sale_spot/screens/product_detail.dart';
import 'package:sale_spot/screens/promote.dart';
import 'package:sale_spot/screens/subCategory.dart';
import 'package:sale_spot/services/manualTools.dart';
import 'package:sale_spot/services/shimmerLayout.dart';
import 'package:sale_spot/services/slideTransition.dart';
import 'package:sale_spot/services/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'emergencyNotification.dart';
import 'faq.dart';
import 'feedback.dart';
import 'myProductList.dart';
import 'login.dart';
import 'package:sale_spot/screens/Emergency.dart';

class Home extends StatefulWidget {
	User _user;
	Home(this._user);
	static FirebaseMessaging fcm = FirebaseMessaging();
	static Firestore db = Firestore.instance;
	@override
	_HomeState createState() => _HomeState(_user);
}

class _HomeState extends State<Home> {
	User _user;
	_HomeState(this._user);

	GoogleSignIn _googleSignIn = GoogleSignIn();



	String token;
	GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
	int adminFlag=0;
	void initState() {
		super.initState();
		checkDbAccess();
		checkForBlock();
		storeSharedPreferences();
		checkAdmin();
		Home.fcm.configure(
			onMessage: (Map<String, dynamic> message) async {
				print('onMessage: $message');
				String mblood=((message['notification']['title']).split(' '))[2];
				showDialog(
					context: context,
					builder: (context) => AlertDialog(
						content: ListTile(
							title: Text(BloodMap.StringToBlood[mblood]),
							subtitle: Text(message['notification']['body']),
						),
						actions: <Widget>[
							FlatButton(
								child: Text('Ok'),
								onPressed: () => Navigator.of(context).pop(),
							),
						],
					),
				);
			},
			onResume: (Map<String, dynamic> message) async {
				print('onResume: $message');
			},
			onLaunch: (Map<String, dynamic> message) async {
				print('onLaunch: $message');
			},

		);
		getToken();
	}


	@override
	Widget build(BuildContext context) {
		Widget image_slider=new Container(
			height: MediaQuery.of(context).size.height*0.2,

			child:Carousel(
				boxFit: BoxFit.cover,
				dotSize: 4.0,
				indicatorBgPadding: 0.0,
				dotBgColor: Colors.transparent,
				overlayShadow: true,
				overlayShadowColors: Colors.red,
				animationCurve: Curves.fastOutSlowIn,
				images:[
					Container(
              decoration: BoxDecoration(
//							color: Colors.lightBlue,
							borderRadius: BorderRadius.all(Radius.circular(10))
					    ),
              height:100,
              width:100,
//              child:Image.asset('assets/images/slider_1.png'),
						child:Image.asset('assets/images/slider_2.png',fit: BoxFit.fitWidth,),
          ),
					Container(decoration: BoxDecoration(
//							color: Colors.blueAccent,
							borderRadius: BorderRadius.all(Radius.circular(10))
					),height:100,width:100,
						child:Image.asset('assets/images/slider_1.png',fit: BoxFit.fitWidth,),),
				],
				animationDuration: Duration(milliseconds: 2000),

			),
		);
		return Scaffold(
//			backgroundColor: Colors.white,
			key: _scaffoldKey,
//			appBar: AppBar (
//				backgroundColor: Color(int.parse('#0288D1'.replaceAll('#', '0xff'))),
//				elevation: 0.1,
//				title: new Text("SaleSpot",style:TextStyle(letterSpacing: 1.0,fontSize: 28.0),),
//				centerTitle: true,
//
//				flexibleSpace: Stack(children: <Widget>[
//					ListView(children: <Widget>[
//						SizedBox(height: 10.0),
//						Text('',
//								textAlign: TextAlign.center,
//								style: TextStyle(color: Colors.white, fontSize: 25.0)),
//						SizedBox(height: 25.0),
//						Container(
//
//							padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0,10.0),
//							color:Color(int.parse('#0288D1'.replaceAll('#', '0xff'))) ,
//							child: Container(
//								padding: EdgeInsets.symmetric(horizontal: 24),
//								height: 45,
//								decoration: BoxDecoration(
//										color: Color(0xffEFEFEF),
//										borderRadius: BorderRadius.circular(14)
//								),
//								child: InkWell(
//									onTap: (){
//										showSearch(context: context, delegate:SearchBar(_user) );
//									},
//									child: Row(
//										children: <Widget>[
//											Icon(Icons.search),
//											SizedBox(width: 10,),
//											Text("Search", style: TextStyle(
//													color: Colors.grey,
//													fontSize: 19
//											),)
//										],
//									),
//								),
//							),
//						),
//					])
//				]),
//
//        actions: <Widget>[
//          Padding(
//              padding: EdgeInsets.only(right: 20.0),
//              child: GestureDetector(
//                onTap: () {
////                  Navigator.pop(context);
//                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>Cart(_user)));
//                },
//                child: Icon(
//                  Icons.shopping_cart,
//                  size: 26.0,
//                ),
//              )
//          ),
//        ],
//
//			),
			drawer: Drawer(
				child: ListView(
					children: <Widget>[
						UserAccountsDrawerHeader(
//							decoration: BoxDecoration(
//								color: Colors.white70,
//							),

							accountEmail: Text(_user.email,style: TextStyle(color: Colors.white70),),
							accountName: Text(_user.name,style: TextStyle(color: Colors.white70),),
							currentAccountPicture: Container(
//								child: Image.network(userDetails.photoUrl),
								decoration: _user.photoUrl==null?BoxDecoration():BoxDecoration(
									shape: BoxShape.circle,
									image: DecorationImage(
										fit: BoxFit.fill,
										image: NetworkImage(_user.photoUrl)
									)
								),
							),
						),
						ListTile(
							leading: Icon(Icons.assignment_turned_in,),
							title: Text('Emergency Notification Panel'),
							onTap: () {
								Navigator.pop(context);

								Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>EmergencyNotification(_user)));
							},
						),

							adminFlag==1?ListTile(
							leading: Icon(Icons.assignment_turned_in,),
							title: Text('Send Emergency Msg'),
							onTap: () {
								Navigator.pop(context);
								Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>EmergencyMsg(_user)));
							},
						):Container(),
            ListTile(
              leading: Icon(Icons.assignment_turned_in,),
              title: Text('My Products'),
              onTap: () {
								Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>myProductList( _user)));
              },
            ),
						ListTile(
							leading: Icon(Icons.shopping_cart,),
							title: Text('Cart'),
							onTap: () {
								Navigator.pop(context);
								Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>Cart(_user)));
							},
						),
            ListTile(
              leading: Icon(Icons.call_made,),
              title: Text('Promote'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>Promote(_user)));
              },
            ),
						ListTile(
							leading: Icon(Icons.person),
							title: Text('Profile'),
							onTap: () {
								_openProfilePage(context);
							},
						),
						ListTile(
							leading: Icon(Icons.assignment),
							title: Text('Feedback'),
							onTap: () {
								Navigator.pop(context);
								Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>FeedBack(_user)));
							},
						),
						ListTile(
							leading: Icon(Icons.question_answer),
							title: Text('FAQ'),
							onTap: () {
								Navigator.pop(context);
								Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>Faq()));
							},
						),
						ListTile(
							leading: Icon(Icons.exit_to_app),
							title: Text('Log Out'),
							onTap: () {
								_googleSignIn.signOut();
								clearSharedPrefs();
								Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Login()), (Route<dynamic> route) => false);
							},
						),

					],
				),
			),
				body:	Container(
						height:screenHeight(context),
						width:screenWidth(context),
//						color: Colors.white,
						child:CustomScrollView(
								slivers:<Widget>[
									SliverAppBar(
											expandedHeight: 140.0,
											backgroundColor:Color(int.parse('0xff0288D1')),
											title: new Text("SaleSpot",style:TextStyle(letterSpacing: 1.0,fontSize: 28.0),),
											centerTitle: true,
											leading: IconButton(
													icon: Icon(LineIcons.navicon, color: Colors.white),
													onPressed: () {
														_scaffoldKey.currentState.openDrawer();
													}
											),
											floating: true,
											pinned: true,
											flexibleSpace: Stack(children: <Widget>[
												ListView(children: <Widget>[
													SizedBox(height: 10.0),
													Text('',
															textAlign: TextAlign.center,
															style: TextStyle(color: Colors.white, fontSize: 25.0)),
													SizedBox(height: 25.0),
													Container(

														padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0,10.0),
														color:Color(int.parse('#0288D1'.replaceAll('#', '0xff'))) ,
														child: Container(
															padding: EdgeInsets.symmetric(horizontal: 24),
															height: 45,
															decoration: BoxDecoration(
																	color: Color(0xffEFEFEF),
																	borderRadius: BorderRadius.circular(14)
															),
															child: InkWell(
																onTap: (){
																	showSearch(context: context, delegate:SearchBar(_user) );
																},
																child: Row(
																	children: <Widget>[
																		Icon(Icons.search),
																		SizedBox(width: 10,),
																		Text("Search", style: TextStyle(
																				color: Colors.grey,
																				fontSize: 19
																		),)
																	],
																),
															),
														),
													),
												])
											]),
										actions: <Widget>[
											Padding(
													padding: EdgeInsets.only(right: 20.0),
													child: GestureDetector(
														onTap: () {
															Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>Cart(_user)));
														},
														child: Icon(
															LineIcons.shopping_cart,
															size: 26.0,
														),
													)
											),
										],
									),

									SliverToBoxAdapter(
										child: Container(
											color: Colors.white,
										  child: ListTile(
//										  	leading: Icon(Icons.apps),
										  		title:Text("Category",style: TextStyle(fontSize: 18,color: Colors.black87.withOpacity(0.7),fontWeight: FontWeight.w500),),

										  	),
										),

									),

//										SliverPadding(
//												padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
//												sliver: _categoryData(context),
//										),

									SliverGroupBuilder(
										decoration: BoxDecoration(
											color: Colors.white,
//												borderRadius: BorderRadius.all(Radius.circular(2)),
//												border: Border.all(color: Color.fromRGBO(238, 237, 238, 1))
										),


										child:SliverPadding(
											padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 20.0),
											sliver: _categoryData(context),
										),
									),
									SliverToBoxAdapter(
										child: Padding(
										  padding: const EdgeInsets.all(8.0),
										  child: Container(
//											color: Colors.white,

										  	child: image_slider
										  ),
										),

									),
									SliverToBoxAdapter(

                    child: Container(
//                        color: Colors.white,
												height:50.0,
                        margin: EdgeInsets.symmetric(horizontal:10.0,vertical: 2.0),
                        decoration: BoxDecoration(
                          color: Color(int.parse('#94C4F4'.replaceAll('#', '0xff'))) ,
												borderRadius: BorderRadius.all(Radius.circular(10)),
												
                        ),
												child:Image.asset('assets/images/r1.png',fit: BoxFit.fitHeight,),
//                      child: ListTile(
//                        title:Text("Recommended For You",style: TextStyle(fontSize: 18,color: Colors.black87,fontWeight: FontWeight.w500),),
//
//                      )
                    ),

									),

//									SliverPadding(
//										padding: EdgeInsets.only(top: 0.0),
//										sliver: _productList(),
//									),
									SliverGroupBuilder(
										decoration: BoxDecoration(
//											color: Colors.grey[100],
//												borderRadius: BorderRadius.all(Radius.circular(2)),
//												border: Border.all(color: Color.fromRGBO(238, 237, 238, 1))
										),
										child:SliverPadding(
										padding: EdgeInsets.only(top: 0.0),
										sliver: _productList(),
									),
									),

								]
						)
				),

				floatingActionButton: FloatingActionButton(
//					backgroundColor: Colors.blue,
					onPressed: () {
//						Navigator.push(context,SlideBottomRoute( page:ChooseCategory( _user)));
						Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>ChooseCategory(_user)));
					},
//					child: Icon(Icons.add,color: Colors.white,),
						child: Text("SELL",style: TextStyle(
							fontSize: 15.0,
							color: Colors.white,
						),),
		),



		);

	}


	_openProfilePage(BuildContext context) async{
		_user=await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>EditProfile(_user)));
	}
	Widget headerCategoryItem(String name,String iconUrl,String documentId) {
		return GestureDetector(
				onTap: () {
//					Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>SubCategory(documentId,name, _user)));
					Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>SubCategory(documentId,name, _user,"visitPost")));
				},
				child: Container(
//					color: Colors.lightBlueAccent,
					decoration: BoxDecoration(
//						color: Colors.red,

//						border: Border.all(color: Colors.grey,width: 0.1),
//						borderRadius: BorderRadius.all(
//								Radius.circular(10.0) //                 <--- border radius here
//						),

					),

					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						crossAxisAlignment: CrossAxisAlignment.center,
						children: <Widget>[
							SizedBox(
								height: screenHeight(context)/15,
								child:Center(
//																	color:Colors.blueGrey,
									child: networkImageWithoutHeightConstraint(iconUrl),
								),

							),
//
							Padding(
							  padding: EdgeInsets.only(top: 5.0),
							  child: SizedBox(
							  	height: screenHeight(context)/30,
//							  	child:Text("Study Material1",maxLines:3),
//									child:Text(name,maxLines:3),
//										child: autoSizeText('Study Material1233333333333333', 2,15.0)
//										child: autoSizeText(name, 3,13.0,Colors.black54)
									child:autoSizeText(name, 2, 15.0, Colors.black54)
							  ),
							),
						],
					),
				)

		);
	}

	void clearSharedPrefs() async {
		final SharedPreferences prefs = await SharedPreferences.getInstance();
		prefs.setString('storedObject', '');
		prefs.setString('storedId', '');
		prefs.setString('storedPhoto', '');
	}

	void storeSharedPreferences() async {
		final SharedPreferences prefs = await SharedPreferences.getInstance();
		prefs.setString('storedObject', json.encode(_user.toMap()));
		prefs.setString('storedId', _user.documentId);
		prefs.setString('storePhoto', _user.photoUrl);
	}

	final scrollController = ScrollController();
//	final Delay listShowItemDuration = Duration(milliseconds: 250);
	Widget _categoryData(BuildContext context){

		return StreamBuilder<QuerySnapshot>(
			stream: Firestore.instance.collection('category').snapshots(),
			builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
				//print(snapshot.data);
				  if(!snapshot.hasData) {
				    return SliverList(
							delegate:SliverChildBuilderDelegate(( BuildContext context, int index) {
							return Column(
								children: <Widget>[
//									CircularProgressIndicator(),
										Container(),
								],

							);

						},
								childCount:1,
						)
						);
				  }

				return SliverGrid(

//					controller: scrollController,
//					delay: Duration(milliseconds: 250),
//					itemCount: snapshot.hasData ? snapshot.data.documents.length : 0,
//					gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//							childAspectRatio: 0.9,
//							maxCrossAxisExtent: 100.0,
//							mainAxisSpacing: 0.5,
//							crossAxisSpacing: 0.5,
//					),
//				itemBuilder:(BuildContext context, int index, Animation<double> animation,){
//					DocumentSnapshot ds = snapshot.data.documents[index];
//							return FadeTransition(
//								opacity: Tween<double>(begin: 0, end: 1,).animate(animation),
//							// And slide transition
//								child: SlideTransition(
//									position: Tween<Offset>(
//									begin: Offset(0, -0.1),
//									end: Offset.zero,
//									).animate(animation),
//								// Paste you Widget
//									child: FutureBuilder<dynamic> (
//										future: FirebaseStorage.instance.ref().child('categoryIcon').child(ds['name']+'.png').getDownloadURL(),
//										builder: (BuildContext context,AsyncSnapshot<dynamic> asyncSnapshot) {
//											String iconUrl=asyncSnapshot.data.toString();
//											//print(iconUrl+"*");
//											if(iconUrl=='null')
//												return Padding(
//													padding: const EdgeInsets.all(8.0),
//													child: shimmerCategory(context,screenHeight(context)/20,screenWidth(context)/5),
//												);
//											return Card(
//													elevation: 0.0,
//													child:headerCategoryItem(ds['name'],iconUrl, snapshot.data.documents[index].documentID.toString()),
//											);
//										},
//									),
//								),
//							);
//				},

					gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
						childAspectRatio: 0.9,
						maxCrossAxisExtent: 100.0,
						mainAxisSpacing: 0.5,
						crossAxisSpacing: 0.5,
					),
					delegate: SliverChildBuilderDelegate((BuildContext context, int index){
						DocumentSnapshot ds = snapshot.data.documents[index];
						//print(ds['iconId']);
						return FutureBuilder<dynamic> (
							future: FirebaseStorage.instance.ref().child('categoryIcon').child(ds['name']+'.png').getDownloadURL(),
							builder: (BuildContext context,AsyncSnapshot<dynamic> asyncSnapshot) {
								String iconUrl=asyncSnapshot.data.toString();
								//print(iconUrl+"*");
								if(iconUrl=='null')
									return Padding(
										padding: const EdgeInsets.all(8.0),
										child: shimmerCategory(context,screenHeight(context)/15,screenWidth(context)/5),
//											child:Container()
									);
								return Card(
										elevation: 0.0,
										child:headerCategoryItem(ds['name'],iconUrl, snapshot.data.documents[index].documentID.toString()),
								);
							},
						);
					},
						childCount: snapshot.hasData ? snapshot.data.documents.length : 0,
					),
				);
			},
		);

	}

	_productList(){
		return StreamBuilder(
				stream:Firestore.instance.collection('product').where('soldFlag',isEqualTo: '0').where('waitingFlag',isEqualTo: '0').orderBy('priority',descending: true).limit(10).snapshots(),
				builder:(BuildContext context,AsyncSnapshot<QuerySnapshot> querySnapshots){
					if(!querySnapshots.hasData)
						return SliverList(
								delegate:SliverChildBuilderDelegate(( BuildContext context, int index) {
									return Column(
										children: <Widget>[
//											CircularProgressIndicator(),
												Container(),
										],
									);
								},
									childCount:1,
								)
						);
					return SliverGrid(
						gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2 ,childAspectRatio: 0.75,crossAxisSpacing: 2.0,mainAxisSpacing: 2.0),

							delegate: SliverChildBuilderDelegate((BuildContext context, int index){
//							print(querySnapshots.data.documents.length.toString()+'  document');
							DocumentSnapshot documentSnapshot=querySnapshots.data.documents[index];
							Product product=Product.fromMapObject(documentSnapshot.data);
							product.productId=documentSnapshot.documentID;
							double salePrice=double.parse(product.salePrice);
							double originalPrice=double.parse(product.originalPrice);
							double discount;
							String discountPercentage;
							String originalPriceText;
							if(originalPrice!=0){
								originalPriceText=rupee()+product.originalPrice;
								discount=1-(salePrice/originalPrice);
								discountPercentage=(discount*100).round().toString()+'% off';
							}
							else{
								originalPriceText='';
								discountPercentage='';
							}

							return FutureBuilder(
									future: FirebaseStorage.instance.ref().child(product.productId.toString()+'1').getDownloadURL(),
									builder: (BuildContext context,AsyncSnapshot<dynamic> downloadUrl){
										String currUrl=downloadUrl.data.toString();
										if(!downloadUrl.hasData)
											return Padding(
												padding: const EdgeInsets.all(8.0),
												child: shimmerLayout(context),
											);
										return InkWell(
											onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>ProductDetail(product.productId, _user))); },
											child:new Card(
												shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
												elevation: 0.0,
												child: Column(
													mainAxisSize: MainAxisSize.min,
													mainAxisAlignment: MainAxisAlignment.center,
													children: <Widget>[
														Container(
														  padding: EdgeInsets.only(bottom:8.0),

//															child: networkImageHeightWidth(currUrl,screenHeight(context)/4.5,screenWidth(context)/2.5),
														  child: ClipRRect(
														  	borderRadius: BorderRadius.circular(8.0),
														    child: networkImageHeightWidth(currUrl,screenHeight(context)/4.5,screenWidth(context)/2.5),
														  ),
														),

														SizedBox(
															height: screenWidth(context)/20,
															child:autoSizeText(product.title, 1, 15.0, Colors.black87),
														),
														Row(
														mainAxisAlignment: MainAxisAlignment.center,
														children: <Widget>[
															Text(
															rupee()+product.salePrice,
																style: TextStyle(fontSize: 18.0, color: Colors.black87),
															),
															SizedBox(
																width: 8.0,
															),
															Text(
																originalPriceText,
																style: TextStyle(
																	fontSize: 15.0,
																	color: Colors.grey,
																	decoration: TextDecoration.lineThrough,
																),
															),
															SizedBox(
																width: 8.0,
															),

															Text(
															discountPercentage,
																style: TextStyle(
																	fontSize: 12.0,
																	color: Colors.green[700],
																),
															),

														],
													),


													],
												),

											),
										);
									}
							);


						},
							childCount: querySnapshots.hasData ? querySnapshots.data.documents.length : 0,),

					);
				}

		);
	}

		Widget buildHeader(String text){
			return SliverList(
				delegate: SliverChildListDelegate([Container(
					margin: EdgeInsets.all(5),
					padding: EdgeInsets.all(15),
					decoration: BoxDecoration(
//															border: Border.all(color: Colors.grey,width: 0.5),
						color: Colors.white,
						borderRadius: BorderRadius.all(
								Radius.circular(10.0) //                 <--- border radius here
						),
					),

					child: Text(text,style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.bold),),
				)]
				),
			);

		}

		void getToken() async {
			token = await Home.fcm.getToken();
			Firestore.instance.collection('user').document(_user.documentId).updateData({'token': token});
		}

		void checkForBlock() async {
		var newData = await Firestore.instance.collection('user').document(_user.documentId).get();
		if(newData.data['blockedNo'] > 2) {
			_googleSignIn.signOut();
			clearSharedPrefs();
			Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Login()), (Route<dynamic> route) => false);
		}
		}



	void checkDbAccess() async {
		Stream<DocumentSnapshot> userP = Firestore.instance.collection('db').document('zMLNFMLPBdRdTLwhEzvI').snapshots();
		userP.listen((DocumentSnapshot value) {
			if(value != null) {
				print(value.data.toString());
				if(!value['dbEnabled'])
					dbDisabled();
			}
		});
	}

	Future<void> dbDisabled() async {
		return showDialog<void>(
			context: context,
			barrierDismissible: false,
			builder: (BuildContext context) {
				return AlertDialog(
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.all(Radius.circular(20.0))
					),
					title: Text('Under Maintenance', style: TextStyle(color: Colors.red),),
					content: Text('Please retry after some time.'),
					actions: <Widget>[
						RaisedButton(
							child: Text('Okay'),
							color: Colors.cyan[300],
							onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.all(Radius.circular(20.0))
							),
						)
					],
				);
			}
		);
	}

  Future<void> checkAdmin() async {
		QuerySnapshot snapshot1 = await Firestore.instance.collection('admin')
				.where('email', isEqualTo: _user.email)
				.getDocuments();
		if (snapshot1.documents.length != 0) {
			setState(() {
				adminFlag=1;
			});
		} else {
			setState(() {
				adminFlag=0;
			});
		}

	}



}

class SearchBar extends SearchDelegate<String>{

	User _user;
	SearchBar(this._user);
	String _sortValue='date';
	var recent=['Search for products'];


	ThemeData appBarTheme(BuildContext context) {
		assert(context != null);
		final ThemeData theme = Theme.of(context);

		assert(theme != null);
		return theme.copyWith(

			primaryColor: Colors.white,
			primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.cyan[700]),
			primaryColorBrightness: Brightness.light,
			textTheme: theme.textTheme.copyWith(
					title: TextStyle(fontWeight: FontWeight.normal,fontSize: 18.0)),
		);


	}
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
    	IconButton(
				icon:Icon(Icons.clear),
				onPressed: (){
					query="";
				},
			)
		];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
				icon:AnimatedIcon(
						icon: AnimatedIcons.menu_arrow,
						progress: transitionAnimation
				),
				onPressed:(){
					close(context, null);
				});
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults

    return StatefulBuilder(
				builder: (BuildContext context,StateSetter setState){
					print(_sortValue+"xxx");
					return Scaffold(
						body:FutureBuilder(
							future: Firestore.instance.collection('product')
													.where('soldFlag',isEqualTo: '0').where('waitingFlag',isEqualTo: '0')
//												.orderBy(_sortValue)
													.where('title',isGreaterThanOrEqualTo: query)
													.where('title',isLessThan: query+'z')
													.getDocuments(),
							builder: (context,products){
								if(!products.hasData || products.data.documents.length==0)
									return Container();
//        print(products.data+'   Hello');
//								int similarProductsCount=products.data.documents.length;
//								print(similarProductsCount.toString()+products.data.documents[0].documentID.toString());
								return GridView.builder(
										itemCount: products.data.documents.length,
										gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 0.8),
										itemBuilder: (BuildContext context,int index){

											Product pd;
											pd=Product.fromMapObject(products.data.documents[index].data);
											pd.productId=products.data.documents[index].documentID.toString();

											double salePrice=double.parse(pd.salePrice);
											double originalPrice=double.parse(pd.originalPrice);
											double discount;
											String discountPercentage;
											String originalPriceText;
											if(originalPrice!=0){
												originalPriceText=rupee()+pd.originalPrice;
												discount=1-(salePrice/originalPrice);
												discountPercentage=(discount*100).round().toString()+'% off';
											}
											else{
												originalPriceText='';
												discountPercentage='';
											}
//								if(similarProduct.productId==_productContent.productId){
//									return Container();
//								}
											return FutureBuilder(
												future: FirebaseStorage.instance.ref().child(pd.productId+'1').getDownloadURL(),
												builder: (BuildContext context,AsyncSnapshot<dynamic> urls){
													if(!urls.hasData)
														return Padding(
														  padding: const EdgeInsets.all(8.0),
														  child: shimmerLayout(context),
														);
													String currUrl=urls.data.toString();
													return GridTile(
															child:Container(
//									decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
																child: InkWell(
																	onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>ProductDetail(pd.productId, _user))); },
																	child:new Card(
																		shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
																		elevation: 0.3,
																		child: Column(
																			mainAxisSize: MainAxisSize.min,
																			mainAxisAlignment: MainAxisAlignment.center,
																			children: <Widget>[
																				Padding(
																					padding: EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
																					child: ClipRRect(
																						borderRadius: BorderRadius.circular(8.0),
																						child: networkImage(currUrl,screenHeight(context)/5),
																					),
																				),

																				SizedBox(
																					height: screenWidth(context)/20,
																					child:autoSizeText(pd.title, 1, 15.0, Colors.black87),
																				),

																				Row(
																					mainAxisAlignment: MainAxisAlignment.center,
																					children: <Widget>[
																						Text(
																							rupee()+pd.salePrice,
																							style: TextStyle(fontSize: 18.0, color: Colors.black87),
																						),
																						SizedBox(
																							width: 8.0,
																						),
																						Text(
																							originalPriceText,
																							style: TextStyle(
																								fontSize: 15.0,
																								color: Colors.grey,
																								decoration: TextDecoration.lineThrough,
																							),
																						),
																						SizedBox(
																							width: 8.0,
																						),

																						Text(
																							discountPercentage,
																							style: TextStyle(
																								fontSize: 12.0,
																								color: Colors.green[700],
																							),
																						),

																					],
																				),


																			],
																		),

																	),
																),
															)
													);
												},
											);

										});
//        return Row();
							},
						),

//						floatingActionButton: FloatingActionButton(
//							onPressed: () {
//								_sortOption(context,setState);
//
//							},
//							child: Icon(Icons.sort),
//							backgroundColor: Colors.cyan,
//						),
					);
				});
  }

  @override
  Widget buildSuggestions(BuildContext context) {

			if(query.isEmpty)
				{
					return ListView.builder(itemBuilder: (context,index)=>ListTile(
								title: Text(recent[index],textAlign:TextAlign.center,),
							),
								itemCount: recent.length,
							);
				}
			_sortValue='date';
			return StreamBuilder(
					stream:Firestore.instance.collection('product').where('soldFlag',isEqualTo: '0').where('waitingFlag',isEqualTo: '0')
							.where("title",isGreaterThanOrEqualTo: query)
							.where("title",isLessThanOrEqualTo: query+"z")
							.snapshots(),
					builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> querySnapshots){
						if(!querySnapshots.hasData || querySnapshots.data.documents.length==0) {
//            print(querySnapshots);
							return ListView.builder(itemBuilder: (context,index)=>ListTile(
								title: Text(recent[index]),
							),
								itemCount: recent.length,
							);
						}
						return new ListView(
							children: querySnapshots.data.documents.map((document) {
								return ListTile(
								  title: Text(document['title']),
									onTap: (){
								  	query=document['title'];
									},
								);


							}).toList(),
						);

					});
  }

	_sortOption(context,StateSetter setState){
		showModalBottomSheet(
				context: context,
				builder: (BuildContext bc) {
					return Container(
						child: new Wrap(
							children: <Widget>[
								Padding(
									padding:EdgeInsets.symmetric(vertical:15.0),
									child: Center(
										child: Text('Sort By',
											style: TextStyle(
												fontSize: 15.0,
												color: Colors.black45,
												letterSpacing: 1.0,
											),
										),
									),
								),
								SizedBox(
									height: 0,
									child:Divider(
										color: Colors.black54,
									),

								),
								RadioListTile(
									value: 'date',
									groupValue: _sortValue,
									onChanged: (newValue) =>
											setState(() {
												_sortValue = newValue;

//															query='';
												Navigator.pop(context);
											}),
									title: Text("Latest Added"),
									activeColor: Colors.red,
									selected: false,
								),
								RadioListTile(
									value: 'salePrice',
									groupValue: _sortValue,
									onChanged: (newValue) =>
											setState(() {
												_sortValue = newValue;
//															setState(() {
//
//															});
//															query='';
												Navigator.pop(context);
											}),
									title: Text("Price"),
									activeColor: Colors.red,
									selected: false,
								)

							],
						),
					);
				}
		);
	}
}




