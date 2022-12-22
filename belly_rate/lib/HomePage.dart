import 'dart:io';
import 'package:belly_rate/models/restaurantModesl.dart';
import 'package:belly_rate/models/user.dart';
import 'package:belly_rate/views/carousel_loading.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_parts/category_slider.dart';
import 'category_parts/restaurant_model.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  var currentIndex = 0;
  void initState() {
    super.initState();
    get();
  }

  static late UserInfoModel user;
  static List<restaurantModel> restaurants = [];
  static List<String> restaurantsImgs = [];

  get() async {
    final res = await FirebaseFirestore.instance
        .collection('Users')
        .where('uid', isEqualTo: "mCfCKtGUGgWbQAEhpLtAWwMI7MG3")
        .get();
    user = UserInfoModel(
        uid: res.docs[0]['uid'],
        phoneNumber: res.docs[0]['phoneNumber'],
        firstName: res.docs[0]['firstName'],
        lastName: res.docs[0]['lastName'],
        photo: res.docs[0]['picture'],
        recommendedRestaurant: res.docs[0]['rest']);

    for (int i = 0; i < user.recommendedRestaurant.length; i++) {
      final restt = await FirebaseFirestore.instance
          .collection('Restaurants')
          .where('ID', isEqualTo: user.recommendedRestaurant[i])
          .get();

      restaurantModel restaurant = restaurantModel(
          phoneNumber: restt.docs[0]['phoneNumber'],
          category: restt.docs[0]['category'],
          description: restt.docs[0]['description'],
          location: restt.docs[0]['location'],
          name: restt.docs[0]['name'],
          photos: restt.docs[0]['photos'],
          priceAvg: restt.docs[0]['priceAvg'],
          resId: restt.docs[0]['ID']);
      setState(() {
        restaurants.add(restaurant);
        restaurantsImgs.add(restaurant.photos[0]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double displayOfWidth = MediaQuery.of(context).size.width;
    var x = 0;
    final List<Widget> imageSliders = restaurantsImgs
        .map((item) => Container(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                margin: EdgeInsets.all(2.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    child: Stack(
                      children: <Widget>[
                        Image.network(item, fit: BoxFit.cover, width: 1000.0),
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(200, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            child: Text(
                              restaurants[x++].name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ))
        .toList();
    List<Widget> listOfWidgets = [
      //home page container
      Container(
          child: Column(
        children: [
          SizedBox(
            height: 100,
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Recommended Restaurants",
                  style: TextStyle(
                      color: Color(0xFF5a3769),
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              )),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Saudi Arabia, Riyadh",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              )),
          (restaurants.isEmpty == true)
              ? CarouselLoading()
              : Container(
                  child: CarouselSlider(
                  options: CarouselOptions(
                    aspectRatio: 16 / 9,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    initialPage: 0,
                    autoPlay: true,
                  ),
                  items: imageSliders,
                )),
          SizedBox(
            height: 20,
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Discover Restaurants",
                  style: TextStyle(
                      color: Color(0xFF5a3769),
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              )),
          CategorySlider(),
          SizedBox(
            height: 10,
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Near you",
                  style: TextStyle(
                      color: Color(0xFF5a3769),
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              )),
        ],
      )),
      //Favorite page container
      Container(child: Text('Favorite')),
      //History page container
      Container(child: Text('History')),
      //Profile page container
      Container(child: Text('Profile')),
    ];
    List<IconData> listOfIcons = [
      Icons.home_rounded,
      Icons.favorite_rounded,
      Icons.history_rounded,
      Icons.person_rounded,
    ];

    List<String> listOfStrings = [
      'Home',
      'Favorite',
      'History',
      'Profile',
    ];

    return Scaffold(
      body: Center(child: listOfWidgets[currentIndex]),
      bottomNavigationBar: Container(
          margin: EdgeInsets.all(displayOfWidth * .05),
          height: displayOfWidth * .155,
          decoration: BoxDecoration(
              color: Colors.white70,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.07),
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
              borderRadius: BorderRadius.circular(50)),
          child: ListView.builder(
              itemCount: 4,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: displayOfWidth * .02),
              itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      setState(() {
                        currentIndex = index;
                        HapticFeedback.lightImpact();
                      });
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Stack(children: [
                      AnimatedContainer(
                        duration: Duration(seconds: 1),
                        curve: Curves.fastLinearToSlowEaseIn,
                        width: index == currentIndex
                            ? displayOfWidth * .32
                            : displayOfWidth * .18,
                        alignment: Alignment.center,
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          curve: Curves.fastLinearToSlowEaseIn,
                          height:
                              index == currentIndex ? displayOfWidth * .12 : 0,
                          width:
                              index == currentIndex ? displayOfWidth * .32 : 0,
                          decoration: BoxDecoration(
                            color: index == currentIndex
                                ? Color(0xFFae96e82).withOpacity(.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(seconds: 1),
                        curve: Curves.fastLinearToSlowEaseIn,
                        width: index == currentIndex
                            ? displayOfWidth * .31
                            : displayOfWidth * .18,
                        alignment: Alignment.center,
                        child: Stack(children: [
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: Duration(seconds: 1),
                                curve: Curves.fastLinearToSlowEaseIn,
                                width: index == currentIndex
                                    ? displayOfWidth * .13
                                    : 0,
                              ),
                              AnimatedOpacity(
                                opacity: index == currentIndex ? 1 : 0,
                                duration: Duration(seconds: 1),
                                curve: Curves.fastLinearToSlowEaseIn,
                                child: Text(
                                  index == currentIndex
                                      ? '${listOfStrings[index]}'
                                      : '',
                                  style: TextStyle(
                                    color: Color(0xFFae96e82),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: Duration(seconds: 1),
                                curve: Curves.fastLinearToSlowEaseIn,
                                width: index == currentIndex
                                    ? displayOfWidth * .03
                                    : 20,
                              ),
                              Icon(
                                listOfIcons[index],
                                size: displayOfWidth * .076,
                                color: index == currentIndex
                                    ? Color(0xFFae96e82)
                                    : Colors.black26,
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ]),
                  ))),
    );
  }
}
