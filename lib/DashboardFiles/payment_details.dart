import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mny_champ/SharedFiles/invite_users.dart';
import 'package:mny_champ/SharedFiles/loading.dart';

class PaymentDetails extends StatefulWidget {
  final String userRefCode, currentPlan;

  PaymentDetails({required this.userRefCode, required this.currentPlan});

  @override
  _PaymentDetailsState createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  bool loading = false;
  late String subID, subAmt;
  late Timestamp subDate;

  void getChampPayments() async {
    String ref = 'Subscribed';
    ref = ref + widget.currentPlan[0].toUpperCase() + widget.currentPlan.substring(1) + 'Users';
    setState(() {
      loading = true;
    });
    User _user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection(ref)
        .doc(_user.uid)
        .get()
        .then((userDoc) {
      subID = userDoc.data()!['subscriptionPaymentID'];
      subAmt = userDoc.data()!['subscriptionAmt'];
      subDate = userDoc.data()!['subscriptionDate'];
    });
    setState(() {
      loading = false;
    });
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
          ? 'ca-app-pub-3518368113893985/8025070657'
          : 'ca-app-pub-3518368113893985/8025070657',
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
    getChampPayments();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('CHAMP '+ widget.currentPlan.toUpperCase() +' PAYMENTS', style: TextStyle(fontSize: 16)),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: loading
            ? Loading()
            : Column(
                children: [
                  Container(
                    child: Card(
                      color: Color.fromRGBO(121, 199, 200, 1),
                        child: ListTile(
                      title: Row(
                        children: [
                          Expanded(child: SelectableText('SID: ' + subID)),
                        ],
                      ),
                      subtitle: Text('S Date: ' + subDate.toDate().toString()),
                      trailing: Text('INR ' + subAmt + '/-'),
                    )),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.725,
                    child: ListView.builder(
                        itemCount: 0,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            child: Card(
                                child: ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                      child: SelectableText('PID: ' + subID)),
                                ],
                              ),
                              subtitle: Text(
                                  'P Date: ' + subDate.toDate().toString()),
                              trailing: Text('INR ' + subAmt + '/-'),
                            )),
                          );
                        }),
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
      ),
    );
  }
}