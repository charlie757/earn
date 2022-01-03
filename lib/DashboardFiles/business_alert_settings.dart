import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mny_champ/SharedFiles/invite_users.dart';
import '../SharedFiles/loading.dart';

class BusinessChilds extends StatefulWidget {
  final String userRefCode, currentPlan;

  BusinessChilds({required this.userRefCode, required this.currentPlan});

  @override
  _BusinessChildsState createState() => _BusinessChildsState();
}

class _BusinessChildsState extends State<BusinessChilds> {
  bool loading = false;
  late int myChampID;
  late QuerySnapshot _querySnapshot;

  getChilds() async {
    String ref = 'Subscribed';
    ref = ref + widget.currentPlan[0].toUpperCase() + widget.currentPlan.substring(1) + 'Users';
    setState(() => loading = true);
    User _user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection(ref).doc(_user.uid).get().then((value) => myChampID = value.get('champ_id'));
    _querySnapshot = await FirebaseFirestore.instance.collection(ref).where('champ_id', isGreaterThan: myChampID).orderBy('champ_id').get();
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
          ? 'ca-app-pub-3518368113893985/8409882338'
          : 'ca-app-pub-3518368113893985/8409882338',
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
    setState(() {
      loading = true;
    });
    getChilds();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return loading ? Loading() : Scaffold(
        appBar: AppBar(
          title: Text(widget.currentPlan.toUpperCase() + ' CHILDS: '+ ((_querySnapshot.size).toString())),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.pink,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InviteUsers(userRefCode: widget.userRefCode,currentPlan: widget.currentPlan),
            )
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: MediaQuery.of(context).size.height*0.825,
                color: Color.fromRGBO(121, 199, 200, 1),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _querySnapshot.size,
                  itemBuilder: (BuildContext context, int index) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('Users').where('id', isEqualTo: _querySnapshot.docs[index].id).snapshots(),
                      builder: (context, snap) {
                        if(!snap.hasData) return Loading();
                        else return Card(
                          child: ListTile(
                            title: Row(
                              children: [
                                Expanded(child: Text((index+1).toString()+'.')),
                                Expanded(child: Text(_querySnapshot.docs[index].get('champ_id').toString())),
                                Expanded(child: Text((_querySnapshot.docs[index].get('currentLevel')+1).toString())),
                                Expanded(child: Text(snap.data!.docs[0].get('username'))),
                              ],
                            )
                          ),
                        );
                      }
                    );
                  },
                ),
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
        ));
  }
}