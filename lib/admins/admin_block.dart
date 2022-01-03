import 'package:flutter/material.dart';
import 'package:mny_champ/admins/admin_sub_payment_details.dart';
import 'package:mny_champ/admins/alert_users.dart';
import 'package:mny_champ/admins/app_users.dart';
import 'package:mny_champ/admins/share_text.dart';
import 'package:mny_champ/admins/subscribed_users.dart';
import 'package:mny_champ/admins/unsubscribed_users.dart';

class AdminBlock extends StatefulWidget {
  final String currentPlan;

  AdminBlock({required this.currentPlan});

  @override
  _AdminBlockState createState() => _AdminBlockState();
}

class _AdminBlockState extends State<AdminBlock> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.orangeAccent),
                accountName: Text('Admin'),
                accountEmail: Text('9416136562'),
                currentAccountPicture: InkWell(
                  child: Container(
                      width: 150.0,
                      height: 150.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                              image: AssetImage('images/AboutUs/developer.png'),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.all(Radius.circular(75.0)),
                          boxShadow: [
                            BoxShadow(blurRadius: 20.0, color: Colors.white)
                          ])),
                ),
                otherAccountsPictures: <Widget>[
                  Container(
                      child: Text(widget.currentPlan.toUpperCase()),
                      width: 150.0,
                      height: 150.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(75.0)),
                          boxShadow: [
                            BoxShadow(blurRadius: 20.0, color: Colors.white)
                          ]))
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SubscribedUsers(currentPlan: widget.currentPlan)));
                },
                child: ListTile(
                  title: Text('Subscribed Users'),
                  leading: Icon(
                    Icons.verified_user,
                    color: Colors.green,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UnSubscribedUsers()));
                },
                child: ListTile(
                  title: Text('UnSubscribed Users'),
                  leading: Icon(
                    Icons.live_help,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AppUsers()));
                },
                child: ListTile(
                  title: Text('Total Users'),
                  leading: Icon(
                    Icons.person_pin,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SubPaymentDetails()));
                },
                child: ListTile(
                  title: Text('Subscription Payments'),
                  leading: Icon(
                    Icons.monetization_on,
                    color: Colors.green,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SubPaymentDetails()));
                },
                child: ListTile(
                  title: Text('CheckOut Payments'),
                  leading: Icon(
                    Icons.monetization_on_outlined,
                    color: Colors.red,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AlertUsers()));
                },
                child: ListTile(
                  title: Text('Alert All'),
                  leading: Icon(
                    Icons.notifications_active,
                    color: Colors.blue,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ShareText()));
                },
                child: ListTile(
                  title: Text('Share Text'),
                  leading: Icon(
                    Icons.share,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 60, top: 60),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 10),
                Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.3,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                            image: AssetImage('images/logo.png'),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.all(Radius.circular(75.0)),
                        boxShadow: [
                          BoxShadow(blurRadius: 20.0, color: Colors.white)
                        ])),
                SizedBox(height: 20),
                Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                            image: AssetImage('images/AboutUs/developer.png'),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.all(Radius.circular(75.0)),
                        boxShadow: [
                          BoxShadow(blurRadius: 20.0, color: Colors.white)
                        ])),
              ],
            ),
          ),
        ));
  }
}
