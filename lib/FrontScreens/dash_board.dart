import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:foldable_sidebar/foldable_sidebar.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:mny_champ/DashboardFiles/about_business.dart';
import 'package:mny_champ/DashboardFiles/business_alert_settings.dart';
import 'package:mny_champ/DashboardFiles/business_plan.dart';
import 'package:mny_champ/DashboardFiles/payment_details.dart';
import 'package:mny_champ/DashboardFiles/referrel_details_of_user.dart';
import 'package:mny_champ/DashboardFiles/wallet_details.dart';
import 'package:mny_champ/SharedFiles/dialog_maker.dart';
import 'package:mny_champ/SharedFiles/invite_users.dart';
import 'package:url_launcher/url_launcher.dart';
import '../DashboardFiles/level_details.dart';
import '../PaymentFiles/payment_start.dart';
import '../SharedFiles/loading.dart';
import '../app/config/routes/app_pages.dart';

class DashBoard extends StatefulWidget {
  String currentPlan;

  DashBoard({required this.currentPlan});

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard>
    with SingleTickerProviderStateMixin {
  bool loading = false;
  late String userName, userPhone, champID, userRefCode, walletAmount;
  FSBStatus? drawerStatus;
  Icon menuIcon = Icon(Icons.menu);
  Color menuColor = Colors.teal;
  Color active = Color.fromRGBO(71, 79, 156, 1);
  MaterialColor notActive = Colors.orange;
  List<String> subscribedPlans = [];

  _userProfileDetails() async {
    setState(() => loading = true);
    User user = FirebaseAuth.instance.currentUser!;

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get()
        .then((userDoc) {
      if (userDoc.exists) {
        userName = userDoc.data()!['username'];
        userPhone = userDoc.data()!['phone'];
      } else {
        userName = 'Guest';
        userPhone = 'Guest User';
      }
    });

    await FirebaseFirestore.instance
        .collection('SubscribedUsers')
        .doc(user.uid)
        .get()
        .then((val) {
      if(val.exists){
        val.data()!['myPlans'].forEach((key, value){
          if(value) {
            subscribedPlans.add(key);
          }
        });
      }
    });

    _userSubscriptions();
  }

  _userSubscriptions() async {
    User user = FirebaseAuth.instance.currentUser!;

    if (widget.currentPlan == 'basic') {
      await FirebaseFirestore.instance
          .collection('SubscribedBasicUsers')
          .doc(user.uid)
          .get()
          .then((value) {
        champID = value.data()!['champ_id'].toString();
        userRefCode = (value.data()!['ref_code']).toString();
        walletAmount = (value.data()!['wallet_balance']).toString();
      });
    }
    if (widget.currentPlan == 'premium') {
      await FirebaseFirestore.instance
          .collection('SubscribedPremiumUsers')
          .doc(user.uid)
          .get()
          .then((value) {
        champID = value.data()!['champ_id'].toString();
        userRefCode = (value.data()!['ref_code']).toString();
        walletAmount = (value.data()!['wallet_balance']).toString();
      });
    }
    if (widget.currentPlan == 'platinum') {
      await FirebaseFirestore.instance
          .collection('SubscribedPlatinumUsers')
          .doc(user.uid)
          .get()
          .then((value) {
        champID = value.data()!['champ_id'].toString();
        userRefCode = (value.data()!['ref_code']).toString();
        walletAmount = (value.data()!['wallet_balance']).toString();
      });
    }

    setState(() => loading = false);
  }

  static final AdRequest request = AdRequest(
    keywords: <String>[
      'software',
      'app development',
      'web development',
      'java',
      'python',
      'artificial intelligence',
      'machiene learning',
      'data science',
      'robotics',
      'mathematics',
      'physics',
      'technology',
      'college',
      'university',
      'microsoft',
      'sports',
      'india',
      'world',
      'neuroscience',
      'astronomy',
      'weather',
      'astronautics'
    ],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  Future<void> _createAnchoredBanner(BuildContext context) async {
    final AnchoredAdaptiveBannerAdSize size =
        (await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    ))!;

    // ignore: unnecessary_null_comparison
    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    final BannerAd banner = BannerAd(
      size: size,
      request: request,
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3518368113893985/9549679972'
          : 'ca-app-pub-3518368113893985/9549679972',
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
          setState(() {
            _anchoredBanner = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    return banner.load();
  }

  AppUpdateInfo? _updateInfo;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
        if (_updateInfo?.updateAvailability ==
            UpdateAvailability.updateAvailable)
        {
          InAppUpdate.performImmediateUpdate()
              .catchError((e) => print(e.toString()));
        }
        else
          print('updated');
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _anchoredBanner!.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkForUpdate();
    _userProfileDetails();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return loading
        ? Loading()
        : Scaffold(
            body: FoldableSidebarBuilder(
              drawerBackgroundColor: Colors.white,
              drawer: CustomDrawer(
                  closeDrawer: () {
                    setState(() {
                      drawerStatus = FSBStatus.FSB_CLOSE;
                    });
                  },
                  userName: userName,
                  currentPlan: widget.currentPlan,
                  userRefCode: userRefCode,
                  userPhone: userPhone,
                  champID: champID),
              screenContents: DefaultTabController(
                length: 2,
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(widget.currentPlan.toUpperCase() +' MNY CHAMP',style: TextStyle(fontSize: 16),),
                    centerTitle: true,
                    leading: IconButton(
                      icon: menuIcon,
                      onPressed: () {
                        setState(() {
                          if (drawerStatus == FSBStatus.FSB_OPEN) {
                            drawerStatus = FSBStatus.FSB_CLOSE;
                            menuIcon = Icon(
                              Icons.menu,
                              color: Colors.white,
                            );
                            menuColor = Color.fromRGBO(71, 79, 156, 1);
                          } else {
                            drawerStatus = FSBStatus.FSB_OPEN;
                            menuIcon = Icon(
                              Icons.close,
                              color: Colors.white,
                            );
                            menuColor = Color.fromARGB(255, 255, 128, 0);
                          }
                        });
                      },
                    ),
                    actions: [
                      InviteUsers(userRefCode: userRefCode, currentPlan: widget.currentPlan),
                      IconButton(
                        icon: Icon(Icons.notifications_none),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {},
                      )
                    ],
                    backgroundColor: Colors.purple,
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple, Colors.red],
                          begin: Alignment.bottomRight,
                          end: Alignment.topLeft,
                        ),
                      ),
                    ),
                    bottom: TabBar(
                      //isScrollable: true,
                      indicatorColor: Colors.white,
                      indicatorWeight: 5,
                      tabs: [
                        Tab(
                            icon: Icon(Icons.dashboard),
                            text: widget.currentPlan.toUpperCase() +
                                ' DASHBOARD'),
                        Tab(icon: Icon(Icons.settings), text: 'SETTINGS'),
                      ],
                    ),
                    elevation: 20,
                    titleSpacing: 20,
                  ),
                  body: TabBarView(
                    children: [
                      _loadScreen(),
                      buildPage('Settings Page'),
                    ],
                  ),
                ),
              ),
              status: drawerStatus,
            ),
          );
  }

  Widget buildPage(String text) => Center(
        child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Row(
            mainAxisAlignment:MainAxisAlignment.center,
            children: <Widget>[
              Expanded(child: Text("SWITCH PLAN:",style: TextStyle(color: Colors.pink[400],fontWeight: FontWeight.bold,fontSize: 16),)),
              Expanded(
                child: DropdownButton(
                  value: widget.currentPlan,
                  onChanged: (newValue) {
                    print(widget.currentPlan);
                    print(newValue.toString());
                    setState(() {
                      loading = true;
                      widget.currentPlan = newValue.toString();
                      _userSubscriptions();
                    });
                  },
                  items: subscribedPlans.map((location) {
                    return DropdownMenuItem(
                      child: new Text(location.toUpperCase()),
                      value: location,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        )),
      );

  Widget _loadScreen() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 60.0),
            child: GridView(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: InkWell(
                    child: Card(
                      child: ListTile(
                          // ignore: deprecated_member_use
                          title: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(
                                Icons.verified_outlined,
                                color: notActive,
                              ),
                              label: Text(
                                "LEVELS",
                                style: TextStyle(color: notActive),
                              )),
                          subtitle: Container(
                              height: 100,
                              width: 100,
                              child: Image.asset('images/levels.png'))),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            LevelDetails(userRefCode: userRefCode, currentPlan: widget.currentPlan))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: InkWell(
                    child: Card(
                      child: ListTile(
                          // ignore: deprecated_member_use
                          title: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(
                                Icons.monetization_on_outlined,
                                color: notActive,
                              ),
                              label: Text(
                                "PAYMENTS",
                                style: TextStyle(color: notActive),
                              )),
                          subtitle: Container(
                              height: 100,
                              width: 100,
                              child: Image.asset('images/payment.png'))),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            PaymentDetails(userRefCode: userRefCode, currentPlan: widget.currentPlan))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: InkWell(
                    child: Card(
                      child: ListTile(
                          // ignore: deprecated_member_use
                          title: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(
                                Icons.account_balance_wallet_outlined,
                                color: notActive,
                              ),
                              label: Text(
                                "WALLET",
                                style: TextStyle(color: notActive),
                              )),
                          subtitle: Container(
                              height: 100,
                              width: 100,
                              child: Image.asset('images/wallet.png'))),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => WalletDetails(
                            walletAmount: walletAmount,
                            currentPlan: widget.currentPlan,
                            userRefCode: userRefCode))),
                    onDoubleTap: () => cDialog(
                        context,
                        Icon(Icons.warning_amber_rounded,
                            color: Color.fromRGBO(68, 76, 140, 1)),
                        " Information!",
                        "Wallet balance INR Rs. " +
                            walletAmount +
                            "/- will be transferred to your bank account with next level payments!",
                        160,
                        Color.fromRGBO(68, 76, 140, 1),
                        Color.fromRGBO(68, 76, 140, 1),
                        Container()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: InkWell(
                    child: Card(
                      child: ListTile(
                          // ignore: deprecated_member_use
                          title: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(
                                Icons.business,
                                color: notActive,
                              ),
                              label: Text(
                                "BUSINESS",
                                style: TextStyle(color: notActive),
                              )),
                          subtitle: Container(
                              height: 100,
                              width: 100,
                              child: Image.asset('images/plan.png'))),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            BusinessPlan(userRefCode: userRefCode, currentPlan: widget.currentPlan))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: InkWell(
                    child: Card(
                      child: ListTile(
                          // ignore: deprecated_member_use
                          title: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(
                                Icons.child_care_outlined,
                                color: notActive,
                              ),
                              label: Text(
                                "CHILDS",
                                style: TextStyle(color: notActive),
                              )),
                          subtitle: Container(
                              height: 100,
                              width: 100,
                              child: Image.asset('images/child_nodes.png'))),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            BusinessChilds(userRefCode: userRefCode, currentPlan: widget.currentPlan))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: InkWell(
                    child: Card(
                      child: ListTile(
                          // ignore: deprecated_member_use
                          title: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(
                                Icons.business_sharp,
                                color: notActive,
                              ),
                              label: Text(
                                "REFERRELS",
                                style: TextStyle(color: notActive),
                              )),
                          subtitle: Container(
                              height: 100,
                              width: 100,
                              child: Image.asset('images/referrels.png'))),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            MyReferrels(ref_code: userRefCode, currentPlan: widget.currentPlan))),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ignore: unnecessary_null_comparison
        if (_anchoredBanner != null)
          Container(
            color: Colors.green,
            width: _anchoredBanner!.size.width.toDouble(),
            height: _anchoredBanner!.size.height.toDouble(),
            child: AdWidget(ad: _anchoredBanner!),
          ),
      ],
    );
  }
}

