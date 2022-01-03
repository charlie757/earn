import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mny_champ/FrontScreens/dash_board.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../SharedFiles/dialog_maker.dart';
import '../SharedFiles/loading.dart';

const int maxFailedLoadAttempts = 3;

class SubscriptionPayments extends StatefulWidget {
  @override
  _SubscriptionPaymentsState createState() => _SubscriptionPaymentsState();
}

class _SubscriptionPaymentsState extends State<SubscriptionPayments> {
  bool loading = false;
  bool referrelFound = false;
  String referrelPlan = '';
  late Razorpay _razorpay;

  String selectedPlan = '';
  late Map<String,dynamic> champIDs;
  late int _champID;
  late Map<String,dynamic> _referrelAmountForInviter;
  late Map<String,dynamic> _referrelAmountForSubscriber;
  late Map<String, dynamic> _subAmount;
  late double _subscriptionAmount;
  late int _referrelAmtForInviter;
  late int _referrelAmtForSubscriber;
  late String _subRecieverTestAPI;
  late String _subRecieverLiveAPI;
  late String _useSubAPI;
  late String _userPhone;
  int _radioValue = 0;
  late String referrelCode;

  TextEditingController _controllerReferrelCode = TextEditingController();

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

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: 'ca-app-pub-3518368113893985/6527838921',
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
    // TODO: implement dispose
    _rewardedAd?.dispose();
    super.dispose();
    _razorpay.clear();
  }

  @override
  void initState() {
    setState(() => loading = true);
    _createRewardedAd();
    this.referrelCode = 'REF_MNY';
    super.initState();
    getChampID();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  getChampID() async {
    await FirebaseFirestore.instance
        .collection('AllotableChampID')
        .doc('allotable_champ_id')
        .get()
        .then((value) {
      _subAmount = value.data()!['subscriptionAmount'];
      _subRecieverTestAPI = value.data()!['testModeAPI'];
      _subRecieverLiveAPI = value.data()!['liveModeAPI'];
      champIDs = value.data()!['allotableChampId'];
      _referrelAmountForInviter = value.data()!['referrelInviterMoney'];
      _referrelAmountForSubscriber = value.data()!['referrelUserMoney'];
    });
    User _user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('Users').doc(_user.uid).get().then((value) => _userPhone = value.data()!['phone']);
    setState(() => loading = false);
  }

  void openCheckOut() {
    var options = {
      'key': _useSubAPI,
      'amount': _subscriptionAmount * 100,
      'name': 'Mny Champ Subscription',
      'description':this.referrelCode,
      'prefill': {
        'contact': _userPhone,
        'email': 'mnychamp@gmail.com',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    paymentSuccessful(response);
  }

  void _handlePaymentError() {
    // Do something when payment fails
    Fluttertoast.showToast(
        msg: 'Payment Failed',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.CENTER);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
    Fluttertoast.showToast(
        msg: 'Payment Using External Wallet',
        backgroundColor: Colors.green,
        textColor: Colors.white,
        gravity: ToastGravity.CENTER);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(71, 79, 156, 0.4),
        title: Text('MNY Champ Subscription', style: TextStyle(fontSize: 24)),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: loading
            ? Loading()
            : ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                color: Color.fromRGBO(71, 79, 156, 0.2),
                child: ListTile(
                    title: Text(
                        'Subscription payment is one time payment and after this payment you will be subscribed with MNY Champ. After successful subscription you will be allotted an unique ID and you will be authorized to access the MNY Champ Dashboard where you will manage your business. After being member of MNY Champ you are only supposed to invite new entries and complete target levels while retrieving level achievements.\n\nसब्सक्रिप्शन भुगतान एकमुश्त भुगतान है और इस भुगतान के बाद आपको मनी चैंप के साथ सब्सक्राइब किया जाएगा। सफल सब्सक्रिप्शन के बाद आपको एक यूनिक आईडी आवंटित की जाएगी और आपको मनी चैंप डैशबोर्ड तक पहुंचने के लिए अधिकृत किया जाएगा जहां आप अपने व्यवसाय का प्रबंधन करेंगे। मनी चैंप के सदस्य होने के बाद, आपको केवल नई प्रविष्टियाँ आमंत्रित करनी चाहिए और स्तर की उपलब्धियों को प्राप्त करते हुए लक्ष्य स्तरों को पूरा करना चाहिए।',
                        style: TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            color: Color.fromRGBO(71, 79, 156, 0.8)))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card( color: Color.fromARGB(255, 0, 113, 219),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Choose Subscription Plan",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    Card(child:  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Radio(
                          value: 1,
                          groupValue: _radioValue,
                          onChanged: _handleRadioValueChange,
                        ),
                        new Text('Basic Plan'),
                      ],
                    )),
                    Card(child:  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Radio(
                          value: 2,
                          groupValue: _radioValue,
                          onChanged: _handleRadioValueChange,
                        ),
                        new Text('Premium Plan'),
                      ],
                    )),
                    Card(child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Radio(
                          value: 3,
                          groupValue: _radioValue,
                          onChanged: _handleRadioValueChange,
                        ),
                        new Text('Platinum Plan'),
                      ],
                    ))
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controllerReferrelCode,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(10))),
                    labelText: 'Referrel Code is Optional',
                    hintText: 'Referrel Code (Optional)',
                    labelStyle: TextStyle(
                        color: Color.fromRGBO(71, 79, 156, 0.6)),
                    hintStyle: TextStyle(
                        color: Color.fromRGBO(71, 79, 156, 0.6))),
                onChanged: (value) {
                  if (value.length == 6)
                    this.referrelCode = value;
                  else
                    this.referrelCode = 'REF_MNY';
                },
              ),
            ),
            ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.deepPurple),
              onPressed: () async {
                _controllerReferrelCode.clear();
                _showRewardedAd();

                if(_radioValue == 0) {
                  cDialog(
                      context,
                      Icon(Icons.warning_amber_rounded,
                          color: Color.fromARGB(255, 0, 113, 219)),
                      " Choose Subscription Plan!",
                      'Please choose subscription plan to proceed.',
                      100,
                      Color.fromARGB(255, 0, 113, 219),
                      Color.fromARGB(255, 0, 113, 219), Container());
                }

                User _user = FirebaseAuth.instance.currentUser!;
                await FirebaseFirestore.instance.collection('Users').doc(_user.uid).get().then((value) async {
                  if(value.data()!['testMode'] == true) {
                    _useSubAPI = _subRecieverTestAPI;
                  }
                  else if((value.data()!['testMode'] == false)) {
                    _useSubAPI = _subRecieverLiveAPI;
                  }
                  if(this.referrelCode == 'REF_MNY') {
                    openCheckOut();
                  }
                  else {
                    if(referrelFound == false) {
                      await FirebaseFirestore.instance.collection('SubscribedBasicUsers').where('idActivated', isEqualTo: true).get().then((snaps) async {
                        for (int i = 0; i < snaps.docs.length; i++) {
                          if (this.referrelCode ==
                              ((snaps.docs[i].data()['ref_code']).toString())) {
                            referrelFound = true;
                            referrelPlan = 'basic';
                            _champID = champIDs['basic']!;
                            _subscriptionAmount = double.parse(_subAmount['basic']!);
                            _referrelAmtForInviter = (_referrelAmountForInviter['basic']!);
                            _referrelAmtForSubscriber = (_referrelAmountForSubscriber['basic']!);
                            cDialog(
                                context,
                                Icon(Icons.warning_amber_rounded,
                                    color: Color.fromARGB(255, 0, 113, 219)),
                                " Valid Referrel Code: "+ this.referrelCode,
                                'Valid referrel code for basic plan only.',
                                100,
                                Color.fromARGB(255, 0, 113, 219),
                                Color.fromARGB(255, 0, 113, 219), Container());
                            openCheckOut();
                            break;
                          }
                        }
                      });
                    }
                    if(referrelFound == false) {
                      await FirebaseFirestore.instance.collection('SubscribedPremiumUsers').where('idActivated', isEqualTo: true).get().then((snaps) async {
                        for (int i = 0; i < snaps.docs.length; i++) {
                          if (this.referrelCode ==
                              ((snaps.docs[i].data()['ref_code']).toString())) {
                            referrelFound = true;
                            referrelPlan = 'premium';
                            _champID = champIDs['premium']!;
                            _subscriptionAmount = double.parse(_subAmount['premium']!);
                            _referrelAmtForInviter = (_referrelAmountForInviter['premium']!);
                            _referrelAmtForSubscriber = (_referrelAmountForSubscriber['premium']!);
                            cDialog(
                                context,
                                Icon(Icons.warning_amber_rounded,
                                    color: Color.fromARGB(255, 0, 113, 219)),
                                " Valid Referrel Code: "+ this.referrelCode,
                                'Valid referrel code for premium plan only.',
                                100,
                                Color.fromARGB(255, 0, 113, 219),
                                Color.fromARGB(255, 0, 113, 219), Container());
                            openCheckOut();
                            break;
                          }
                        }
                      });
                    }
                    if(referrelFound == false) {
                      await FirebaseFirestore.instance.collection('SubscribedPlatinumUsers').where('idActivated', isEqualTo: true).get().then((snaps) async {
                        for (int i = 0; i < snaps.docs.length; i++) {
                          if (this.referrelCode ==
                              ((snaps.docs[i].data()['ref_code']).toString())) {
                            referrelFound = true;
                            referrelPlan = 'platinum';
                            _champID = champIDs['platinum']!;
                            _subscriptionAmount = double.parse(_subAmount['platinum']!);
                            _referrelAmtForInviter = (_referrelAmountForInviter['platinum']!);
                            _referrelAmtForSubscriber = (_referrelAmountForSubscriber['platinum']!);
                            cDialog(
                                context,
                                Icon(Icons.warning_amber_rounded,
                                    color: Color.fromARGB(255, 0, 113, 219)),
                                " Valid Referrel Code: "+ this.referrelCode,
                                'Valid referrel code for platinum plan only.',
                                100,
                                Color.fromARGB(255, 0, 113, 219),
                                Color.fromARGB(255, 0, 113, 219), Container());
                            openCheckOut();
                            break;
                          }
                        }
                      });
                    }
                    if(referrelFound == false) {
                      cDialog(
                          context,
                          Icon(Icons.warning_amber_rounded,
                              color: Color.fromARGB(255, 0, 113, 219)),
                          " Invalid Referrel Code: "+ this.referrelCode,
                          'Either Use valid referrel code this referrel code has been expired or try without any referrel code.',
                          150,
                          Color.fromARGB(255, 0, 113, 219),
                          Color.fromARGB(255, 0, 113, 219), Container());
                      this.referrelCode = 'REF_MNY';
                    }
                  }
                });
              },
              child: Center(
                  child: Text('Proceed To Subscribe',
                      style:
                      TextStyle(color: Colors.white, fontSize: 24))),
            )
          ],
        ),
      ),
    );
  }

  void _handleRadioValueChange(int? value) {
    setState(() {
      _radioValue = value!;

      switch (_radioValue) {
        case 1:
          selectedPlan = 'basic';
          _champID = champIDs['basic']!;
          _subscriptionAmount = double.parse(_subAmount['basic']!);
          _referrelAmtForInviter = (_referrelAmountForInviter['basic']!);
          _referrelAmtForSubscriber = (_referrelAmountForSubscriber['basic']!);
          cDialog(
              context,
              Icon(Icons.warning_amber_rounded,
                  color: Color.fromARGB(255, 0, 113, 219)),
              " Subscription Amount : "+ _subscriptionAmount.toString(),
              'If you use valid referrel code of any subscribed user then you will get Rs '+_referrelAmtForSubscriber.toString()+ ' and the subscriber whose referrel code you are using will get Rs '+_referrelAmtForInviter.toString()+ ' as wallet money that will be sanctioned to your bank account with next level achievements.',
              200,
              Color.fromARGB(255, 0, 113, 219),
              Color.fromARGB(255, 0, 113, 219), Container());
          break;

        case 2:
          selectedPlan = 'premium';
          _champID = champIDs['premium']!;
          _subscriptionAmount = double.parse(_subAmount['premium']!);
          _referrelAmtForInviter = (_referrelAmountForInviter['premium']!);
          _referrelAmtForSubscriber = (_referrelAmountForSubscriber['premium']!);
          cDialog(
              context,
              Icon(Icons.warning_amber_rounded,
                  color: Color.fromARGB(255, 0, 113, 219)),
              " Subscription Amount : "+ _subscriptionAmount.toString(),
              'If you use valid referrel code of any subscribed user then you will get Rs '+_referrelAmtForSubscriber.toString()+ ' and the subscriber whose referrel code you are using will get Rs '+_referrelAmtForInviter.toString()+ ' as wallet money that will be sanctioned to your bank account with next level achievements.',
              200,
              Color.fromARGB(255, 0, 113, 219),
              Color.fromARGB(255, 0, 113, 219), Container());
          break;

        case 3:
          selectedPlan = 'platinum';
          _champID = champIDs['platinum']!;
          _subscriptionAmount = double.parse(_subAmount['platinum']!);
          _referrelAmtForInviter = (_referrelAmountForInviter['platinum']!);
          _referrelAmtForSubscriber = (_referrelAmountForSubscriber['platinum']!);
          cDialog(
              context,
              Icon(Icons.warning_amber_rounded,
                  color: Color.fromARGB(255, 0, 113, 219)),
              " Subscription Amount : "+ _subscriptionAmount.toString(),
              'If you use valid referrel code of any subscribed user then you will get Rs '+_referrelAmtForSubscriber.toString()+ ' and the subscriber whose referrel code you are using will get Rs '+_referrelAmtForInviter.toString()+ ' as wallet money that will be sanctioned to your bank account with next level achievements.',
              200,
              Color.fromARGB(255, 0, 113, 219),
              Color.fromARGB(255, 0, 113, 219), Container());
          break;
      }
    });
  }


  Future<void> paymentSuccessful(PaymentSuccessResponse response) async {

    cDialog(
        context,
        Icon(Icons.verified,
            color: Colors.green),
        " Payment Successful!",
        'Please do not press anything for a moment.',
        125,
        Color.fromRGBO(71, 79, 156, 1),
        Color.fromRGBO(71, 79, 156, 1),
        Container());

   // Do something when payment succeeds
    bool referrelUsed = false;
    String referencerID = 'unknown';
    int walletBalance = 0;
    User _user = FirebaseAuth.instance.currentUser!;
    final _random = new Random();
    int refCode = 100000 + _random.nextInt(1000000 - 100000);

    await FirebaseFirestore.instance.collection('SubscribedUsers').doc(_user.uid).get().then((value) async {
      if(!value.exists) {
        FirebaseFirestore.instance.collection('SubscribedUsers').doc(_user.uid).set({
          "myPlans": {selectedPlan: true}
        });
      }
      if(value.exists) {
        Map<String,dynamic>? plans;
        await FirebaseFirestore.instance.collection('SubscribedUsers').doc(_user.uid).get().then((value) {
          plans = value.data()!['myPlans'];
          if(!(plans!.containsKey(selectedPlan))) {
            plans![selectedPlan] = true;
          }
        }).then((value) async {
          await FirebaseFirestore.instance.collection('SubscribedUsers').doc(_user.uid).update({
            "myPlans": plans
          });
        });
      }
    });

    if (this.referrelCode == 'REF_MNY') {
      if(selectedPlan == 'basic') {
        await FirebaseFirestore.instance
            .collection('SubscribedBasicUsers')
            .doc(_user.uid)
            .set({
          'champ_id': _champID,
          'idActivated': true,
          'wallet_balance': walletBalance,
          'ref_code': refCode,
          'referenceUsed': referrelUsed,
          'referencerID': referencerID,
          'subscriptionPaymentID': response.paymentId,
          'subscriptionDate': DateTime.now(),
          'subscriptionAmt': _subscriptionAmount.toString(),
          'currentLevel': 0,
          'myLevels': {
            'level_1': false,
            'level_2': false,
            'level_3': false,
            'level_4': false,
            'level_5': false,
            'level_6': false,
            'level_7': false,
            'level_8': false,
            'level_9': false,
            'level_final': false
          },
          'myReferrels': []
        });
        await FirebaseFirestore.instance
            .collection('AllotableChampID')
            .doc('allotable_champ_id')
            .update({"allotableChampId":{'platinum': champIDs['platinum'],
          'premium': champIDs['premium'],
          'basic': _champID + 1}});

        await FirebaseFirestore.instance.collection('BasicSubscriptionPayments').doc(response.paymentId).set({
          'subscriptionDate': DateTime.now(),
          'subscriberID': _user.uid,
          'paymentAmount': _subscriptionAmount
        });

        Fluttertoast.showToast(
            msg: 'Payment Successful, please wait.....',
            backgroundColor: Colors.green,
            textColor: Colors.white)
            .then((value) => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => DashBoard(currentPlan: 'basic'))));
      }
      if(selectedPlan == 'premium') {
        await FirebaseFirestore.instance
            .collection('SubscribedPremiumUsers')
            .doc(_user.uid)
            .set({
          'champ_id': _champID,
          'idActivated': true,
          'wallet_balance': walletBalance,
          'ref_code': refCode,
          'referenceUsed': referrelUsed,
          'referencerID': referencerID,
          'subscriptionPaymentID': response.paymentId,
          'subscriptionDate': DateTime.now(),
          'subscriptionAmt': _subscriptionAmount.toString(),
          'currentLevel': 0,
          'myLevels': {
            'level_1': false,
            'level_2': false,
            'level_3': false,
            'level_4': false,
            'level_5': false,
            'level_6': false,
            'level_7': false,
            'level_8': false,
            'level_9': false,
            'level_final': false
          },
          'myReferrels': []
        });
        await FirebaseFirestore.instance
            .collection('AllotableChampID')
            .doc('allotable_champ_id')
            .update({"allotableChampId":{'platinum': champIDs['platinum'],
          'basic': champIDs['basic'],
          'premium': _champID + 1}});

        await FirebaseFirestore.instance.collection('PremiumSubscriptionPayments').doc(response.paymentId).set({
          'subscriptionDate': DateTime.now(),
          'subscriberID': _user.uid,
          'paymentAmount': _subscriptionAmount
        });

        Fluttertoast.showToast(
            msg: 'Payment Successful, please wait.....',
            backgroundColor: Colors.green,
            textColor: Colors.white)
            .then((value) => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => DashBoard(currentPlan: 'premium'))));
      }
      if(selectedPlan == 'platinum') {
        await FirebaseFirestore.instance
            .collection('SubscribedPlatinumUsers')
            .doc(_user.uid)
            .set({
          'champ_id': _champID,
          'idActivated': true,
          'wallet_balance': walletBalance,
          'ref_code': refCode,
          'referenceUsed': referrelUsed,
          'referencerID': referencerID,
          'subscriptionPaymentID': response.paymentId,
          'subscriptionDate': DateTime.now(),
          'subscriptionAmt': _subscriptionAmount.toString(),
          'currentLevel': 0,
          'myLevels': {
            'level_1': false,
            'level_2': false,
            'level_3': false,
            'level_4': false,
            'level_5': false,
            'level_6': false,
            'level_7': false,
            'level_8': false,
            'level_9': false,
            'level_final': false
          },
          'myReferrels': []
        });
        await FirebaseFirestore.instance
            .collection('AllotableChampID')
            .doc('allotable_champ_id')
            .update({"allotableChampId":{'premium': champIDs['premium'],
          'basic': champIDs['basic'],
          'platinum': _champID + 1}});

        await FirebaseFirestore.instance.collection('PlatinumSubscriptionPayments').doc(response.paymentId).set({
          'subscriptionDate': DateTime.now(),
          'subscriberID': _user.uid,
          'paymentAmount': _subscriptionAmount
        });

        Fluttertoast.showToast(
            msg: 'Payment Successful, please wait.....',
            backgroundColor: Colors.green,
            textColor: Colors.white)
            .then((value) => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => DashBoard(currentPlan: 'platinum'))));
      }
    } else {
      if (referrelFound) {
        if(referrelPlan == 'basic') {
          await FirebaseFirestore.instance
              .collection('SubscribedBasicUsers')
              .where('idActivated', isEqualTo: true)
              .get()
              .then((snaps) async {
            for (int i = 0; i < snaps.docs.length; i++) {
              if (this.referrelCode ==
                  ((snaps.docs[i].data()['ref_code']).toString())) {
                List<dynamic> inviterReferrels = [];
                referrelUsed = true;
                referencerID = snaps.docs[i].id;
                int oldWalletBalance = snaps.docs[i].data()['wallet_balance'];
                int newWalletBalance = oldWalletBalance + _referrelAmtForInviter;
                await FirebaseFirestore.instance.collection('SubscribedBasicUsers').doc(referencerID).get().then((value) {
                  inviterReferrels = value.data()!['myReferrels'];
                });
                inviterReferrels.add(_user.uid);
                await FirebaseFirestore.instance
                    .collection('SubscribedBasicUsers')
                    .doc(referencerID)
                    .update({
                  'wallet_balance': newWalletBalance,
                  'myReferrels': inviterReferrels
                });
                break;
              }
            }
          });
          if (referrelUsed) {
            walletBalance = walletBalance + _referrelAmtForSubscriber;
          }
          await FirebaseFirestore.instance
              .collection('SubscribedBasicUsers')
              .doc(_user.uid)
              .set({
            'champ_id': _champID,
            'idActivated': true,
            'wallet_balance': walletBalance,
            'ref_code': refCode,
            'referenceUsed': referrelUsed,
            'referencerID': referencerID,
            'subscriptionPaymentID': response.paymentId,
            'subscriptionDate': DateTime.now(),
            'subscriptionAmt': _subscriptionAmount.toString(),
            'currentLevel': 0,
            'myLevels': {
              'level_1': false,
              'level_2': false,
              'level_3': false,
              'level_4': false,
              'level_5': false,
              'level_6': false,
              'level_7': false,
              'level_8': false,
              'level_9': false,
              'level_final': false
            },
            'myReferrels': []
          });

          await FirebaseFirestore.instance
              .collection('AllotableChampID')
              .doc('allotable_champ_id')
              .update({"allotableChampId":{'premium': champIDs['premium'],
            'platinum': champIDs['platinum'],
            'basic': _champID + 1}});

          await FirebaseFirestore.instance.collection('BasicSubscriptionPayments').doc(response.paymentId).set({
            'subscriptionDate': DateTime.now(),
            'subscriberID': _user.uid,
            'paymentId': response.paymentId
          });

          Fluttertoast.showToast(
              msg: 'please wait.....',
              backgroundColor: Colors.green,
              textColor: Colors.white)
              .then((value) => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => DashBoard(currentPlan: 'basic'))));
        }

        if(referrelPlan == 'premium') {
          await FirebaseFirestore.instance
              .collection('SubscribedPremiumUsers')
              .where('idActivated', isEqualTo: true)
              .get()
              .then((snaps) async {
            for (int i = 0; i < snaps.docs.length; i++) {
              if (this.referrelCode ==
                  ((snaps.docs[i].data()['ref_code']).toString())) {
                List<dynamic> inviterReferrels = [];
                referrelUsed = true;
                referencerID = snaps.docs[i].id;
                int oldWalletBalance = snaps.docs[i].data()['wallet_balance'];
                int newWalletBalance = oldWalletBalance + _referrelAmtForInviter;
                await FirebaseFirestore.instance.collection('SubscribedPremiumUsers').doc(referencerID).get().then((value) {
                  inviterReferrels = value.data()!['myReferrels'];
                });
                inviterReferrels.add(_user.uid);
                await FirebaseFirestore.instance
                    .collection('SubscribedPremiumUsers')
                    .doc(referencerID)
                    .update({
                  'wallet_balance': newWalletBalance,
                  'myReferrels': inviterReferrels
                });
                break;
              }
            }
          });
          if (referrelUsed) {
            walletBalance = walletBalance + _referrelAmtForSubscriber;
          }
          await FirebaseFirestore.instance
              .collection('SubscribedPremiumUsers')
              .doc(_user.uid)
              .set({
            'champ_id': _champID,
            'idActivated': true,
            'wallet_balance': walletBalance,
            'ref_code': refCode,
            'referenceUsed': referrelUsed,
            'referencerID': referencerID,
            'subscriptionPaymentID': response.paymentId,
            'subscriptionDate': DateTime.now(),
            'subscriptionAmt': _subscriptionAmount.toString(),
            'currentLevel': 0,
            'myLevels': {
              'level_1': false,
              'level_2': false,
              'level_3': false,
              'level_4': false,
              'level_5': false,
              'level_6': false,
              'level_7': false,
              'level_8': false,
              'level_9': false,
              'level_final': false
            },
            'myReferrels': []
          });

          await FirebaseFirestore.instance
              .collection('AllotableChampID')
              .doc('allotable_champ_id')
              .update({"allotableChampId":{'basic': champIDs['basic'],
            'platinum': champIDs['platinum'],
            'premium': _champID + 1}});

          await FirebaseFirestore.instance.collection('PremiumSubscriptionPayments').doc(response.paymentId).set({
            'subscriptionDate': DateTime.now(),
            'subscriberID': _user.uid,
            'paymentId': response.paymentId
          });

          Fluttertoast.showToast(
              msg: 'please wait.....',
              backgroundColor: Colors.green,
              textColor: Colors.white)
              .then((value) => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => DashBoard(currentPlan: 'premium'))));
        }

        if(referrelPlan == 'platinum') {
          await FirebaseFirestore.instance
              .collection('SubscribedPlatinumUsers')
              .where('idActivated', isEqualTo: true)
              .get()
              .then((snaps) async {
            for (int i = 0; i < snaps.docs.length; i++) {
              if (this.referrelCode ==
                  ((snaps.docs[i].data()['ref_code']).toString())) {
                List<dynamic> inviterReferrels = [];
                referrelUsed = true;
                referencerID = snaps.docs[i].id;
                int oldWalletBalance = snaps.docs[i].data()['wallet_balance'];
                int newWalletBalance = oldWalletBalance + _referrelAmtForInviter;
                await FirebaseFirestore.instance.collection('SubscribedPlatinumUsers').doc(referencerID).get().then((value) {
                  inviterReferrels = value.data()!['myReferrels'];
                });
                inviterReferrels.add(_user.uid);
                await FirebaseFirestore.instance
                    .collection('SubscribedPlatinumUsers')
                    .doc(referencerID)
                    .update({
                  'wallet_balance': newWalletBalance,
                  'myReferrels': inviterReferrels
                });
                break;
              }
            }
          });
          if (referrelUsed) {
            walletBalance = walletBalance + _referrelAmtForSubscriber;
          }
          await FirebaseFirestore.instance
              .collection('SubscribedPlatinumUsers')
              .doc(_user.uid)
              .set({
            'champ_id': _champID,
            'idActivated': true,
            'wallet_balance': walletBalance,
            'ref_code': refCode,
            'referenceUsed': referrelUsed,
            'referencerID': referencerID,
            'subscriptionPaymentID': response.paymentId,
            'subscriptionDate': DateTime.now(),
            'subscriptionAmt': _subscriptionAmount.toString(),
            'currentLevel': 0,
            'myLevels': {
              'level_1': false,
              'level_2': false,
              'level_3': false,
              'level_4': false,
              'level_5': false,
              'level_6': false,
              'level_7': false,
              'level_8': false,
              'level_9': false,
              'level_final': false
            },
            'myReferrels': []
          });

          await FirebaseFirestore.instance
              .collection('AllotableChampID')
              .doc('allotable_champ_id')
              .update({"allotableChampId":{'basic': champIDs['basic'],
            'premium': champIDs['premium'],
            'platinum': _champID + 1}});

          await FirebaseFirestore.instance.collection('PlatinumSubscriptionPayments').doc(response.paymentId).set({
            'subscriptionDate': DateTime.now(),
            'subscriberID': _user.uid,
            'paymentId': response.paymentId
          });

          Fluttertoast.showToast(
              msg: 'please wait.....',
              backgroundColor: Colors.green,
              textColor: Colors.white)
              .then((value) => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => DashBoard(currentPlan: 'platinum'))));
        }
      }
    }
  }
}