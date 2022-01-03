import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mny_champ/SharedFiles/invite_users.dart';

class WalletDetails extends StatefulWidget {
  final String userRefCode, currentPlan;
  final String walletAmount;
  WalletDetails({required this.userRefCode,required this.walletAmount, required this.currentPlan});
  @override
  _WalletDetailsState createState() => _WalletDetailsState();
}

class _WalletDetailsState extends State<WalletDetails> {
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
          ? 'ca-app-pub-3518368113893985/7687773700'
          : 'ca-app-pub-3518368113893985/7687773700',
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
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return Scaffold(
        appBar: AppBar(
            title: Text('WALLET DETAILS'),
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
            Container(height: MediaQuery.of(context).size.height*0.825,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Card(color: (int.parse(widget.walletAmount) >0) ? Colors.green : Colors.red, child: ListTile(title: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Wallet Amount: INR '+widget.walletAmount+'/-',style: TextStyle(color: Colors.white,fontSize: 20)),
                      ],
                    ))),
                    SizedBox(height: 20),
                    Card(color: Color.fromRGBO(121, 159, 200, 1), child: ListTile(title: Text('Wallet Money:\n\n1. Amounts in your wallet increments when you invite new entries and they subscribes using your referrel code then referrel amount added to your wallet balance.\n\n2. This wallet amount will be transferred to your bank account when you completes your current level then with level completion achievements this wallet balance will be transferred to your account.\n\n3. To increase your wallet balance you are supposed to just invite new entries and tell them to use your referrel code at the time of subscription so you and your subscriber both will be rewarded with prefixed amounts.\n\n4. As wallet balance transferred to your account it is resetted to zero.',style: TextStyle(color: Colors.white,fontSize: 20)))),
                  ],
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