class CustomDrawer extends StatelessWidget {
  final Function closeDrawer;
  final String userName;
  final String userPhone;
  final String userRefCode;
  final String currentPlan;
  final String champID;

  const CustomDrawer(
      {required this.closeDrawer,
      required this.userName,
      required this.userRefCode,
      required this.currentPlan,
      required this.userPhone,
      required this.champID});

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: Container(
        color: Color.fromARGB(255, 255, 128, 0),
        width: mediaQuery.size.width * 0.60,
        height: mediaQuery.size.height,
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration:
                  BoxDecoration(color: Color.fromARGB(255, 255, 128, 0)),
              accountName: Text(userName),
              accountEmail: Text(userPhone),
              currentAccountPicture: InkWell(
                onTap: () {},
                child: Container(
                    width: 150.0,
                    height: 150.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                            image: NetworkImage(
                                'https://pixel.nymag.com/imgs/daily/vulture/2017/06/14/14-tom-cruise.w700.h700.jpg'),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.all(Radius.circular(75.0)),
                        boxShadow: [
                          BoxShadow(blurRadius: 7.0, color: Colors.white)
                        ])),
              ),
              otherAccountsPictures: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(userName[0]),
                )
              ],
            ),
            Card(
              child: ListTile(
                title: Text('CHAMP ID: ' + champID),
                leading: Icon(
                  Icons.verified_user,
                  color: Colors.green,
                ),
              ),
            ),
            InkWell(
              onTap: () => launch('https://techsk.business.site',
                  forceSafariVC: false, forceWebView: false),
              child: Card(
                child: ListTile(
                  title: Text('VISIT US'),
                  leading: Icon(
                    Icons.web,
                    color: Colors.lightGreen,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () => launch(
                  'https://play.google.com/store/apps/details?id=techsk.solutions.mny_champ',
                  forceSafariVC: false,
                  forceWebView: false),
              child: Card(
                child: ListTile(
                  title: Text('RATE US'),
                  leading: Icon(
                    Icons.star_half,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubscriptionPayments()));
              },
              child: Card(
                child: ListTile(
                  title: Text('SUBSCRIBE'),
                  leading: Icon(
                    Icons.favorite,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      BusinessChilds(userRefCode: userRefCode, currentPlan: currentPlan))),
              child: Card(
                child: ListTile(
                  title: Text('MY CHILDS'),
                  leading: Icon(
                    Icons.child_care_outlined,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                await FirebaseAuth.instance.signOut().then((value) {
                  Navigator.of(context).pop();
                  Get.offNamed(Routes.login);
                });
              },
              child: Card(
                child: ListTile(
                  title: Text('LOGOUT'),
                  leading: Icon(
                    Icons.logout,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AboutBusiness(userRefCode: userRefCode, currentPlan: currentPlan)));
              },
              child: Card(
                child: ListTile(
                  title: Text('CONTACT US'),
                  leading: Container(width:40,child: Image.asset('images/help.png'))
                ),
              ),
            ),
            // InkWell(
            //   onTap: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) =>
            //                 PaySampleApp()));
            //   },
            //   child: Card(
            //     child: ListTile(
            //       title: Text('CHECKOUT'),
            //       leading: Icon(
            //         Icons.help,
            //         color: Colors.greenAccent,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}