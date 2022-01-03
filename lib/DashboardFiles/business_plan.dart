import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mny_champ/SharedFiles/invite_users.dart';

class BusinessPlan extends StatefulWidget {
  final String userRefCode,currentPlan;
  BusinessPlan({required this.userRefCode, required this.currentPlan});
  @override
  _BusinessPlanState createState() => _BusinessPlanState();
}

class _BusinessPlanState extends State<BusinessPlan> {
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
          ? 'ca-app-pub-3518368113893985/4458975134'
          : 'ca-app-pub-3518368113893985/4458975134',
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
            title: Text('MNY CHAMP '+ widget.currentPlan.toUpperCase() +' PLAN',style: TextStyle(fontSize: 16),),
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                          columns: [
                            DataColumn(label: Text('LEVEL'),),
                            DataColumn(label: Text('MEMBER'),),
                            DataColumn(label: Text('JOIN'),),
                            DataColumn(label: Text('REWARD'),),
                            DataColumn(label: Text('DAY'),),
                            DataColumn(label: Text('TOTAL'),),
                          ],
                          rows:[
                            DataRow(cells: [
                              DataCell(Text("1")),
                              DataCell(Text("0 - 30")),
                              DataCell(Text("1")),
                              DataCell((widget.currentPlan == 'basic') ? Text("75") : (widget.currentPlan =='premium') ? Text("150") : Text("300")),
                              DataCell(Text("3")),
                              DataCell((widget.currentPlan == 'basic') ? Text("225") : (widget.currentPlan =='premium') ? Text("450") : Text("900")),
                            ]),
                            DataRow(cells: [
                              DataCell(Text("2")),
                              DataCell(Text("31 - 100")),
                              DataCell(Text("2")),
                              DataCell((widget.currentPlan == 'basic') ? Text("100") : (widget.currentPlan =='premium') ? Text("200") : Text("400")),
                              DataCell(Text("4")),
                              DataCell((widget.currentPlan == 'basic') ? Text("400") : (widget.currentPlan =='premium') ? Text("800") : Text("1600")),
                            ]),
                            DataRow(cells: [
                              DataCell(Text("3")),
                              DataCell(Text("101 - 350")),
                              DataCell(Text("3")),
                              DataCell((widget.currentPlan == 'basic') ? Text("140") : (widget.currentPlan =='premium') ? Text("280") : Text("560")),
                              DataCell(Text("5")),
                              DataCell((widget.currentPlan == 'basic') ? Text("700") : (widget.currentPlan =='premium') ? Text("1400") : Text("2800")),
                            ]),
                            DataRow(cells: [
                              DataCell(Text("4")),
                              DataCell(Text("351 - 800")),
                              DataCell(Text("4")),
                              DataCell((widget.currentPlan == 'basic') ? Text("200") : (widget.currentPlan =='premium') ? Text("400") : Text("800")),
                              DataCell(Text("5")),
                              DataCell((widget.currentPlan == 'basic') ? Text("1000") : (widget.currentPlan =='premium') ? Text("2000") : Text("4000")),
                            ]),
                            DataRow(cells: [
                              DataCell(Text("5")),
                              DataCell(Text("801 - 1800")),
                              DataCell(Text("6")),
                              DataCell((widget.currentPlan == 'basic') ? Text("350") : (widget.currentPlan =='premium') ? Text("700") : Text("1400")),
                              DataCell(Text("5")),
                              DataCell((widget.currentPlan == 'basic') ? Text("1750") : (widget.currentPlan =='premium') ? Text("3550") : Text("7000")),
                            ]),
                            DataRow(cells: [
                              DataCell(Text("6")),
                              DataCell(Text("1801 - 3000")),
                              DataCell(Text("8")),
                              DataCell((widget.currentPlan == 'basic') ? Text("425") : (widget.currentPlan =='premium') ? Text("850") : Text("1700")),
                              DataCell(Text("6")),
                              DataCell((widget.currentPlan == 'basic') ? Text("2550") : (widget.currentPlan =='premium') ? Text("5100") : Text("10200")),
                            ]),
                            DataRow(cells: [
                              DataCell(Text("7")),
                              DataCell(Text("3001 - 5400")),
                              DataCell(Text("10")),
                              DataCell((widget.currentPlan == 'basic') ? Text("625") : (widget.currentPlan =='premium') ? Text("1250") : Text("2500")),
                              DataCell(Text("6")),
                              DataCell((widget.currentPlan == 'basic') ? Text("3750") : (widget.currentPlan =='premium') ? Text("7500") : Text("15000")),
                            ]),
                            DataRow(cells: [
                              DataCell(Text("8")),
                              DataCell(Text("5401 - 9200")),
                              DataCell(Text("12")),
                              DataCell((widget.currentPlan == 'basic') ? Text("875") : (widget.currentPlan =='premium') ? Text("1750") : Text("3500")),
                              DataCell(Text("6")),
                              DataCell((widget.currentPlan == 'basic') ? Text("5250") : (widget.currentPlan =='premium') ? Text("10500") : Text("21000")),
                            ]),
                            DataRow(cells: [
                              DataCell(Text("9")),
                              DataCell(Text("9201 - 16000")),
                              DataCell(Text("14")),
                              DataCell((widget.currentPlan == 'basic') ? Text("1000") : (widget.currentPlan =='premium') ? Text("2000") : Text("4000")),
                              DataCell(Text("6")),
                              DataCell((widget.currentPlan == 'basic') ? Text("6000") : (widget.currentPlan =='premium') ? Text("12000") : Text("24000")),
                            ]),
                            DataRow(cells: [
                              DataCell(Text("10")),
                              DataCell(Text("16001 - 30000")),
                              DataCell(Text("16")),
                              DataCell((widget.currentPlan == 'basic') ? Text("1207.5") : (widget.currentPlan =='premium') ? Text("2415") : Text("4830")),
                              DataCell(Text("6")),
                              DataCell((widget.currentPlan == 'basic') ? Text("7245") : (widget.currentPlan =='premium') ? Text("14490") : Text("28980")),
                            ]),
                          ]
                      ),
                    ),
                    SizedBox(height: 20),
                    Card( color: Color.fromRGBO(121, 199, 200, 1),child: ListTile(title: Text('LEVEL: Level is the number of level that will be assigned to you when you joins specified new entries at particular level.',style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic)))),
                    SizedBox(height: 10),
                    Card( color: Color.fromRGBO(121, 199, 200, 1),child: ListTile(title: Text('MEMBER: Member is the number of child entries that will be joined individually or by someone\'s reference at particular level.',style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic)))),
                    SizedBox(height: 10),
                    Card( color: Color.fromRGBO(121, 199, 200, 1),child: ListTile(title: Text('JOIN: Join is the number of new entries that you have to invite on your own behalf to achieve particular level.',style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic)))),
                    SizedBox(height: 10),
                    Card( color: Color.fromRGBO(121, 199, 200, 1),child: ListTile(title: Text('REWARD: Reward is the amount of money that will be transferred to your bank account for DAY at particular level with your wallet balances.',style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic)))),
                    SizedBox(height: 10),
                    Card( color: Color.fromRGBO(121, 199, 200, 1),child: ListTile(title: Text('DAY: Day is the number of days for which REWARD amount will be transferred to your bank account at continuous days except holidays or sunday.',style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic)))),
                    SizedBox(height: 10),
                    Card( color: Color.fromRGBO(121, 199, 200, 1),child: ListTile(title: Text('TOTAL: Total is the amount of money that will be transferred to your bank account for particular level completion.',style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic)))),
                    SizedBox(height: 10),
                    Card( color: Colors.blue,child: ListTile(title: Text('BLUE ENTRIES: Those entries which are not invited by you, either invited by your child entries or they subscribed individually.\n\nNote: Topmost or first entry is yours.',style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic)))),
                    SizedBox(height: 10),
                    Card( color: Colors.green,child: ListTile(title: Text('GREEN ENTRIES: Those entries which are subscribed using your referrel code and only for green entries you get wallet balances.',style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic)))),
                    SizedBox(height: 10),
                    Card( color: Color.fromRGBO(121, 199, 200, 1),child: ListTile(title: Text('REFEREL CODE: Referrel code is used to invite new subscribers but every 24 hours your referrel code will be updated so never use old referrel code to invite new subscribers.',style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic)))),
                    SizedBox(height: 10),
                    Card( color: Color.fromRGBO(121, 199, 200, 1),child: ListTile(title: Text('WALLET BALANCE: Wallet Balance is the amount of money that you earns by inviting new entries with your referrel code and this money will be transferred to your bank account at time of particular level completion.',style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic)))),
                    SizedBox(height: 10),
                    Card( color: Color.fromRGBO(167, 121, 200, 1.0),child: ListTile(title: Text('PAYMENTS: Payments will be transferred to your bank account in specific way as: \n\nLevel LNo -> Completed -> Wallet Balance + (Rewards*Days)\n\nNote:-Wallet balance will be transferred with your first day reward amount after that in next days you will be paid only rewards for particular level.\n\n*You will get your total payment with a deduction of 12.5% only as service tax from MNY CHAMP including Google play services, payment services, developer fees, GST and RTR submitted by MNY CHAMP Authorities etc.',style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic)))),
                    SizedBox(height: 10),
                    Card( color: Color.fromRGBO(121, 199, 200, 1),child: ListTile(title: Text('SUBSCRIBE: Subscription is the event that will be fired that you can take subscription at MNY CHAMP from scratch.',style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic)))),
                    SizedBox(height: 10),
                    Card( color: Color.fromRGBO(71, 79, 156, 1),child: ListTile(title: Text('UPDATE: Whenever you receive notifications regarding latest update you are supposed to take latest update from play store to get reflected user interface and enhanced features.',style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic)))),
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
        ),
    );
  }
}