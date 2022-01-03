import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mny_champ/SharedFiles/dialog_maker.dart';
import 'package:mny_champ/SharedFiles/invite_users.dart';
import 'package:mny_champ/SharedFiles/loading.dart';

const int maxFailedLoadAttempts = 3;

class LevelDetails extends StatefulWidget {
  final String userRefCode, currentPlan;

  LevelDetails({required this.userRefCode, required this.currentPlan});

  @override
  _LevelDetailsState createState() => _LevelDetailsState();
}

class _LevelDetailsState extends State<LevelDetails> {
  bool loading = false;
  late int mnyChampID;
  late int _currentLevel;
  late Map<String, dynamic> myLevels;
  late User _user;
  late QuerySnapshot querySnapshot;

  _getChildrens() async {
    setState(() {
      loading = true;
    });

    _user = FirebaseAuth.instance.currentUser!;
    String ref = 'Subscribed';
    ref = ref + widget.currentPlan[0].toUpperCase() + widget.currentPlan.substring(1) + 'Users';
    await FirebaseFirestore.instance
        .collection(ref)
        .doc(_user.uid)
        .get()
        .then((value) {
      mnyChampID = value.data()!['champ_id'];
      _currentLevel = value.data()!['currentLevel'];
      myLevels = value.data()!['myLevels'];
    });

    querySnapshot = await FirebaseFirestore.instance
        .collection(ref)
        .where('champ_id', isGreaterThanOrEqualTo: mnyChampID).orderBy('champ_id')
        .get();

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

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: 'ca-app-pub-3518368113893985/6306463176',
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
    super.initState();
    _createRewardedAd();
    _getChildrens();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('CHAMP '+ widget.currentPlan.toUpperCase() +' LEVELS', style: TextStyle(fontSize: 16)),
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
        padding: const EdgeInsets.all(2.0),
        child: Column(
              children: [
                loading ? Loading() : Container(height: MediaQuery.of(context).size.height*0.825,
                  child: Stepper(
                      physics: ScrollPhysics(),
                      type: StepperType.vertical,
                      currentStep: _currentLevel,
                      onStepTapped: (int step) => _checkLevelStatus(step),
                      onStepContinue:
                          _currentLevel < 9 ? () => checkLevelContinuity() : null,
                      // setState(() => _currentLevel += 1)
                      onStepCancel: _currentLevel > 0
                          ? () => setState(() => _currentLevel -= 1)
                          : null,
                      steps: <Step>[
                        Step(
                          // ignore: deprecated_member_use
                          title: FlatButton(
                              onPressed: () {},
                              child: Text(
                                'LEVEL 1',
                                style: TextStyle(fontSize: 20),
                              ),
                              color: (myLevels['level_1']) ? Colors.green : Color.fromRGBO(91, 79, 156, 1),
                              textColor: Colors.white),
                          content: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: querySnapshot.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  color: (querySnapshot.docs[index]
                                              .get('referencerID') ==
                                          _user.uid)
                                      ? Colors.green
                                      : Colors.blue,
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        Expanded(
                                            child:
                                                Text((index).toString() + '.')),
                                        Expanded(
                                            child: SelectableText(
                                                (querySnapshot.docs[index]
                                                        .get('champ_id'))
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white))),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          isActive: _currentLevel >= 4,
                          state: _currentLevel >= 0
                              ? StepState.complete
                              : StepState.disabled,
                        ),
                        Step(
                          // ignore: deprecated_member_use
                          title: FlatButton(
                              onPressed: () {},
                              child: Text(
                                'LEVEL 2',
                                style: TextStyle(fontSize: 20),
                              ),
                              color: (myLevels['level_2']) ? Colors.green : Color.fromRGBO(91, 79, 156, 1),
                              textColor: Colors.white),
                          content: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: querySnapshot.docs.length,
                              itemBuilder: (context, int index) {
                                return Card(
                                  color: (querySnapshot.docs[index]
                                              .get('referencerID') ==
                                          _user.uid)
                                      ? Colors.green
                                      : Colors.blue,
                                  child: InkWell(
                                    onTap: () => cDialog(
                                        context,
                                        Icon(Icons.warning_amber_rounded,
                                            color: Color.fromRGBO(68, 76, 140, 1)),
                                        querySnapshot.docs[index].get('username'),
                                        'Champ ID: ' +
                                            (querySnapshot.docs[index]
                                                    .get('champ_id'))
                                                .toString(),
                                        120,
                                        Color.fromRGBO(68, 76, 140, 1),
                                        Color.fromRGBO(68, 76, 140, 1)),
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                                  (index + 31).toString() + '.')),
                                          Expanded(
                                              child: SelectableText(
                                                  (querySnapshot.docs[index]
                                                          .get('champ_id'))
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white))),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          isActive: _currentLevel >= 5,
                          state: _currentLevel >= 1
                              ? StepState.complete
                              : StepState.disabled,
                        ),
                        Step(
                          // ignore: deprecated_member_use
                          title: FlatButton(
                              onPressed: () {},
                              child: Text(
                                'LEVEL 3',
                                style: TextStyle(fontSize: 20),
                              ),
                              color: (myLevels['level_3']) ? Colors.green : Color.fromRGBO(91, 79, 156, 1),
                              textColor: Colors.white),
                          content: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: querySnapshot.docs.length,
                              itemBuilder: (context, int index) {
                                return Card(
                                  color: (querySnapshot.docs[index]
                                              .get('referencerID') ==
                                          _user.uid)
                                      ? Colors.green
                                      : Colors.blue,
                                  child: InkWell(
                                    onTap: () => cDialog(
                                        context,
                                        Icon(Icons.warning_amber_rounded,
                                            color: Color.fromRGBO(68, 76, 140, 1)),
                                        querySnapshot.docs[index].get('username'),
                                        'Champ ID: ' +
                                            (querySnapshot.docs[index]
                                                    .get('champ_id'))
                                                .toString(),
                                        120,
                                        Color.fromRGBO(68, 76, 140, 1),
                                        Color.fromRGBO(68, 76, 140, 1)),
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Expanded(
                                              child:
                                                  Text((index + 1).toString() + '.')),
                                          Expanded(
                                              child: SelectableText(
                                                  (querySnapshot.docs[index]
                                                          .get('champ_id'))
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white))),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          isActive: _currentLevel >= 0,
                          state: _currentLevel >= 1
                              ? StepState.complete
                              : StepState.disabled,
                        ),
                        Step(
                          // ignore: deprecated_member_use
                          title: FlatButton(
                              onPressed: () {},
                              child: Text(
                                'LEVEL 4',
                                style: TextStyle(fontSize: 20),
                              ),
                              color: (myLevels['level_4']) ? Colors.green : Color.fromRGBO(91, 79, 156, 1),
                              textColor: Colors.white),
                          content: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: querySnapshot.docs.length,
                              itemBuilder: (context, int index) {
                                return Card(
                                  color: (querySnapshot.docs[index]
                                              .get('referencerID') ==
                                          _user.uid)
                                      ? Colors.green
                                      : Colors.blue,
                                  child: InkWell(
                                    onTap: () => cDialog(
                                        context,
                                        Icon(Icons.warning_amber_rounded,
                                            color: Color.fromRGBO(68, 76, 140, 1)),
                                        querySnapshot.docs[index].get('username'),
                                        'Champ ID: ' +
                                            (querySnapshot.docs[index]
                                                    .get('champ_id'))
                                                .toString(),
                                        120,
                                        Color.fromRGBO(68, 76, 140, 1),
                                        Color.fromRGBO(68, 76, 140, 1)),
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Expanded(
                                              child:
                                                  Text((index + 1).toString() + '.')),
                                          Expanded(
                                              child: SelectableText(
                                                  (querySnapshot.docs[index]
                                                          .get('champ_id'))
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white))),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          isActive: _currentLevel >= 0,
                          state: _currentLevel >= 1
                              ? StepState.complete
                              : StepState.disabled,
                        ),
                        Step(
                          // ignore: deprecated_member_use
                          title: FlatButton(
                              onPressed: () {},
                              child: Text(
                                'LEVEL 5',
                                style: TextStyle(fontSize: 20),
                              ),
                              color: (myLevels['level_5']) ? Colors.green : Color.fromRGBO(91, 79, 156, 1),
                              textColor: Colors.white),
                          content: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: querySnapshot.docs.length,
                              itemBuilder: (context, int index) {
                                return Card(
                                  color: (querySnapshot.docs[index]
                                              .get('referencerID') ==
                                          _user.uid)
                                      ? Colors.green
                                      : Colors.blue,
                                  child: InkWell(
                                    onTap: () => cDialog(
                                        context,
                                        Icon(Icons.warning_amber_rounded,
                                            color: Color.fromRGBO(68, 76, 140, 1)),
                                        querySnapshot.docs[index].get('username'),
                                        'Champ ID: ' +
                                            (querySnapshot.docs[index]
                                                    .get('champ_id'))
                                                .toString(),
                                        120,
                                        Color.fromRGBO(68, 76, 140, 1),
                                        Color.fromRGBO(68, 76, 140, 1)),
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Expanded(
                                              child:
                                                  Text((index + 1).toString() + '.')),
                                          Expanded(
                                              child: SelectableText(
                                                  (querySnapshot.docs[index]
                                                          .get('champ_id'))
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white))),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          isActive: _currentLevel >= 0,
                          state: _currentLevel >= 1
                              ? StepState.complete
                              : StepState.disabled,
                        ),
                        Step(
                          // ignore: deprecated_member_use
                          title: FlatButton(
                              onPressed: () {},
                              child: Text(
                                'LEVEL 6',
                                style: TextStyle(fontSize: 20),
                              ),
                              color: (myLevels['level_6']) ? Colors.green : Color.fromRGBO(91, 79, 156, 1),
                              textColor: Colors.white),
                          content: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: querySnapshot.docs.length,
                              itemBuilder: (context, int index) {
                                return Card(
                                  color: (querySnapshot.docs[index]
                                              .get('referencerID') ==
                                          _user.uid)
                                      ? Colors.green
                                      : Colors.blue,
                                  child: InkWell(
                                    onTap: () => cDialog(
                                        context,
                                        Icon(Icons.warning_amber_rounded,
                                            color: Color.fromRGBO(68, 76, 140, 1)),
                                        querySnapshot.docs[index].get('username'),
                                        'Champ ID: ' +
                                            (querySnapshot.docs[index]
                                                    .get('champ_id'))
                                                .toString(),
                                        120,
                                        Color.fromRGBO(68, 76, 140, 1),
                                        Color.fromRGBO(68, 76, 140, 1)),
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Expanded(
                                              child:
                                                  Text((index + 1).toString() + '.')),
                                          Expanded(
                                              child: SelectableText(
                                                  (querySnapshot.docs[index]
                                                          .get('champ_id'))
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white))),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          isActive: _currentLevel >= 0,
                          state: _currentLevel >= 1
                              ? StepState.complete
                              : StepState.disabled,
                        ),
                        Step(
                          // ignore: deprecated_member_use
                          title: FlatButton(
                              onPressed: () {},
                              child: Text(
                                'LEVEL 7',
                                style: TextStyle(fontSize: 20),
                              ),
                              color: (myLevels['level_7']) ? Colors.green : Color.fromRGBO(91, 79, 156, 1),
                              textColor: Colors.white),
                          content: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: querySnapshot.docs.length,
                              itemBuilder: (context, int index) {
                                return Card(
                                  color: (querySnapshot.docs[index]
                                              .get('referencerID') ==
                                          _user.uid)
                                      ? Colors.green
                                      : Colors.blue,
                                  child: InkWell(
                                    onTap: () => cDialog(
                                        context,
                                        Icon(Icons.warning_amber_rounded,
                                            color: Color.fromRGBO(68, 76, 140, 1)),
                                        querySnapshot.docs[index].get('username'),
                                        'Champ ID: ' +
                                            (querySnapshot.docs[index]
                                                    .get('champ_id'))
                                                .toString(),
                                        120,
                                        Color.fromRGBO(68, 76, 140, 1),
                                        Color.fromRGBO(68, 76, 140, 1)),
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Expanded(
                                              child:
                                                  Text((index + 1).toString() + '.')),
                                          Expanded(
                                              child: SelectableText(
                                                  (querySnapshot.docs[index]
                                                          .get('champ_id'))
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white))),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          isActive: _currentLevel >= 0,
                          state: _currentLevel >= 1
                              ? StepState.complete
                              : StepState.disabled,
                        ),
                        Step(
                          // ignore: deprecated_member_use
                          title: FlatButton(
                              onPressed: () {},
                              child: Text(
                                'LEVEL 8',
                                style: TextStyle(fontSize: 20),
                              ),
                              color: (myLevels['level_8']) ? Colors.green : Color.fromRGBO(91, 79, 156, 1),
                              textColor: Colors.white),
                          content: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: querySnapshot.docs.length,
                              itemBuilder: (context, int index) {
                                return Card(
                                  color: (querySnapshot.docs[index]
                                              .get('referencerID') ==
                                          _user.uid)
                                      ? Colors.green
                                      : Colors.blue,
                                  child: InkWell(
                                    onTap: () => cDialog(
                                        context,
                                        Icon(Icons.warning_amber_rounded,
                                            color: Color.fromRGBO(68, 76, 140, 1)),
                                        querySnapshot.docs[index].get('username'),
                                        'Champ ID: ' +
                                            (querySnapshot.docs[index]
                                                    .get('champ_id'))
                                                .toString(),
                                        120,
                                        Color.fromRGBO(68, 76, 140, 1),
                                        Color.fromRGBO(68, 76, 140, 1)),
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Expanded(
                                              child:
                                                  Text((index + 1).toString() + '.')),
                                          Expanded(
                                              child: SelectableText(
                                                  (querySnapshot.docs[index]
                                                          .get('champ_id'))
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white))),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          isActive: _currentLevel >= 0,
                          state: _currentLevel >= 1
                              ? StepState.complete
                              : StepState.disabled,
                        ),
                        Step(
                          // ignore: deprecated_member_use
                          title: FlatButton(
                              onPressed: () {},
                              child: Text(
                                'LEVEL 9',
                                style: TextStyle(fontSize: 20),
                              ),
                              color: (myLevels['level_9']) ? Colors.green : Color.fromRGBO(91, 79, 156, 1),
                              textColor: Colors.white),
                          content: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: querySnapshot.docs.length,
                              itemBuilder: (context, int index) {
                                return Card(
                                  color: (querySnapshot.docs[index]
                                              .get('referencerID') ==
                                          _user.uid)
                                      ? Colors.green
                                      : Colors.blue,
                                  child: InkWell(
                                    onTap: () => cDialog(
                                        context,
                                        Icon(Icons.warning_amber_rounded,
                                            color: Color.fromRGBO(68, 76, 140, 1)),
                                        querySnapshot.docs[index].get('username'),
                                        'Champ ID: ' +
                                            (querySnapshot.docs[index]
                                                    .get('champ_id'))
                                                .toString(),
                                        120,
                                        Color.fromRGBO(68, 76, 140, 1),
                                        Color.fromRGBO(68, 76, 140, 1),
                                        Container()),
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Expanded(
                                              child:
                                                  Text((index + 1).toString() + '.')),
                                          Expanded(
                                              child: SelectableText(
                                                  (querySnapshot.docs[index]
                                                          .get('champ_id'))
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white))),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          isActive: _currentLevel >= 0,
                          state: _currentLevel >= 1
                              ? StepState.complete
                              : StepState.disabled,
                        ),
                        Step(
                          title: (myLevels['level_final']) ? InkWell(onTap: () {print('ReSubscribe');},
                            child: Image.asset(
                              "images/Levels/level_10.png",
                              width: 200,
                              height: 200),
                          ) : Image.asset(
                            "images/Levels/level10.png",
                            width: 100,
                            height: 100,
                          ),
                          content: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: querySnapshot.docs.length,
                              itemBuilder: (context, int index) {
                                return Card(
                                  color: (querySnapshot.docs[index]
                                              .get('referencerID') ==
                                          _user.uid)
                                      ? Colors.green
                                      : Colors.blue,
                                  child: InkWell(
                                    onTap: () => cDialog(
                                        context,
                                        Icon(Icons.warning_amber_rounded,
                                            color: Color.fromRGBO(68, 76, 140, 1)),
                                        querySnapshot.docs[index].get('username'),
                                        'Champ ID: ' +
                                            (querySnapshot.docs[index]
                                                    .get('champ_id'))
                                                .toString(),
                                        120,
                                        Color.fromRGBO(68, 76, 140, 1),
                                        Color.fromRGBO(68, 76, 140, 1)),
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Expanded(
                                              child:
                                                  Text((index + 1).toString() + '.')),
                                          Expanded(
                                              child: SelectableText(
                                                  (querySnapshot.docs[index]
                                                          .get('champ_id'))
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white))),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          isActive: _currentLevel >= 0,
                          state: _currentLevel >= 1
                              ? StepState.complete
                              : StepState.disabled,
                        ),
                      ],
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
      ),
    );
  }

  _checkLevelStatus(int levelNo) {
    setState(() => loading = true);
    if (levelNo < _currentLevel) {
      cDialog(
          context,
          Icon(Icons.warning_amber_rounded,
              color: Color.fromRGBO(68, 76, 140, 1)),
          'Level '+ (levelNo+1).toString() +' Status',
          'Level completed.',
          100,
          Color.fromRGBO(68, 76, 140, 1),
          Color.fromRGBO(68, 76, 140, 1),
          Container());
    } else if (levelNo == _currentLevel) {
      String content = 'Level Running......';
      if(levelNo == 0) {
        content = content + '\n\nInvite users to earn money.\n\nAtleast 1 referrel and 30 childs mandatory to achieve level payments.';
      }
      cDialog(
          context,
          Icon(Icons.warning_amber_rounded,
              color: Color.fromRGBO(68, 76, 140, 1)),
          'Level '+ (levelNo+1).toString() +' Status',
          content,
          170,
          Color.fromRGBO(68, 76, 140, 1),
          Color.fromRGBO(68, 76, 140, 1),
          Container());
    } else {
      cDialog(
          context,
          Icon(Icons.warning_amber_rounded,
              color: Color.fromRGBO(68, 76, 140, 1)),
          'Level '+ (levelNo+1).toString() +' Status',
          'First complete running level: ' + (_currentLevel+1).toString() + '\n\nInvite new users as much as possible to complete the level ASAP.',
          150,
          Color.fromRGBO(68, 76, 140, 1),
          Color.fromRGBO(68, 76, 140, 1),
          Container());
    }
    _showRewardedAd();
    setState(() => loading = false);
  }

  checkLevelContinuity() async {
    setState(() => loading = true);
    if (myLevels['level_'+(_currentLevel+2).toString()]) {
      setState(() {
        loading = false;
        _currentLevel += 1;
      });
    } else {
      setState(() {
        loading = false;
        _showRewardedAd();
        cDialog(
            context,
            Icon(Icons.warning_amber_rounded,
                color: Color.fromRGBO(68, 76, 140, 1)),
            'Level '+ (_currentLevel+1).toString() +' Status',
            'First complete running level: ' + (_currentLevel+1).toString() + '\n\nInvite new users as much as possible to complete the level ASAP before proceeding to next levels.',
            150,
            Color.fromRGBO(68, 76, 140, 1),
            Color.fromRGBO(68, 76, 140, 1),
            Container());
      });
    }
  }
}