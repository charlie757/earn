import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../SharedFiles/dialog_maker.dart';
import '../SharedFiles/invite_users.dart';
import '../SharedFiles/loading.dart';

class MyReferrels extends StatefulWidget {
  final String ref_code, currentPlan;
  MyReferrels({required this.ref_code, required this.currentPlan});
  @override
  _MyReferrelsState createState() => _MyReferrelsState();
}

class _MyReferrelsState extends State<MyReferrels> {
  bool loading = false;
  User? _user;
  List<dynamic> referrelList1 = [];
  List<dynamic> referrelList2 = [];

  getReferrels() async {
    setState(() => loading = true);
    _user = FirebaseAuth.instance.currentUser!;
    String ref = 'Subscribed';
    ref = ref + widget.currentPlan[0].toUpperCase() + widget.currentPlan.substring(1) + 'Users';
    await FirebaseFirestore.instance.collection(ref).doc(_user!.uid).get().then((value) {
      referrelList1 = value.data()!['myReferrels'];
    });
    setState(() => loading = false);
  }

  static final AdRequest request = AdRequest(
    keywords: <String>['software','app development','web development','java','python','artificial intelligence','machiene learning','data science','robotics','mathematics','physics','technology','college','university','microsoft','sports','india','world','neuroscience','astronomy','weather','astronautics'],
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
          ? 'ca-app-pub-3518368113893985/7999174010'
          : 'ca-app-pub-3518368113893985/7999174010',
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

  @override
  void dispose() {
    super.dispose();
    _anchoredBanner!.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReferrels();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return loading ? Loading() : Scaffold(
      appBar: AppBar(
        title: Text(widget.currentPlan.toUpperCase() + ' REFERRELS: '+ referrelList1.length.toString()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.pink,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InviteUsers(userRefCode: widget.ref_code,currentPlan: widget.currentPlan),
          )
        ],
      ),
      body: ListView(
        children: [
          Container(height: MediaQuery.of(context).size.height*0.9,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _referredUsersList(),
            ),
          ),
          // ignore: unnecessary_null_comparison
          if (_anchoredBanner != null)
            Container(
              width: _anchoredBanner!.size.width.toDouble(),
              height: _anchoredBanner!.size.height.toDouble(),
              child: AdWidget(ad: _anchoredBanner!),
            ),
        ],
      ),
    );
  }


  Widget _referredUsersList() {
    String ref = 'Subscribed';
    ref = ref + widget.currentPlan[0].toUpperCase() + widget.currentPlan.substring(1) + 'Users';
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(ref).where('referencerID', isEqualTo: _user!.uid).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Loading();
        return ListView.builder(
          shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            padding: EdgeInsets.all(5.0),
            itemBuilder: (context, i) {
              return Container(
                padding: EdgeInsets.all(5.0),
                child: Card(
                  color: Colors.green,
                  child: ListTile(
                    onTap: () => _referrelDetails(snapshot, i),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(snapshot.data!.docs[i].get('champ_id').toString(),
                              style: TextStyle(
                                  color: Colors.white,fontSize: 16.0,fontWeight: FontWeight.bold
                              )),
                        ),
                        Expanded(
                          child: Text('Running Level: '+ (snapshot.data!.docs[i].get('currentLevel') + 1).toString(),
                              style: TextStyle(
                                  color: Colors.white,fontSize: 16.0,fontWeight: FontWeight.bold
                              )),
                        ),
                      ],
                    ),
                    subtitle: Text((snapshot
                        .data!.docs[i].get('subscriptionDate')
                        .toDate()
                        .toString()) ,style: TextStyle(color: Colors.black,fontSize: 16.0)),
                  ),
                ),
              );
            });
      },
    );
  }

  void _referrelDetails(AsyncSnapshot snapshot, int i) async {
    var champName;
    var champPhone;

    await FirebaseFirestore.instance.collection('Users').doc(snapshot.data.docs[i].id).get().then((referrerDoc) {
      champName = referrerDoc.data()!['username'];
      champPhone = referrerDoc.data()!['phone'];
    });

    cDialog(
        context,
        Icon(Icons.verified_user,
            color: Colors.green),
        " Referrel Details!",
        'Champ ID: '+ snapshot.data.docs[i].data()['champ_id'].toString() + '\n\nLevel Running: '+ (snapshot.data.docs[i].data()['currentLevel'] + 1).toString() + '\n\nName: '+ champName + '\n\nPhone: '+ champPhone +'\n\nSubscription Date: '+(snapshot
            .data.docs[i].data()['subscriptionDate']
            .toDate()
            .toString()),
        350,
        Color.fromARGB(255, 0, 113, 219),
        Color.fromARGB(255, 0, 113, 219), Container());
  }
}