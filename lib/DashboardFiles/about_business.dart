import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mny_champ/SharedFiles/invite_users.dart';
import 'package:url_launcher/url_launcher.dart';

const int maxFailedLoadAttempts = 3;

class AboutBusiness extends StatefulWidget {
  final String userRefCode, currentPlan;

  AboutBusiness({required this.userRefCode, required this.currentPlan});

  @override
  _AboutBusinessState createState() => _AboutBusinessState();
}

class _AboutBusinessState extends State<AboutBusiness> {
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
          ? 'ca-app-pub-3518368113893985/2499080108'
          : 'ca-app-pub-3518368113893985/2499080108',
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

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: 'ca-app-pub-3518368113893985/8569417015',
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts <= maxFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (RewardedAd ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type}');
    });
    _rewardedAd = null;
  }

  @override
  void dispose() {
    super.dispose();
    _anchoredBanner!.dispose();
    _rewardedAd?.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _createRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    if(_rewardedAd != null) _showRewardedAd();
    return Scaffold(
        appBar: AppBar(
          title: Text('ABOUT BUSINESS'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.pink,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InviteUsers(userRefCode: widget.userRefCode,currentPlan: widget.currentPlan,),
            )
          ],
        ),
        body: Column(
          children: [
            Container( height: MediaQuery.of(context).size.height*0.825,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Card(
                        color: Colors.pinkAccent.shade200,
                        child: ListTile(
                            title: Column(
                              children: [
                                Text(
                                    'Feel Free to reach us:\n\nFor any queries regarding anything of the business contact us:',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontStyle: FontStyle.italic)),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(child: InkWell(child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset('images/call.png'),
                                    ), onTap: () => launch('tel:9416136562'))),
                                    Expanded(child: InkWell(child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset('images/whats.png'),
                                    ),onTap: () => launch("whatsapp://send?phone=+919416136562&text="),)),
                                    Expanded(child: InkWell(child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset('images/mail.png'),
                                    ), onTap: () => launch(_emailLaunchUriBusiness.toString())))
                                  ],
                                ),
                              ],
                            ))),
                    SizedBox(height: 20),
                    Card(
                        color: Colors.pinkAccent.shade200,
                        child: ListTile(
                            title: Column(
                          children: [
                            Text(
                                'Feel Free to reach us:\n\nFor any queries regarding any issues of the application contact us:',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic)),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: InkWell(child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset('images/call.png'),
                                ), onTap: () => launch('tel:7073229920'))),
                                Expanded(child: InkWell(child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset('images/whats.png'),
                                ),onTap: () => launch("whatsapp://send?phone=+917073229920&text="),)),
                                Expanded(child: InkWell(child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset('images/mail.png'),
                                ), onTap: () => launch(_emailLaunchUriApp.toString())))
                              ],
                            ),
                          ],
                        ))),
                    SizedBox(height: 20),
                    Card(
                        color: Color.fromRGBO(71, 79, 156, 1),
                        child: ListTile(
                            title: Text(
                                'UPDATE: Whenever you receive notifications regarding latest update you are supposed to take latest update from play store to get reflected user interface and enhanced features.',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic)))),
                    SizedBox(height: 20),
                    Card(
                        color: Color.fromRGBO(121, 199, 200, 1),
                        child: ListTile(
                            title: Text(
                                'Note: We check out your payments after a service tax deduction including google play services, developers fees, and payment services etc.',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic)))),
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

final Uri _emailLaunchUriBusiness = Uri(
    scheme: 'mailto',
    path: 'champmny@gmail.com',
    queryParameters: {
      'subject': ''
    }
);

final Uri _emailLaunchUriApp = Uri(
    scheme: 'mailto',
    path: 'techsk.solutions@gmail.com',
    queryParameters: {
      'subject': ''
    }
);